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

/// Lens identification and characteristics for a RAW capture.
///
/// Mirrors LibRAW's `libraw_lensinfo_t`: the focal/aperture range and lens
/// identity parsed from EXIF, with the maker-note (``makerNotes``) and DNG
/// (``dng``) lens substructures surfaced separately. Per-vendor lens
/// substructures are intentionally out of scope.
public struct RAWLensInfo: Sendable, Equatable
{
    /// The minimum focal length, in millimeters.
    public let minFocal: Float

    /// The maximum focal length, in millimeters.
    public let maxFocal: Float

    /// The maximum aperture (smallest f-number) at the minimum focal length.
    public let maxApertureAtMinFocal: Float

    /// The maximum aperture (smallest f-number) at the maximum focal length.
    public let maxApertureAtMaxFocal: Float

    /// The maximum aperture recorded in EXIF.
    public let exifMaxAperture: Float

    /// The lens manufacturer.
    public let lensMake: String

    /// The lens model name.
    public let lensModel: String

    /// The lens serial number.
    public let lensSerial: String

    /// The internal lens serial number.
    public let internalLensSerial: String

    /// The focal length in 35mm-equivalent millimeters.
    public let focalLengthIn35mmFormat: Int

    /// Curated lens information from the file's maker notes.
    public let makerNotes: RAWMakerNoteLensInfo

    /// Lens information from the DNG `LensInfo` tag.
    public let dng: RAWDNGLensInfo

    /// Creates lens information from explicit values.
    ///
    /// - Parameters:
    ///   - minFocal: The minimum focal length.
    ///   - maxFocal: The maximum focal length.
    ///   - maxApertureAtMinFocal: The maximum aperture at the minimum focal.
    ///   - maxApertureAtMaxFocal: The maximum aperture at the maximum focal.
    ///   - exifMaxAperture: The maximum aperture recorded in EXIF.
    ///   - lensMake: The lens manufacturer.
    ///   - lensModel: The lens model name.
    ///   - lensSerial: The lens serial number.
    ///   - internalLensSerial: The internal lens serial number.
    ///   - focalLengthIn35mmFormat: The 35mm-equivalent focal length.
    ///   - makerNotes: The maker-note lens information.
    ///   - dng: The DNG lens information.
    public init(
        minFocal:                Float,
        maxFocal:                Float,
        maxApertureAtMinFocal:   Float,
        maxApertureAtMaxFocal:   Float,
        exifMaxAperture:         Float,
        lensMake:                String,
        lensModel:               String,
        lensSerial:              String,
        internalLensSerial:      String,
        focalLengthIn35mmFormat: Int,
        makerNotes:              RAWMakerNoteLensInfo,
        dng:                     RAWDNGLensInfo
    )
    {
        self.minFocal                = minFocal
        self.maxFocal                = maxFocal
        self.maxApertureAtMinFocal   = maxApertureAtMinFocal
        self.maxApertureAtMaxFocal   = maxApertureAtMaxFocal
        self.exifMaxAperture         = exifMaxAperture
        self.lensMake                = lensMake
        self.lensModel               = lensModel
        self.lensSerial              = lensSerial
        self.internalLensSerial      = internalLensSerial
        self.focalLengthIn35mmFormat = focalLengthIn35mmFormat
        self.makerNotes              = makerNotes
        self.dng                     = dng
    }

    /// Creates lens information from a LibRAW `libraw_lensinfo_t` value.
    ///
    /// - Parameter lens: The LibRAW lens structure.
    internal init( from lens: libraw_lensinfo_t )
    {
        self.init(
            minFocal:                lens.MinFocal,
            maxFocal:                lens.MaxFocal,
            maxApertureAtMinFocal:   lens.MaxAp4MinFocal,
            maxApertureAtMaxFocal:   lens.MaxAp4MaxFocal,
            exifMaxAperture:         lens.EXIF_MaxAp,
            lensMake:                String( cCharArray: lens.LensMake ),
            lensModel:               String( cCharArray: lens.Lens ),
            lensSerial:              String( cCharArray: lens.LensSerial ),
            internalLensSerial:      String( cCharArray: lens.InternalLensSerial ),
            focalLengthIn35mmFormat: Int( lens.FocalLengthIn35mmFormat ),
            makerNotes:              RAWMakerNoteLensInfo( from: lens.makernotes ),
            dng:                     RAWDNGLensInfo( from: lens.dng )
        )
    }
}
