/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2026, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation
internal import libraw

/// A read-only view over a camera RAW file, backed by LibRAW.
///
/// `RAWFile` opens a RAW file — from a URL or in-memory data — and, depending on
/// the ``RAWParsingOptions``, unpacks its sensor data. Structured metadata and
/// the raw sensor buffer are read off the underlying LibRAW instance.
///
/// The wrapper owns a heap-allocated LibRAW instance for its entire lifetime and
/// releases it on deinitialization. It is a reference type and is intentionally
/// **not** `Sendable`: the underlying LibRAW instance is not thread-safe to share
/// across concurrency domains.
public final class RAWFile: CustomStringConvertible
{
    /// The options the file was parsed with.
    public let options: RAWParsingOptions

    /// The heap-allocated LibRAW instance owned by this file.
    ///
    /// Held through a stable pointer that is never relocated, so the C++ class'
    /// internal self-pointers stay valid for the file's lifetime.
    private let raw: UnsafeMutablePointer< LibRaw >

    /// A stable copy of the input bytes, owned for the file's lifetime, when the
    /// file was opened from in-memory data; `nil` when opened from a URL.
    ///
    /// LibRAW's `open_buffer` keeps the supplied pointer and reads from it
    /// lazily — during `unpack` and metadata access — without copying it, so the
    /// bytes must stay valid until the instance is released.
    private let buffer: UnsafeMutableRawBufferPointer?

    /// Whether the RAW data has been unpacked.
    private var unpacked: Bool

    /// Opens a RAW file from a URL.
    ///
    /// - Parameters:
    ///   - url: A file URL pointing at the RAW file.
    ///   - options: The parsing options. Defaults to ``RAWParsingOptions/default``.
    ///
    /// - Throws: ``RAWError/invalidFileURL(_:)`` if `url` is not a file URL,
    ///   ``RAWError/cannotReadFile(_:)`` if the file does not exist or is not
    ///   readable, or an open/unpack error if LibRAW fails.
    public convenience init( url: URL, options: RAWParsingOptions = .default ) throws
    {
        guard url.isFileURL
        else
        {
            throw RAWError.invalidFileURL( url )
        }

        let path = url.withUnsafeFileSystemRepresentation
        {
            $0.map { String( cString: $0 ) }
        }

        guard let path, FileManager.default.isReadableFile( atPath: path )
        else
        {
            throw RAWError.cannotReadFile( url )
        }

        let raw    = try RAWFile.makeLibRaw()
        let status = path.withCString
        {
            raw.pointee.open_file( $0 )
        }

        guard status == LIBRAW_SUCCESS.rawValue
        else
        {
            raw.pointee.recycle()
            SwiftRAWDestroyLibRaw( raw )

            throw RAWFile.openError( for: status )
        }

        try self.init( raw: raw, buffer: nil, options: options )
    }

    /// Opens a RAW file from in-memory data.
    ///
    /// - Parameters:
    ///   - data: The complete contents of a RAW file.
    ///   - options: The parsing options. Defaults to ``RAWParsingOptions/default``.
    ///
    /// - Throws: An open/unpack error if LibRAW cannot read the data.
    public convenience init( data: Data, options: RAWParsingOptions = .default ) throws
    {
        let raw = try RAWFile.makeLibRaw()

        // LibRAW's `open_buffer` keeps the supplied pointer and reads from it
        // lazily, without copying, so the bytes must remain valid for the whole
        // lifetime of the instance. The pointer vended by `Data.withUnsafeBytes`
        // is only valid within its closure, so the bytes are copied into a
        // stable buffer that this file owns and frees on release.
        let buffer = UnsafeMutableRawBufferPointer.allocate( byteCount: data.count, alignment: MemoryLayout< UInt8 >.alignment )

        data.copyBytes( to: buffer )

        let status = raw.pointee.open_buffer( buffer.baseAddress, buffer.count )

        guard status == LIBRAW_SUCCESS.rawValue
        else
        {
            raw.pointee.recycle()
            SwiftRAWDestroyLibRaw( raw )
            buffer.deallocate()

            throw RAWFile.openError( for: status )
        }

        try self.init( raw: raw, buffer: buffer, options: options )
    }

    /// The designated initializer, taking ownership of an already-opened LibRAW
    /// instance.
    ///
    /// - Parameters:
    ///   - raw: A LibRAW instance on which `open_file`/`open_buffer` has already
    ///     succeeded. Ownership is transferred to the new file.
    ///   - buffer: The stable byte buffer backing an in-memory open, owned for
    ///     the file's lifetime, or `nil` for a URL-based open.
    ///   - options: The parsing options.
    ///
    /// - Throws: An unpack error if eager unpacking is requested and fails. In
    ///   that case the instance and buffer are released before rethrowing.
    private init( raw: UnsafeMutablePointer< LibRaw >, buffer: UnsafeMutableRawBufferPointer?, options: RAWParsingOptions ) throws
    {
        self.raw      = raw
        self.buffer   = buffer
        self.options  = options
        self.unpacked = false

        guard options.unpacksImmediately
        else
        {
            return
        }

        do
        {
            try self.unpack()
        }
        catch
        {
            raw.pointee.recycle()
            SwiftRAWDestroyLibRaw( raw )
            buffer?.deallocate()

            throw error
        }
    }

