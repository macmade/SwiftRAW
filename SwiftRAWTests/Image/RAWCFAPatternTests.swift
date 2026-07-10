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
import Testing

/// Tests for ``RAWCFAPattern`` color lookups.
struct RAWCFAPatternTests
{
    /// The standard RGGB Bayer mosaic, packed as LibRAW encodes it, resolves to
    /// the expected per-pixel colors and channels across the repeating 2×2 cell.
    ///
    /// `0x94949494` with the `"RGBG"` descriptor is LibRAW's canonical RGGB
    /// layout: R at (0,0), G at (0,1) and (1,0), B at (1,1).
    @Test
    func bayerRGGB()
    {
        let pattern = RAWCFAPattern( filters: 0x9494_9494, colorDescription: "RGBG" )

        #expect( pattern.kind == .bayer )

        #expect( pattern.color( atRow: 0, column: 0 ) == 0 )
        #expect( pattern.color( atRow: 0, column: 1 ) == 1 )
        #expect( pattern.color( atRow: 1, column: 0 ) == 1 )
        #expect( pattern.color( atRow: 1, column: 1 ) == 2 )

        #expect( pattern.channel( atRow: 0, column: 0 ) == "R" )
        #expect( pattern.channel( atRow: 0, column: 1 ) == "G" )
        #expect( pattern.channel( atRow: 1, column: 0 ) == "G" )
        #expect( pattern.channel( atRow: 1, column: 1 ) == "B" )
    }

    /// The Bayer pattern repeats every two pixels in each direction.
    @Test
    func bayerIsPeriodic()
    {
        let pattern = RAWCFAPattern( filters: 0x9494_9494, colorDescription: "RGBG" )

        #expect( pattern.color( atRow: 0, column: 0 ) == pattern.color( atRow: 2, column: 2 ) )
        #expect( pattern.color( atRow: 1, column: 1 ) == pattern.color( atRow: 3, column: 3 ) )
    }

    /// A `filters` value of `0` is a sensor without a CFA: every pixel reports
    /// the full-color index and has no single channel.
    @Test
    func noColorFilterArray()
    {
        let pattern = RAWCFAPattern( filters: 0, colorDescription: "" )

        #expect( pattern.kind == .none )
        #expect( pattern.color( atRow: 3, column: 7 ) == RAWCFAPattern.fullColorIndex )
        #expect( pattern.channel( atRow: 3, column: 7 ) == nil )
    }

    /// A `filters` value of `9` is X-Trans and looks up the 6×6 grid, wrapping
    /// with the sensor's period.
    @Test
    func xTransUsesGrid()
    {
        let grid =
        [
            [ 1, 1, 0, 1, 1, 2 ],
            [ 1, 1, 2, 1, 1, 0 ],
            [ 2, 0, 1, 0, 2, 1 ],
            [ 1, 1, 2, 1, 1, 0 ],
            [ 1, 1, 0, 1, 1, 2 ],
            [ 0, 2, 1, 2, 0, 1 ],
        ]

        let pattern = RAWCFAPattern( filters: 9, colorDescription: "RGBG", xTransPattern: grid )

        #expect( pattern.kind == .xTrans )
        #expect( pattern.color( atRow: 0, column: 2 ) == 0 )
        #expect( pattern.color( atRow: 2, column: 0 ) == 2 )
        #expect( pattern.color( atRow: 6, column: 8 ) == grid[ 0 ][ 2 ] ) // wraps to (0,2)
    }
}
