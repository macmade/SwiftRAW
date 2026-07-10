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

import Foundation

/// An error raised while reading a RAW file.
///
/// Errors originating in LibRAW carry the raw LibRAW status code and its
/// human-readable message (as returned by `libraw_strerror`), so callers can
/// inspect the exact failure. Every case renders through a `"RAW Error: …"`
/// description.
public enum RAWError: LocalizedError, CustomStringConvertible, Sendable
{
    /// The provided URL is not a file URL.
    case invalidFileURL( URL )

    /// The file at the provided URL does not exist or is not readable.
    case cannotReadFile( URL )

    /// LibRAW failed to open the RAW input.
    ///
    /// - Parameters:
    ///   - code: The LibRAW status code.
    ///   - message: The LibRAW error message for the code.
    case openFailed( code: Int32, message: String )

    /// LibRAW failed to unpack the RAW data.
    ///
    /// - Parameters:
    ///   - code: The LibRAW status code.
    ///   - message: The LibRAW error message for the code.
    case unpackFailed( code: Int32, message: String )

    /// The input is not a RAW format supported by LibRAW.
    case unsupportedFormat

    /// A LibRAW operation failed with a status code not covered by a more
    /// specific case.
    ///
    /// - Parameters:
    ///   - code: The LibRAW status code.
    ///   - message: The LibRAW error message for the code.
    case libRAWError( code: Int32, message: String )

    /// A textual representation of the error, prefixed with `"RAW Error: "`.
    public var description: String
    {
        switch self
        {
            case .invalidFileURL( let url ):

                return "RAW Error: Invalid file URL: \( url.absoluteString )"

            case .cannotReadFile( let url ):

                return "RAW Error: Cannot read file: \( url.absoluteString )"

            case .openFailed( let code, let message ):

                return "RAW Error: Failed to open the RAW file (\( code )): \( message )"

            case .unpackFailed( let code, let message ):

                return "RAW Error: Failed to unpack the RAW data (\( code )): \( message )"

            case .unsupportedFormat:

                return "RAW Error: Unsupported RAW format"

            case .libRAWError( let code, let message ):

                return "RAW Error: LibRAW error (\( code )): \( message )"
        }
    }

    /// A localized description of the error, matching ``description``.
    public var errorDescription: String?
    {
        self.description
    }
}
