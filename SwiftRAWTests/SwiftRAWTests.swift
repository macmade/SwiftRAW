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

/// Build-system smoke tests proving that the vendored LibRAW C++ library is
/// exposed to Swift and links correctly, through both the Xcode project and the
/// Swift package. These exercise the C++ interoperability path (static methods
/// and instance construction) that the rest of SwiftRAW is built on.
struct SwiftRAWTests
{
    /// The LibRAW version string is readable through C++ interop and reports
    /// the vendored library version.
    @Test
    func libRAWVersionString() async throws
    {
        #expect( LibRAWVersion.string == "0.22.1-Release" )
    }

    /// The LibRAW version number is readable through C++ interop and matches
    /// the vendored library version (0.22.1 → `0x001601`).
    @Test
    func libRAWVersionNumber() async throws
    {
        #expect( LibRAWVersion.number == ( 0 << 16 ) | ( 22 << 8 ) | 1 )
    }

    /// A LibRAW instance can be created and destroyed from Swift, proving that
    /// the library links and a working LibRAW context can be spun up.
    @Test
    func libRAWContextCreation() async throws
    {
        #expect( LibRAWVersion.canCreateLibRAWContext() )
    }
}
