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

internal import libraw

/// A description of the unpacked raw sensor buffer.
///
/// Mirrors the geometry and layout of LibRAW's `libraw_rawdata_t`. After a
/// ``RAWFile`` is unpacked, LibRAW populates exactly one of several buffer
/// variants depending on the camera and decode path; ``layout`` reports which
/// one, so a consumer knows what the data looks like even for the less common
/// multi-channel and floating-point variants that have no dedicated accessor.
///
/// The single-channel 16-bit Bayer buffer — by far the most common — is read
/// through ``RAWFile/rawImage`` and ``RAWFile/withRawImage(_:)``.
public struct RAWSensorData: Sendable, Equatable
{
    /// The in-memory form of the unpacked sensor data.
    public enum Layout: Sendable, Equatable
    {
        /// No raw buffer is available (the file has not been unpacked, or the
        /// decoder produced none).
        case none

        /// A single-channel 16-bit Bayer/mosaic buffer (`raw_image`).
        case bayer

        /// A three-channel 16-bit buffer (`color3_image`).
        case color3

        /// A four-channel 16-bit buffer (`color4_image`).
        case color4

        /// A single-channel floating-point buffer (`float_image`).
        case bayerFloat

        /// A three-channel floating-point buffer (`float3_image`).
        case color3Float

        /// A four-channel floating-point buffer (`float4_image`).
        case color4Float
    }

    /// The full sensor width, in pixels.
    public let width: Int

    /// The full sensor height, in pixels.
    public let height: Int

    /// The number of bytes per row of the raw buffer.
    public let pitch: Int

    /// The in-memory layout LibRAW populated for the unpacked data.
    public let layout: Layout

    /// The number of components per pixel (`1` for Bayer, `3`, `4`, or `0` when
    /// no buffer is available).
    public var componentCount: Int
    {
        switch self.layout
        {
            case .none:                    return 0
            case .bayer, .bayerFloat:      return 1
            case .color3, .color3Float:    return 3
            case .color4, .color4Float:    return 4
        }
    }

    /// Whether the samples are floating-point rather than 16-bit integers.
    public var isFloatingPoint: Bool
    {
        switch self.layout
        {
            case .bayerFloat, .color3Float, .color4Float:

                return true

            case .none, .bayer, .color3, .color4:

                return false
        }
    }

    /// Whether an unpacked raw buffer pointer is present.
    ///
    /// This reflects buffer presence, not that ``RAWFile/withRawImage(_:)`` will
    /// necessarily vend samples — that additionally requires a valid row pitch.
    public var hasBuffer: Bool
    {
        self.layout != .none
    }

    /// Creates sensor data from explicit values.
    ///
    /// - Parameters:
    ///   - width: The full sensor width.
    ///   - height: The full sensor height.
    ///   - pitch: The number of bytes per raw row.
    ///   - layout: The in-memory layout of the unpacked data.
    public init( width: Int, height: Int, pitch: Int, layout: Layout )
    {
        self.width  = width
        self.height = height
        self.pitch  = pitch
        self.layout = layout
    }

    /// Creates sensor data from LibRAW's raw data and image sizes.
    ///
    /// The layout is derived from whichever buffer pointer LibRAW populated,
    /// checked in priority order; when none are set the layout is ``Layout/none``.
    ///
    /// - Parameters:
    ///   - rawData: A pointer to the LibRAW raw-data structure.
    ///   - sizes: The LibRAW image sizes structure.
    internal init( from rawData: UnsafePointer< libraw_rawdata_t >, sizes: libraw_image_sizes_t )
    {
        let layout: Layout

        if rawData.pointee.raw_image != nil
        {
            layout = .bayer
        }
        else if rawData.pointee.color3_image != nil
        {
            layout = .color3
        }
        else if rawData.pointee.color4_image != nil
        {
            layout = .color4
        }
        else if rawData.pointee.float_image != nil
        {
            layout = .bayerFloat
        }
        else if rawData.pointee.float3_image != nil
        {
            layout = .color3Float
        }
        else if rawData.pointee.float4_image != nil
        {
            layout = .color4Float
        }
        else
        {
            layout = .none
        }

        self.init( width: Int( sizes.raw_width ), height: Int( sizes.raw_height ), pitch: Int( sizes.raw_pitch ), layout: layout )
    }
}
