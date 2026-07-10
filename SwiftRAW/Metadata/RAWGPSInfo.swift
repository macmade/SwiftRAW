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

/// The GPS location recorded with a RAW file.
///
/// Mirrors LibRAW's `libraw_gps_info_t`. LibRAW stores coordinates as
/// degrees/minutes/seconds with separate hemisphere references; this type
/// resolves them into signed decimal degrees (negative for south/west) and a
/// signed altitude (negative below sea level), while still exposing the raw
/// reference markers.
public struct RAWGPSInfo: Sendable, Equatable, CustomStringConvertible
{
    /// A compact summary of the coordinates, `latitude, longitude, altitude`.
    public var description: String
    {
        "\( self.latitude ), \( self.longitude ), \( self.altitude.compactDescription )m"
    }

    /// The latitude in signed decimal degrees (negative for the southern
    /// hemisphere).
    public let latitude: Double

    /// The longitude in signed decimal degrees (negative for the western
    /// hemisphere).
    public let longitude: Double

    /// The altitude in meters (negative below sea level).
    public let altitude: Double

    /// The latitude hemisphere reference (`"N"` or `"S"`), if present.
    public let latitudeRef: Character?

    /// The longitude hemisphere reference (`"E"` or `"W"`), if present.
    public let longitudeRef: Character?

    /// The altitude reference: `0` above sea level, `1` below.
    public let altitudeRef: Int

    /// Creates GPS information from explicit values.
    ///
    /// - Parameters:
    ///   - latitude: The latitude in signed decimal degrees.
    ///   - longitude: The longitude in signed decimal degrees.
    ///   - altitude: The altitude in meters.
    ///   - latitudeRef: The latitude hemisphere reference.
    ///   - longitudeRef: The longitude hemisphere reference.
    ///   - altitudeRef: The altitude reference (`0` or `1`).
    public init(
        latitude:     Double,
        longitude:    Double,
        altitude:     Double,
        latitudeRef:  Character?,
        longitudeRef: Character?,
        altitudeRef:  Int
    )
    {
        self.latitude     = latitude
        self.longitude    = longitude
        self.altitude     = altitude
        self.latitudeRef  = latitudeRef
        self.longitudeRef = longitudeRef
        self.altitudeRef  = altitudeRef
    }

    /// Creates GPS information from a LibRAW `libraw_gps_info_t` value.
    ///
    /// - Parameter gps: The LibRAW GPS structure.
    ///
    /// - Returns: `nil` if the file carries no parsed GPS data.
    internal init?( from gps: libraw_gps_info_t )
    {
        guard gps.gpsparsed != 0
        else
        {
            return nil
        }

        let latitude     = CFixedArray.values( of: gps.latitude, as: Float.self )
        let longitude    = CFixedArray.values( of: gps.longitude, as: Float.self )
        let latitudeRef  = RAWGPSInfo.character( from: gps.latref )
        let longitudeRef = RAWGPSInfo.character( from: gps.longref )

        self.init(
            latitude:     RAWGPSInfo.decimalDegrees( latitude, isNegative: latitudeRef == "S" ),
            longitude:    RAWGPSInfo.decimalDegrees( longitude, isNegative: longitudeRef == "W" ),
            altitude:     gps.altref == 1 ? -Double( gps.altitude ) : Double( gps.altitude ),
            latitudeRef:  latitudeRef,
            longitudeRef: longitudeRef,
            altitudeRef:  Int( gps.altref )
        )
    }

    /// Converts a degrees/minutes/seconds triple to signed decimal degrees.
    ///
    /// - Parameters:
    ///   - dms: A `[degrees, minutes, seconds]` triple. Missing components are
    ///     treated as zero.
    ///   - isNegative: Whether the coordinate is in the southern/western
    ///     hemisphere and should be negated.
    ///
    /// - Returns: The coordinate in signed decimal degrees.
    internal static func decimalDegrees( _ dms: [ Float ], isNegative: Bool ) -> Double
    {
        let degrees = dms.count > 0 ? Double( dms[ 0 ] ) : 0
        let minutes = dms.count > 1 ? Double( dms[ 1 ] ) : 0
        let seconds = dms.count > 2 ? Double( dms[ 2 ] ) : 0
        let value   = degrees + ( minutes / 60.0 ) + ( seconds / 3600.0 )

        return isNegative ? -value : value
    }

    /// Converts a LibRAW reference byte to a printable character.
    ///
    /// - Parameter byte: A `CChar` reference marker (e.g. `latref`).
    ///
    /// - Returns: The character, or `nil` if the byte is empty or non-printing.
    private static func character( from byte: CChar ) -> Character?
    {
        guard byte > 0
        else
        {
            return nil
        }

        return Character( UnicodeScalar( UInt8( byte ) ) )
    }
}
