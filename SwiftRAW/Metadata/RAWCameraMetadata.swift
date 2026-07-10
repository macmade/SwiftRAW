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

/// Camera-common metadata drawn from a file's maker notes.
///
/// Mirrors the cross-vendor fields of LibRAW's `libraw_metadata_common_t`:
/// flash output, environmental temperatures, color space, firmware, and
/// sensitivity. Per-vendor maker-note structures and camera-specific
/// autofocus data blobs are intentionally out of scope.
public struct RAWCameraMetadata: Sendable, Equatable
{
    /// The flash exposure compensation applied, in stops.
    public let flashExposureCompensation: Float

    /// The flash guide number.
    public let flashGuideNumber: Float

    /// The camera body temperature, in degrees Celsius.
    public let cameraTemperature: Float

    /// The sensor temperature, in degrees Celsius.
    public let sensorTemperature: Float

    /// The lens temperature, in degrees Celsius.
    public let lensTemperature: Float

    /// The ambient temperature, in degrees Celsius.
    public let ambientTemperature: Float

    /// The battery temperature, in degrees Celsius.
    public let batteryTemperature: Float

    /// The color space code recorded by the camera.
    public let colorSpace: Int

    /// The camera firmware version string.
    public let firmware: String

    /// The real (measured) ISO sensitivity.
    public let realISO: Float

    /// The EXIF exposure index.
    public let exposureIndex: Float

    /// Creates camera metadata from explicit values.
    ///
    /// - Parameters:
    ///   - flashExposureCompensation: The flash exposure compensation, in stops.
    ///   - flashGuideNumber: The flash guide number.
    ///   - cameraTemperature: The camera body temperature.
    ///   - sensorTemperature: The sensor temperature.
    ///   - lensTemperature: The lens temperature.
    ///   - ambientTemperature: The ambient temperature.
    ///   - batteryTemperature: The battery temperature.
    ///   - colorSpace: The color space code.
    ///   - firmware: The firmware version string.
    ///   - realISO: The real ISO sensitivity.
    ///   - exposureIndex: The EXIF exposure index.
    public init(
        flashExposureCompensation: Float,
        flashGuideNumber:          Float,
        cameraTemperature:         Float,
        sensorTemperature:         Float,
        lensTemperature:           Float,
        ambientTemperature:        Float,
        batteryTemperature:        Float,
        colorSpace:                Int,
        firmware:                  String,
        realISO:                   Float,
        exposureIndex:             Float
    )
    {
        self.flashExposureCompensation = flashExposureCompensation
        self.flashGuideNumber          = flashGuideNumber
        self.cameraTemperature         = cameraTemperature
        self.sensorTemperature         = sensorTemperature
        self.lensTemperature           = lensTemperature
        self.ambientTemperature        = ambientTemperature
        self.batteryTemperature        = batteryTemperature
        self.colorSpace                = colorSpace
        self.firmware                  = firmware
        self.realISO                   = realISO
        self.exposureIndex             = exposureIndex
    }

    /// Creates camera metadata from a LibRAW `libraw_metadata_common_t` value.
    ///
    /// - Parameter common: The LibRAW common metadata structure.
    internal init( from common: libraw_metadata_common_t )
    {
        self.init(
            flashExposureCompensation: common.FlashEC,
            flashGuideNumber:          common.FlashGN,
            cameraTemperature:         common.CameraTemperature,
            sensorTemperature:         common.SensorTemperature,
            lensTemperature:           common.LensTemperature,
            ambientTemperature:        common.AmbientTemperature,
            batteryTemperature:        common.BatteryTemperature,
            colorSpace:                Int( common.ColorSpace ),
            firmware:                  String( cCharArray: common.firmware ),
            realISO:                   common.real_ISO,
            exposureIndex:             common.exifExposureIndex
        )
    }
}
