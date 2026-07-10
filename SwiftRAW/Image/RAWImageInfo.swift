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

/// Camera identification and sensor-description metadata for a RAW image.
///
/// Mirrors LibRAW's `libraw_iparams_t`. Alongside the human-readable camera
/// make and model, LibRAW also provides normalized identifiers (stable strings
/// LibRAW derives across firmware/marketing variations) and the color-filter
/// description used to interpret the raw samples.
public struct RAWImageInfo: Sendable, Equatable, CustomStringConvertible
{
    /// A compact summary of the camera and color-filter description.
    public var description: String
    {
        let camera = "\( self.make ) \( self.model )".trimmingCharacters( in: .whitespaces )
        let name   = camera.isEmpty ? "Unknown camera" : camera

        return "\( name ) — \( self.colors ) colors (\( self.colorDescription ))"
    }

    /// The camera manufacturer, as recorded in the file.
    public let make: String

    /// The camera model, as recorded in the file.
    public let model: String

    /// The creating software, as recorded in the file.
    public let software: String

    /// The manufacturer, normalized by LibRAW to a canonical spelling.
    public let normalizedMake: String

    /// The model, normalized by LibRAW to a canonical spelling.
    public let normalizedModel: String

    /// The number of colors in the color-filter array (e.g. `3` or `4`).
    public let colors: Int

    /// The packed color-filter-array pattern, as encoded by LibRAW.
    ///
    /// See ``RAWCFAPattern`` for a structured interpretation of this value.
    public let filters: UInt32

    /// The color descriptor mapping color indices to channel letters (e.g.
    /// `"RGBG"`).
    public let colorDescription: String

    /// The number of raw images stored in the file.
    public let rawCount: Int

    /// The DNG version, or `0` if the file is not a DNG.
    public let dngVersion: Int

    /// Whether the sensor is a Foveon (layered) sensor, which has no
    /// color-filter array.
    public let isFoveon: Bool

    /// Creates image information from explicit values.
    ///
    /// - Parameters:
    ///   - make: The camera manufacturer.
    ///   - model: The camera model.
    ///   - software: The creating software.
    ///   - normalizedMake: The normalized manufacturer.
    ///   - normalizedModel: The normalized model.
    ///   - colors: The number of colors in the color-filter array.
    ///   - filters: The packed color-filter-array pattern.
    ///   - colorDescription: The color descriptor.
    ///   - rawCount: The number of raw images in the file.
    ///   - dngVersion: The DNG version, or `0`.
    ///   - isFoveon: Whether the sensor is a Foveon sensor.
    public init(
        make:             String,
        model:            String,
        software:         String,
        normalizedMake:   String,
        normalizedModel:  String,
        colors:           Int,
        filters:          UInt32,
        colorDescription: String,
        rawCount:         Int,
        dngVersion:       Int,
        isFoveon:         Bool
    )
    {
        self.make             = make
        self.model            = model
        self.software         = software
        self.normalizedMake   = normalizedMake
        self.normalizedModel  = normalizedModel
        self.colors           = colors
        self.filters          = filters
        self.colorDescription = colorDescription
        self.rawCount         = rawCount
        self.dngVersion       = dngVersion
        self.isFoveon         = isFoveon
    }

    /// Creates image information from a LibRAW `libraw_iparams_t` value.
    ///
    /// - Parameter idata: The LibRAW identification structure.
    internal init( from idata: libraw_iparams_t )
    {
        self.init(
            make:             String( cCharArray: idata.make ),
            model:            String( cCharArray: idata.model ),
            software:         String( cCharArray: idata.software ),
            normalizedMake:   String( cCharArray: idata.normalized_make ),
            normalizedModel:  String( cCharArray: idata.normalized_model ),
            colors:           Int( idata.colors ),
            filters:          idata.filters,
            colorDescription: String( cCharArray: idata.cdesc ),
            rawCount:         Int( idata.raw_count ),
            dngVersion:       Int( idata.dng_version ),
            isFoveon:         idata.is_foveon != 0
        )
    }
}
