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

/*
 * SwiftRAW-authored C++ shim (not part of the vendored LibRAW distribution).
 *
 * The C++ `LibRaw` class cannot be held as a Swift value: it is a large,
 * self-referential object whose constructor stores pointers into its own
 * members, and Swift relocates values with a bitwise move, which dangles those
 * self-pointers and crashes. This shim keeps the object on the heap and hands
 * Swift a stable pointer it never relocates, so the C++ class stays the primary
 * binding surface (lifecycle methods are called through the pointer).
 */

#ifndef SWIFTRAW_LIBRAW_H
#define SWIFTRAW_LIBRAW_H

#include <new>

#include "libraw/libraw.h"

/// Heap-allocates a `LibRaw` instance.
///
/// - Parameter flags: The LibRaw constructor flags (`LIBRAW_OPTIONS_NONE` is
///   `0`).
/// - Returns: A pointer to a newly allocated `LibRaw`, or `nullptr` if the
///   allocation failed. Ownership is transferred to the caller, which must
///   release it with `SwiftRAWDestroyLibRaw`.
static inline LibRaw * SwiftRAWCreateLibRaw( unsigned int flags )
{
    return new ( std::nothrow ) LibRaw( flags );
}

/// Destroys a `LibRaw` instance previously created with `SwiftRAWCreateLibRaw`.
///
/// - Parameter instance: The instance to destroy. Passing `nullptr` is a no-op.
static inline void SwiftRAWDestroyLibRaw( LibRaw * instance )
{
    delete instance;
}

#endif /* SWIFTRAW_LIBRAW_H */
