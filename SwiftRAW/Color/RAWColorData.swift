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

/// Color calibration data used to interpret a RAW file's samples.
///
/// Mirrors the commonly used fields of LibRAW's `libraw_colordata_t`: the black
/// and saturation levels that bound the sample range, the white-balance
/// multipliers, and the color-conversion matrices. The full per-block black
/// map, tone curve, and per-vendor color tables are beyond this curated scope.
public struct RAWColorData: Sendable, Equatable, CustomStringConvertible
{
    /// A compact summary of the black and saturation levels.
    public var description: String
    {
        let profile = self.hasEmbeddedColorProfile ? ", ICC profile" : ""

        return "black \( self.blackLevel ), max \( self.maximum )\( profile )"
    }

    /// The global black level subtracted from raw samples.
    public let blackLevel: Int

    /// The per-channel black-level adjustments (up to four channels).
    public let channelBlackLevels: [ Int ]

    /// The saturation (white) level of the raw samples.
    public let maximum: Int

    /// The maximum sample value actually observed in the data.
    public let dataMaximum: Int

    /// The camera white-balance multipliers (`cam_mul`), one per channel.
    public let cameraMultipliers: [ Float ]

    /// The pre-multipliers (`pre_mul`) LibRAW would apply, one per channel.
    public let preMultipliers: [ Float ]

    /// The camera-to-sRGB conversion matrix (`rgb_cam`), 3×4.
    public let rgbCamera: [ [ Float ] ]

    /// The camera-to-XYZ conversion matrix (`cam_xyz`), 4×3.
    public let cameraXYZ: [ [ Float ] ]

    /// The embedded color matrix (`cmatrix`), 3×4.
    public let colorMatrix: [ [ Float ] ]

    /// Whether the file embeds an ICC color profile.
    public let hasEmbeddedColorProfile: Bool

    /// The length in bytes of the embedded color profile, or `0` if none.
    public let colorProfileLength: Int

    /// Creates color data from explicit values.
    ///
    /// - Parameters:
    ///   - blackLevel: The global black level.
    ///   - channelBlackLevels: The per-channel black-level adjustments.
    ///   - maximum: The saturation level.
    ///   - dataMaximum: The maximum observed sample value.
    ///   - cameraMultipliers: The camera white-balance multipliers.
    ///   - preMultipliers: The pre-multipliers.
    ///   - rgbCamera: The camera-to-sRGB matrix.
    ///   - cameraXYZ: The camera-to-XYZ matrix.
    ///   - colorMatrix: The embedded color matrix.
    ///   - hasEmbeddedColorProfile: Whether an ICC profile is embedded.
    ///   - colorProfileLength: The embedded profile length in bytes.
    public init(
        blackLevel:              Int,
        channelBlackLevels:      [ Int ],
        maximum:                 Int,
        dataMaximum:             Int,
        cameraMultipliers:       [ Float ],
        preMultipliers:          [ Float ],
        rgbCamera:               [ [ Float ] ],
        cameraXYZ:               [ [ Float ] ],
        colorMatrix:             [ [ Float ] ],
        hasEmbeddedColorProfile: Bool,
        colorProfileLength:      Int
    )
    {
        self.blackLevel              = blackLevel
        self.channelBlackLevels      = channelBlackLevels
        self.maximum                 = maximum
        self.dataMaximum             = dataMaximum
        self.cameraMultipliers       = cameraMultipliers
        self.preMultipliers          = preMultipliers
        self.rgbCamera               = rgbCamera
        self.cameraXYZ               = cameraXYZ
        self.colorMatrix             = colorMatrix
        self.hasEmbeddedColorProfile = hasEmbeddedColorProfile
        self.colorProfileLength      = colorProfileLength
    }

    /// Creates color data from a LibRAW `libraw_colordata_t` value.
    ///
    /// Read through a pointer rather than by value: `libraw_colordata_t` embeds
    /// a large tone curve and per-vendor tables, so copying the whole structure
    /// for each access would be wasteful.
    ///
    /// - Parameter color: A pointer to the LibRAW color structure.
    internal init( from color: UnsafePointer< libraw_colordata_t > )
    {
        let channelBlack: [ Int ]

        if let cblack = SwiftRAWColorDataChannelBlackLevels( color )
        {
            channelBlack = ( 0 ..< 4 ).map
            {
                Int( cblack[ $0 ] )
            }
        }
        else
        {
            channelBlack = []
        }

        self.init(
            blackLevel:              Int( color.pointee.black ),
            channelBlackLevels:      channelBlack,
            maximum:                 Int( color.pointee.maximum ),
            dataMaximum:             Int( color.pointee.data_maximum ),
            cameraMultipliers:       CFixedArray.values( of: color.pointee.cam_mul, as: Float.self ),
            preMultipliers:          CFixedArray.values( of: color.pointee.pre_mul, as: Float.self ),
            rgbCamera:               CFixedArray.matrix( of: color.pointee.rgb_cam, rows: 3, columns: 4, as: Float.self ),
            cameraXYZ:               CFixedArray.matrix( of: color.pointee.cam_xyz, rows: 4, columns: 3, as: Float.self ),
            colorMatrix:             CFixedArray.matrix( of: color.pointee.cmatrix, rows: 3, columns: 4, as: Float.self ),
            hasEmbeddedColorProfile: color.pointee.profile != nil && color.pointee.profile_length > 0,
            colorProfileLength:      Int( color.pointee.profile_length )
        )
    }
}
