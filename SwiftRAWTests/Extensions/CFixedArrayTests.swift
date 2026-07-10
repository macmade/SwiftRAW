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

/// Tests for ``CFixedArray``, which reads C fixed-size arrays (imported as
/// tuples) into Swift arrays.
struct CFixedArrayTests
{
    /// A homogeneous tuple is read into a flat array, in order.
    @Test
    func valuesReadsTupleInOrder()
    {
        let tuple  = ( Float( 1 ), Float( 2 ), Float( 3 ), Float( 4 ) )
        let values = CFixedArray.values( of: tuple, as: Float.self )

        #expect( values == [ 1, 2, 3, 4 ] )
    }

    /// A nested tuple is reshaped row-major into rows and columns.
    @Test
    func matrixReshapesRowMajor()
    {
        let tuple  = ( Int32( 1 ), Int32( 2 ), Int32( 3 ), Int32( 4 ), Int32( 5 ), Int32( 6 ) )
        let matrix = CFixedArray.matrix( of: tuple, rows: 2, columns: 3, as: Int32.self )

        #expect( matrix == [ [ 1, 2, 3 ], [ 4, 5, 6 ] ] )
    }

    /// A 3×4 reshape matches the layout LibRAW uses for its color matrices.
    @Test
    func matrixThreeByFour()
    {
        let tuple = (
            Float( 0 ), Float( 1 ), Float( 2 ),  Float( 3 ),
            Float( 4 ), Float( 5 ), Float( 6 ),  Float( 7 ),
            Float( 8 ), Float( 9 ), Float( 10 ), Float( 11 )
        )

        let matrix = CFixedArray.matrix( of: tuple, rows: 3, columns: 4, as: Float.self )

        #expect( matrix == [ [ 0, 1, 2, 3 ], [ 4, 5, 6, 7 ], [ 8, 9, 10, 11 ] ] )
    }
}
