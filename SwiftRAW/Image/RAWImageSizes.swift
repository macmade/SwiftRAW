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

/// The geometry of a RAW image, describing the sensor layout.
///
/// Mirrors LibRAW's `libraw_image_sizes_t`. The `raw` dimensions cover the full
/// unpacked sensor buffer (including any masked/optical-black margins), while
/// the output dimensions describe the visible image after applying those
/// margins.
public struct RAWImageSizes: Sendable, Equatable
{
    /// The full sensor width, in pixels, including margins.
    public let rawWidth: Int

    /// The full sensor height, in pixels, including margins.
    public let rawHeight: Int

    /// The visible output width, in pixels.
    public let width: Int

    /// The visible output height, in pixels.
    public let height: Int

    /// The top margin (masked rows above the visible area), in pixels.
    public let topMargin: Int

    /// The left margin (masked columns left of the visible area), in pixels.
    public let leftMargin: Int

    /// The internal image width used by LibRAW, in pixels.
    public let iwidth: Int

    /// The internal image height used by LibRAW, in pixels.
    public let iheight: Int

    /// The number of bytes per row of the raw buffer.
    public let rawPitch: Int

    /// The pixel aspect ratio (non-square-pixel sensors differ from `1.0`).
    public let pixelAspect: Double

    /// The orientation flag, as reported by LibRAW (EXIF-style rotation code).
    public let flip: Int

    /// Creates image sizes from explicit values.
    ///
    /// - Parameters:
    ///   - rawWidth: The full sensor width.
    ///   - rawHeight: The full sensor height.
    ///   - width: The visible output width.
    ///   - height: The visible output height.
    ///   - topMargin: The top margin.
    ///   - leftMargin: The left margin.
    ///   - iwidth: The internal image width.
    ///   - iheight: The internal image height.
    ///   - rawPitch: The number of bytes per raw row.
    ///   - pixelAspect: The pixel aspect ratio.
    ///   - flip: The orientation flag.
    public init(
        rawWidth:    Int,
        rawHeight:   Int,
        width:       Int,
        height:      Int,
        topMargin:   Int,
        leftMargin:  Int,
        iwidth:      Int,
        iheight:     Int,
        rawPitch:    Int,
        pixelAspect: Double,
        flip:        Int
    )
    {
        self.rawWidth    = rawWidth
        self.rawHeight   = rawHeight
        self.width       = width
        self.height      = height
        self.topMargin   = topMargin
        self.leftMargin  = leftMargin
        self.iwidth      = iwidth
        self.iheight     = iheight
        self.rawPitch    = rawPitch
        self.pixelAspect = pixelAspect
        self.flip        = flip
    }

    /// Creates image sizes from a LibRAW `libraw_image_sizes_t` value.
    ///
    /// - Parameter sizes: The LibRAW image sizes structure.
    internal init( from sizes: libraw_image_sizes_t )
    {
        self.init(
            rawWidth:    Int( sizes.raw_width ),
            rawHeight:   Int( sizes.raw_height ),
            width:       Int( sizes.width ),
            height:      Int( sizes.height ),
            topMargin:   Int( sizes.top_margin ),
            leftMargin:  Int( sizes.left_margin ),
            iwidth:      Int( sizes.iwidth ),
            iheight:     Int( sizes.iheight ),
            rawPitch:    Int( sizes.raw_pitch ),
            pixelAspect: sizes.pixel_aspect,
            flip:        Int( sizes.flip )
        )
    }
}
