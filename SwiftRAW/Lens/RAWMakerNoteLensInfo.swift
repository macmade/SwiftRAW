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

/// A curated, cross-vendor subset of the lens information found in a file's
/// maker notes.
///
/// Mirrors the broadly useful fields of LibRAW's `libraw_makernotes_lens_t`.
/// Camera-specific fields (mount/format codes, accessory IDs, per-vendor lens
/// substructures) are intentionally out of scope.
public struct RAWMakerNoteLensInfo: Sendable, Equatable, CustomStringConvertible
{
    /// A compact summary of the lens name and focal range.
    public var description: String
    {
        let range = self.minFocal == self.maxFocal
            ? "\( self.minFocal.compactDescription )mm"
            : "\( self.minFocal.compactDescription )–\( self.maxFocal.compactDescription )mm"

        return self.lensModel.isEmpty ? range : "\( self.lensModel ) (\( range ))"
    }

    /// Whether a lens has a fixed or variable focal length.
    public enum FocalType: Sendable, Equatable
    {
        /// The focal type is unknown.
        case unknown

        /// A fixed-focal-length (prime) lens.
        case fixed

        /// A variable-focal-length (zoom) lens.
        case zoom

        /// Creates a focal type from LibRAW's `FocalType` code.
        ///
        /// - Parameter rawValue: `1` is fixed, `2` is zoom, anything else
        ///   (including `-1` and `0`) is unknown.
        internal init( rawValue: Int )
        {
            switch rawValue
            {
                case 1:  self = .fixed
                case 2:  self = .zoom
                default: self = .unknown
            }
        }
    }

    /// The LibRAW lens identifier.
    public let lensID: UInt64

    /// The lens name recorded in the maker notes.
    public let lensModel: String

    /// Whether the lens is a prime or a zoom.
    public let focalType: FocalType

    /// The minimum focal length, in millimeters.
    public let minFocal: Float

    /// The maximum focal length, in millimeters.
    public let maxFocal: Float

    /// The maximum aperture (smallest f-number) at the minimum focal length.
    public let maxApertureAtMinFocal: Float

    /// The maximum aperture (smallest f-number) at the maximum focal length.
    public let maxApertureAtMaxFocal: Float

    /// The widest maximum aperture (smallest f-number) of the lens.
    public let maxAperture: Float

    /// The smallest minimum aperture (largest f-number) of the lens.
    public let minAperture: Float

    /// The focal length in 35mm-equivalent millimeters.
    public let focalLengthIn35mmFormat: Float

    /// The aperture range of the lens, in f-stops.
    public let lensFStops: Float

    /// The minimum focus distance, in meters.
    public let minFocusDistance: Float

    /// Creates maker-note lens information from explicit values.
    ///
    /// - Parameters:
    ///   - lensID: The LibRAW lens identifier.
    ///   - lensModel: The lens name.
    ///   - focalType: Whether the lens is a prime or a zoom.
    ///   - minFocal: The minimum focal length.
    ///   - maxFocal: The maximum focal length.
    ///   - maxApertureAtMinFocal: The maximum aperture at the minimum focal.
    ///   - maxApertureAtMaxFocal: The maximum aperture at the maximum focal.
    ///   - maxAperture: The widest maximum aperture.
    ///   - minAperture: The smallest minimum aperture.
    ///   - focalLengthIn35mmFormat: The 35mm-equivalent focal length.
    ///   - lensFStops: The aperture range in f-stops.
    ///   - minFocusDistance: The minimum focus distance.
    public init(
        lensID:                  UInt64,
        lensModel:               String,
        focalType:               FocalType,
        minFocal:                Float,
        maxFocal:                Float,
        maxApertureAtMinFocal:   Float,
        maxApertureAtMaxFocal:   Float,
        maxAperture:             Float,
        minAperture:             Float,
        focalLengthIn35mmFormat: Float,
        lensFStops:              Float,
        minFocusDistance:        Float
    )
    {
        self.lensID                  = lensID
        self.lensModel               = lensModel
        self.focalType               = focalType
        self.minFocal                = minFocal
        self.maxFocal                = maxFocal
        self.maxApertureAtMinFocal   = maxApertureAtMinFocal
        self.maxApertureAtMaxFocal   = maxApertureAtMaxFocal
        self.maxAperture             = maxAperture
        self.minAperture             = minAperture
        self.focalLengthIn35mmFormat = focalLengthIn35mmFormat
        self.lensFStops              = lensFStops
        self.minFocusDistance        = minFocusDistance
    }

    /// Creates maker-note lens information from a LibRAW
    /// `libraw_makernotes_lens_t` value.
    ///
    /// - Parameter makerNotes: The LibRAW maker-note lens structure.
    internal init( from makerNotes: libraw_makernotes_lens_t )
    {
        self.init(
            lensID:                  makerNotes.LensID,
            lensModel:               String( cCharArray: makerNotes.Lens ),
            focalType:               FocalType( rawValue: Int( makerNotes.FocalType ) ),
            minFocal:                makerNotes.MinFocal,
            maxFocal:                makerNotes.MaxFocal,
            maxApertureAtMinFocal:   makerNotes.MaxAp4MinFocal,
            maxApertureAtMaxFocal:   makerNotes.MaxAp4MaxFocal,
            maxAperture:             makerNotes.MaxAp,
            minAperture:             makerNotes.MinAp,
            focalLengthIn35mmFormat: makerNotes.FocalLengthIn35mmFormat,
            lensFStops:              makerNotes.LensFStops,
            minFocusDistance:        makerNotes.MinFocusDistance
        )
    }
}
