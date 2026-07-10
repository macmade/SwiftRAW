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

/// Helpers for reading LibRAW's fixed-size C arrays into Swift arrays.
///
/// Swift imports a C fixed-size array (e.g. `float cam_mul[4]` or
/// `float rgb_cam[3][4]`) as a homogeneous tuple. These helpers reinterpret the
/// tuple's contiguous bytes as elements of a known type, which is valid because
/// such a tuple has the same packed layout as the underlying C array.
internal enum CFixedArray
{
    /// Reads a homogeneous fixed-size C array (imported as a tuple) into a flat
    /// Swift array.
    ///
    /// - Parameters:
    ///   - tuple: The tuple value imported from a C fixed-size array.
    ///   - type: The element type of the array.
    ///
    /// - Returns: The array's elements, in order.
    static func values< Tuple, Element >( of tuple: Tuple, as type: Element.Type ) -> [ Element ]
    {
        withUnsafeBytes( of: tuple )
        {
            Array( $0.bindMemory( to: type ) )
        }
    }

    /// Reads a fixed-size two-dimensional C array (imported as a nested tuple,
    /// stored row-major) into a Swift array of rows.
    ///
    /// - Parameters:
    ///   - tuple: The nested tuple value imported from a 2-D C fixed-size array.
    ///   - rows: The number of rows.
    ///   - columns: The number of columns.
    ///   - type: The element type of the array.
    ///
    /// - Returns: A `rows`×`columns` array of the array's elements.
    static func matrix< Tuple, Element >( of tuple: Tuple, rows: Int, columns: Int, as type: Element.Type ) -> [ [ Element ] ]
    {
        let flat = self.values( of: tuple, as: type )

        return ( 0 ..< rows ).map
        {
            row in

            ( 0 ..< columns ).map
            {
                column in

                flat[ ( row * columns ) + column ]
            }
        }
    }
}
