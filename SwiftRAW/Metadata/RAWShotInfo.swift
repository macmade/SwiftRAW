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

/// Exposure and shot metadata for a RAW capture.
///
/// Mirrors the commonly used fields of LibRAW's `libraw_imgother_t`, plus the
/// camera body serial from `libraw_shootinginfo_t`. Camera-specific shooting
/// mode codes are intentionally left out of this curated, cross-vendor subset.
public struct RAWShotInfo: Sendable, Equatable, CustomStringConvertible
{
    /// A compact summary of the exposure settings (ISO, shutter, aperture,
    /// focal length), omitting values the file does not record.
    public var description: String
    {
        let shutter: String

        if self.shutterSpeed > 0, self.shutterSpeed < 1
        {
            let denominator = ( 1 / self.shutterSpeed ).rounded()

            shutter = denominator.isFinite && denominator < 1e9
                ? "1/\( Int( denominator ) )s"
                : "\( self.shutterSpeed.compactDescription )s"
        }
        else if self.shutterSpeed > 0
        {
            shutter = "\( self.shutterSpeed.compactDescription )s"
        }
        else
        {
            shutter = ""
        }

        let parts =
        [
            self.isoSpeed    > 0 ? "ISO \( self.isoSpeed.compactDescription )" : "",
            shutter,
            self.aperture    > 0 ? "f/\( self.aperture.compactDescription )" : "",
            self.focalLength > 0 ? "\( self.focalLength.compactDescription )mm" : "",
        ]

        let summary = parts.filter { $0.isEmpty == false }.joined( separator: ", " )

        return summary.isEmpty ? "no exposure data" : summary
    }

    /// The ISO sensitivity.
    public let isoSpeed: Float

    /// The shutter speed, in seconds.
    public let shutterSpeed: Float

    /// The aperture, as an f-number.
    public let aperture: Float

    /// The focal length, in millimeters.
    public let focalLength: Float

    /// The capture timestamp, or `nil` if the file records none.
    public let timestamp: Date?

    /// The position of this shot in the capture sequence.
    public let shotOrder: Int

    /// The image description recorded in the file.
    public let imageDescription: String

    /// The artist/author recorded in the file.
    public let artist: String

    /// The camera body serial number, if recorded.
    public let bodySerial: String

    /// Creates shot information from explicit values.
    ///
    /// - Parameters:
    ///   - isoSpeed: The ISO sensitivity.
    ///   - shutterSpeed: The shutter speed, in seconds.
    ///   - aperture: The aperture, as an f-number.
    ///   - focalLength: The focal length, in millimeters.
    ///   - timestamp: The capture timestamp.
    ///   - shotOrder: The position in the capture sequence.
    ///   - imageDescription: The image description.
    ///   - artist: The artist/author.
    ///   - bodySerial: The camera body serial number.
    public init(
        isoSpeed:         Float,
        shutterSpeed:     Float,
        aperture:         Float,
        focalLength:      Float,
        timestamp:        Date?,
        shotOrder:        Int,
        imageDescription: String,
        artist:           String,
        bodySerial:       String
    )
    {
        self.isoSpeed         = isoSpeed
        self.shutterSpeed     = shutterSpeed
        self.aperture         = aperture
        self.focalLength      = focalLength
        self.timestamp        = timestamp
        self.shotOrder        = shotOrder
        self.imageDescription = imageDescription
        self.artist           = artist
        self.bodySerial       = bodySerial
    }

    /// Creates shot information from LibRAW structures.
    ///
    /// - Parameters:
    ///   - other: The LibRAW `libraw_imgother_t` structure.
    ///   - shooting: The LibRAW `libraw_shootinginfo_t` structure.
    internal init( from other: libraw_imgother_t, shooting: libraw_shootinginfo_t )
    {
        self.init(
            isoSpeed:         other.iso_speed,
            shutterSpeed:     other.shutter,
            aperture:         other.aperture,
            focalLength:      other.focal_len,
            timestamp:        other.timestamp != 0 ? Date( timeIntervalSince1970: TimeInterval( other.timestamp ) ) : nil,
            shotOrder:        Int( other.shot_order ),
            imageDescription: String( cCharArray: other.desc ),
            artist:           String( cCharArray: other.artist ),
            bodySerial:       String( cCharArray: shooting.BodySerial )
        )
    }
}
