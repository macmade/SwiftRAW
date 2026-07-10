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

/// Identifying information about the underlying LibRAW library that SwiftRAW
/// wraps.
///
/// This is a thin, read-only accessor over LibRAW's version entry points. It
/// lets consumers report or assert on the exact LibRAW build in use, and it
/// doubles as the earliest proof that the C++ `LibRaw` class is correctly
/// exposed to Swift through C++ interoperability: the values below are read
/// through the C++ class' static members rather than the flat C API.
public enum LibRAWVersion
{
    /// The LibRAW version string, for example `"0.22.1-Release"`.
    ///
    /// Read from the C++ `LibRaw::version()` static method.
    public static var string: String
    {
        guard let version = LibRaw.version()
        else
        {
            return ""
        }

        return String( cString: version )
    }

    /// The LibRAW version encoded as a single integer, computed as
    /// `(major << 16) | (minor << 8) | patch`.
    ///
    /// Read from the C++ `LibRaw::versionNumber()` static method.
    public static var number: Int
    {
        Int( LibRaw.versionNumber() )
    }

    /// Creates and immediately releases a LibRAW instance to prove that a
    /// working LibRAW context can be spun up and torn down from Swift, and that
    /// the library links correctly.
    ///
    /// The instance is created through the flat C entry points
    /// (`libraw_init` / `libraw_close`), which heap-allocate and free the
    /// underlying `LibRaw` object. The C++ `LibRaw` class cannot be held
    /// directly as a Swift value: it is a large, self-referential object whose
    /// constructor stores pointers into its own members, and Swift's value
    /// semantics relocate such a value with a bitwise move, dangling those
    /// self-pointers and crashing on destruction. The C entry points sidestep
    /// this by keeping the object on the heap, which is the fallback the plan
    /// reserves for spots where the C++ class is awkward to use from Swift.
    ///
    /// This exists to smoke-test the interoperability path that the rest of
    /// SwiftRAW relies on; it is not part of the public API.
    ///
    /// - Returns: `true` if a LibRAW context was created and released.
    static func canCreateLibRAWContext() -> Bool
    {
        // `0` is `LIBRAW_OPTIONS_NONE`, the default constructor flags.
        guard let context = libraw_init( 0 )
        else
        {
            return false
        }

        libraw_close( context )

        return true
    }
}