    deinit
    {
        self.raw.pointee.recycle()
        SwiftRAWDestroyLibRaw( self.raw )
        self.buffer?.deallocate()
    }

    /// Unpacks the RAW sensor data if it has not been unpacked yet.
    ///
    /// This is idempotent: calling it more than once has no additional effect.
    /// It is called automatically during initialization when
    /// ``RAWParsingOptions/unpacksImmediately`` is `true`.
    ///
    /// - Throws: ``RAWError/unpackFailed(code:message:)`` (or
    ///   ``RAWError/unsupportedFormat``) if LibRAW fails to unpack.
    public func unpack() throws
    {
        guard self.unpacked == false
        else
        {
            return
        }

        let status = self.raw.pointee.unpack()

        guard status == LIBRAW_SUCCESS.rawValue
        else
        {
            throw RAWFile.unpackError( for: status )
        }

        self.unpacked = true
    }

    /// The geometry of the RAW image: sensor and output dimensions, margins,
    /// pitch, pixel aspect, and orientation.
    public var imageSizes: RAWImageSizes
    {
        RAWImageSizes( from: self.raw.pointee.imgdata.sizes )
    }

    /// Camera identification and sensor-description metadata.
    public var imageInfo: RAWImageInfo
    {
        RAWImageInfo( from: self.raw.pointee.imgdata.idata )
    }

    /// The color-filter-array layout of the sensor.
    public var cfaPattern: RAWCFAPattern
    {
        RAWCFAPattern( from: self.raw.pointee.imgdata.idata )
    }

    /// Exposure and shot metadata (ISO, shutter, aperture, focal length,
    /// timestamp, description, artist, body serial).
    public var shotInfo: RAWShotInfo
    {
        RAWShotInfo( from: self.raw.pointee.imgdata.other, shooting: self.raw.pointee.imgdata.shootinginfo )
    }

    /// The GPS location recorded with the file, or `nil` if none is present.
    public var gpsInfo: RAWGPSInfo?
    {
        RAWGPSInfo( from: self.raw.pointee.imgdata.other.parsed_gps )
    }

    /// Color calibration data: black/saturation levels, white-balance
    /// multipliers, and color-conversion matrices.
    public var colorData: RAWColorData
    {
        withUnsafePointer( to: &self.raw.pointee.imgdata.color )
        {
            RAWColorData( from: $0 )
        }
    }

    /// Lens identification and characteristics.
    public var lensInfo: RAWLensInfo
    {
        RAWLensInfo( from: self.raw.pointee.imgdata.lens )
    }

    /// Camera-common maker-note metadata (flash, temperatures, color space,
    /// firmware, sensitivity).
    public var cameraMetadata: RAWCameraMetadata
    {
        RAWCameraMetadata( from: self.raw.pointee.imgdata.makernotes.common )
    }

    /// A basic textual summary of the RAW file.
    public var description: String
    {
        let width  = Int( self.raw.pointee.imgdata.sizes.raw_width )
        let height = Int( self.raw.pointee.imgdata.sizes.raw_height )

        return "RAWFile( \( width )x\( height ), unpacked: \( self.unpacked ) )"
    }

    /// Heap-allocates a LibRAW instance.
    ///
    /// - Throws: ``RAWError/libRAWError(code:message:)`` if allocation fails.
    /// - Returns: A newly allocated LibRAW instance.
    private static func makeLibRaw() throws -> UnsafeMutablePointer< LibRaw >
    {
        guard let raw = SwiftRAWCreateLibRaw( 0 )
        else
        {
            throw RAWError.libRAWError( code: LIBRAW_UNSUFFICIENT_MEMORY.rawValue, message: RAWFile.message( for: LIBRAW_UNSUFFICIENT_MEMORY.rawValue ) )
        }

        return raw
    }

    /// Maps a LibRAW open status code to a ``RAWError``.
    ///
    /// - Parameter code: A non-success LibRAW status code from an open call.
    /// - Returns: The corresponding error.
    private static func openError( for code: Int32 ) -> RAWError
    {
        if code == LIBRAW_FILE_UNSUPPORTED.rawValue
        {
            return .unsupportedFormat
        }

        return .openFailed( code: code, message: RAWFile.message( for: code ) )
    }

    /// Maps a LibRAW unpack status code to a ``RAWError``.
    ///
    /// - Parameter code: A non-success LibRAW status code from an unpack call.
    /// - Returns: The corresponding error.
    private static func unpackError( for code: Int32 ) -> RAWError
    {
        if code == LIBRAW_FILE_UNSUPPORTED.rawValue
        {
            return .unsupportedFormat
        }

        return .unpackFailed( code: code, message: RAWFile.message( for: code ) )
    }

    /// Returns the LibRAW error message for a status code.
    ///
    /// - Parameter code: A LibRAW status code.
    /// - Returns: The message from `libraw_strerror`, or an empty string.
    private static func message( for code: Int32 ) -> String
    {
        guard let cString = libraw_strerror( code )
        else
        {
            return ""
        }

        return String( cString: cString )
    }
}
