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

/// Tests for ``RAWGPSInfo`` coordinate conversion, plus graceful handling of
/// files without GPS.
struct RAWGPSInfoTests
{
    /// A northern-hemisphere DMS triple converts to positive decimal degrees.
    @Test
    func decimalDegreesNorth()
    {
        let value = RAWGPSInfo.decimalDegrees( [ 48, 51, 30 ], isNegative: false )

        #expect( abs( value - 48.858_333 ) < 0.000_1 )
    }

    /// A southern/western coordinate is negated.
    @Test
    func decimalDegreesNegative()
    {
        let value = RAWGPSInfo.decimalDegrees( [ 33, 51, 54 ], isNegative: true )

        #expect( value < 0 )
        #expect( abs( value - -33.865 ) < 0.001 )
    }

    /// Missing DMS components are treated as zero rather than crashing.
    @Test
    func decimalDegreesHandlesShortInput()
    {
        #expect( RAWGPSInfo.decimalDegrees( [ 10 ], isNegative: false ) == 10 )
        #expect( RAWGPSInfo.decimalDegrees( [], isNegative: false ) == 0 )
    }

    /// Reading GPS from a file never crashes and is `nil` when absent. Runs no
    /// cases until fixtures are supplied.
    @Test( arguments: TestUtilities.rawFileURLs )
    func gpsInfoIsSafeToRead( url: URL ) throws
    {
        let file = try RAWFile( url: url )

        if let gps = file.gpsInfo
        {
            #expect( gps.latitude >= -90 && gps.latitude <= 90 )
            #expect( gps.longitude >= -180 && gps.longitude <= 180 )
        }
    }
}
