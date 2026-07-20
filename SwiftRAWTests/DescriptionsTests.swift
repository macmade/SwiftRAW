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

@testable import SwiftRAW
import Foundation
import Testing

/// Tests for the `CustomStringConvertible` descriptions of the metadata types
/// and the rich ``RAWFile`` description.
struct DescriptionsTests
{
    /// Image sizes render as raw and output dimensions.
    @Test
    func imageSizesDescription()
    {
        let sizes = RAWImageSizes(
            rawWidth:    6960,
            rawHeight:   4640,
            width:       6888,
            height:      4546,
            topMargin:   0,
            leftMargin:  0,
            iwidth:      6888,
            iheight:     4546,
            rawPitch:    13920,
            pixelAspect: 1,
            flip:        0
        )

        #expect( sizes.description == "raw 6960×4640, output 6888×4546" )
    }

    /// The CFA pattern names its kind and channel descriptor.
    @Test
    func cfaPatternDescription()
    {
        #expect( RAWCFAPattern( filters: 0x9494_9494, colorDescription: "RGBG" ).description == "Bayer (RGBG)" )
        #expect( RAWCFAPattern( filters: 0, colorDescription: "" ).description == "no CFA" )
        #expect( RAWCFAPattern( filters: 9, colorDescription: "RGBG" ).description == "X-Trans (RGBG)" )
    }

    /// Exposure renders sub-second shutter speeds as fractions and drops
    /// unrecorded values.
    @Test
    func shotInfoDescription()
    {
        let shot = RAWShotInfo(
            isoSpeed:         100,
            shutterSpeed:     0.004,
            aperture:         2.8,
            focalLength:      50,
            timestamp:        nil,
            shotOrder:        0,
            imageDescription: "",
            artist:           "",
            bodySerial:       ""
        )

        #expect( shot.description == "ISO 100, 1/250s, f/2.8, 50mm" )

        let empty = RAWShotInfo(
            isoSpeed:         0,
            shutterSpeed:     0,
            aperture:         0,
            focalLength:      0,
            timestamp:        nil,
            shotOrder:        0,
            imageDescription: "",
            artist:           "",
            bodySerial:       ""
        )

        #expect( empty.description == "no exposure data" )
    }

    /// Non-finite or oversized exposure values (from corrupt input) render
    /// without trapping.
    @Test
    func shotInfoDescriptionToleratesExtremeValues()
    {
        let extreme = RAWShotInfo(
            isoSpeed:         .infinity,
            shutterSpeed:     .leastNonzeroMagnitude,
            aperture:         .nan,
            focalLength:      50,
            timestamp:        nil,
            shotOrder:        0,
            imageDescription: "",
            artist:           "",
            bodySerial:       ""
        )

        #expect( extreme.description.isEmpty == false )
    }

    /// Lens descriptions collapse a prime to a single focal length and keep a
    /// zoom's range.
    @Test
    func lensDescription()
    {
        #expect( RAWDNGLensInfo( minFocal: 24, maxFocal: 70, maxApertureAtMinFocal: 2.8, maxApertureAtMaxFocal: 2.8 ).description == "24–70mm" )
        #expect( RAWDNGLensInfo( minFocal: 50, maxFocal: 50, maxApertureAtMinFocal: 1.8, maxApertureAtMaxFocal: 1.8 ).description == "50mm" )
    }

    /// Sensor data renders its geometry, layout, and component count.
    @Test
    func sensorDataDescription()
    {
        #expect( RAWSensorData( width: 100, height: 50, pitch: 200, layout: .bayer ).description == "100×50 Bayer (1 component)" )
        #expect( RAWSensorData( width: 100, height: 50, pitch: 200, layout: .color3 ).description == "100×50 3-channel (3 components)" )
    }

    /// Parsing options render their unpack mode.
    @Test
    func parsingOptionsDescription()
    {
        #expect( RAWParsingOptions( unpacksImmediately: true ).description == "eager unpack" )
        #expect( RAWParsingOptions( unpacksImmediately: false ).description == "lazy unpack" )
    }

    /// The rich file description is non-empty and includes the sensor
    /// dimensions for real samples.
    @Test( arguments: TestUtilities.rawFileURLs )
    func fileDescriptionIsRich( url: URL ) throws
    {
        let file = try RAWFile( url: url )

        #expect( file.description.isEmpty == false )
        #expect( file.description.contains( "×" ) )
    }

    /// `hasTestFiles` is consistent with the discovered fixtures, whether or not
    /// any are present.
    @Test
    func fixtureDiscoveryIsConsistent()
    {
        #expect( TestUtilities.hasTestFiles == ( TestUtilities.rawFileURLs.isEmpty == false ) )
    }
}
