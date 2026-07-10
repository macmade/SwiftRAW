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

/// Options controlling how a ``RAWFile`` is parsed.
///
/// The read-only scope keeps this intentionally small; it currently only
/// governs when the RAW data is unpacked.
public struct RAWParsingOptions: Sendable, Equatable
{
    /// Whether the RAW data is unpacked as soon as the file is opened.
    ///
    /// When `true` (the default), ``RAWFile`` unpacks eagerly during
    /// initialization, so any open error and any unpack error surface up front.
    /// When `false`, unpacking is deferred: call ``RAWFile/unpack()`` (or access
    /// data that requires it) to unpack on demand.
    public var unpacksImmediately: Bool

    /// The default options: eager unpacking.
    public static let `default` = RAWParsingOptions()

    /// Creates a set of parsing options.
    ///
    /// - Parameter unpacksImmediately: Whether to unpack the RAW data as soon as
    ///   the file is opened. Defaults to `true`.
    public init( unpacksImmediately: Bool = true )
    {
        self.unpacksImmediately = unpacksImmediately
    }
}
