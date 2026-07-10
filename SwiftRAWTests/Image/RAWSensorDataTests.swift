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

/// Tests for ``RAWSensorData`` and ``RAWFile``'s raw-buffer accessors.
struct RAWSensorDataTests
{
    /// Builds a descriptor with the given layout and placeholder geometry.
    private func sensorData( _ layout: RAWSensorData.Layout ) -> RAWSensorData
    {
        RAWSensorData( width: 100, height: 50, pitch: 200, layout: layout )
    }

    /// The component count is derived from the layout.
    @Test
    func componentCounts()
    {
        #expect( self.sensorData( .none ).componentCount == 0 )
        #expect( self.sensorData( .bayer ).componentCount == 1 )
        #expect( self.sensorData( .color3 ).componentCount == 3 )
        #expect( self.sensorData( .color4 ).componentCount == 4 )
        #expect( self.sensorData( .bayerFloat ).componentCount == 1 )
        #expect( self.sensorData( .color3Float ).componentCount == 3 )
        #expect( self.sensorData( .color4Float ).componentCount == 4 )
    }

    /// Only the floating-point layouts report floating-point samples.
    @Test
    func floatingPointFlag()
    {
        #expect( self.sensorData( .bayer ).isFloatingPoint == false )
        #expect( self.sensorData( .color3 ).isFloatingPoint == false )
        #expect( self.sensorData( .color4 ).isFloatingPoint == false )
        #expect( self.sensorData( .bayerFloat ).isFloatingPoint )
        #expect( self.sensorData( .color3Float ).isFloatingPoint )
        #expect( self.sensorData( .color4Float ).isFloatingPoint )
    }

    /// Only ``RAWSensorData/Layout/none`` reports no buffer.
    @Test
    func hasBufferFlag()
    {
        #expect( self.sensorData( .none ).hasBuffer == false )
        #expect( self.sensorData( .bayer ).hasBuffer )
        #expect( self.sensorData( .color4Float ).hasBuffer )
    }

    /// For real Bayer samples, the copied buffer and the borrowed view agree,
    /// match the geometry, and carry non-trivial data. Non-Bayer layouts expose
    /// no 16-bit Bayer buffer. Runs no cases until fixtures are supplied.
    @Test( arguments: TestUtilities.rawFileURLs )
    func rawImageMatchesGeometry( url: URL ) throws
    {
        let file   = try RAWFile( url: url )
        let sensor = file.sensorData

        guard sensor.layout == .bayer
        else
        {
            #expect( file.rawImage == nil )

            return
        }

        let image = try #require( file.rawImage )

        #expect( image.isEmpty == false )
        #expect( image.count == sensor.height * ( sensor.pitch / 2 ) )
        #expect( ( image.max() ?? 0 ) > 0 )

        let viewCount = file.withRawImage
        {
            $0.count
        }

        #expect( viewCount == image.count )
    }
}
