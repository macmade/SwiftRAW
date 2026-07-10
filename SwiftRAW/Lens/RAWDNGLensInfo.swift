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

/// Lens information carried in a DNG file's metadata.
///
/// Mirrors LibRAW's `libraw_dnglens_t`, the lens focal/aperture range recorded
/// in the DNG `LensInfo` tag.
public struct RAWDNGLensInfo: Sendable, Equatable
{
    /// The minimum focal length, in millimeters.
    public let minFocal: Float

    /// The maximum focal length, in millimeters.
    public let maxFocal: Float

    /// The maximum aperture (smallest f-number) at the minimum focal length.
    public let maxApertureAtMinFocal: Float

    /// The maximum aperture (smallest f-number) at the maximum focal length.
    public let maxApertureAtMaxFocal: Float

    /// Creates DNG lens information from explicit values.
    ///
    /// - Parameters:
    ///   - minFocal: The minimum focal length.
    ///   - maxFocal: The maximum focal length.
    ///   - maxApertureAtMinFocal: The maximum aperture at the minimum focal.
    ///   - maxApertureAtMaxFocal: The maximum aperture at the maximum focal.
    public init(
        minFocal:              Float,
        maxFocal:              Float,
        maxApertureAtMinFocal: Float,
        maxApertureAtMaxFocal: Float
    )
    {
        self.minFocal              = minFocal
        self.maxFocal              = maxFocal
        self.maxApertureAtMinFocal = maxApertureAtMinFocal
        self.maxApertureAtMaxFocal = maxApertureAtMaxFocal
    }

    /// Creates DNG lens information from a LibRAW `libraw_dnglens_t` value.
    ///
    /// - Parameter dng: The LibRAW DNG lens structure.
    internal init( from dng: libraw_dnglens_t )
    {
        self.init(
            minFocal:              dng.MinFocal,
            maxFocal:              dng.MaxFocal,
            maxApertureAtMinFocal: dng.MaxAp4MinFocal,
            maxApertureAtMaxFocal: dng.MaxAp4MaxFocal
        )
    }
}
