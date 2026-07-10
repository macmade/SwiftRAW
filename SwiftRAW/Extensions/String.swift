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

extension String
{
    /// Creates a string from a fixed-size C `char` array value.
    ///
    /// LibRAW exposes many text fields as fixed C arrays (e.g. `char make[64]`),
    /// which Swift imports as homogeneous tuples of `CChar`. This reads the
    /// tuple's bytes up to the first `NUL`, so it is safe even if the array is
    /// not `NUL`-terminated, and decodes the result as UTF-8.
    ///
    /// - Parameter cCharArray: A tuple of `CChar` values, as imported from a C
    ///   fixed-size `char` array.
    init< T >( cCharArray: T )
    {
        self = withUnsafeBytes( of: cCharArray )
        {
            buffer in

            let bytes = buffer.prefix
            {
                $0 != 0
            }

            return String( decoding: bytes, as: UTF8.self )
        }
    }
}
