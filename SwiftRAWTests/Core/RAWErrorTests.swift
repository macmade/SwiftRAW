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

/// Tests for ``RAWError`` descriptions.
struct RAWErrorTests
{
    /// All cases carry the shared `"RAW Error:"` prefix.
    @Test
    func descriptionsArePrefixed()
    {
        let url = URL( fileURLWithPath: "/tmp/photo.cr2" )

        let errors: [ RAWError ] =
        [
            .invalidFileURL( url ),
            .cannotReadFile( url ),
            .openFailed( code: -2, message: "unsupported" ),
            .unpackFailed( code: -9, message: "io error" ),
            .unsupportedFormat,
            .libRAWError( code: -1, message: "unspecified" ),
        ]

        errors.forEach
        {
            #expect( $0.description.hasPrefix( "RAW Error:" ) )
        }
    }

    /// The status code and message are included in the description.
    @Test
    func descriptionIncludesCodeAndMessage()
    {
        let error = RAWError.openFailed( code: -2, message: "Unsupported file format" )

        #expect( error.description.contains( "-2" ) )
        #expect( error.description.contains( "Unsupported file format" ) )
    }

    /// The localized `errorDescription` matches the textual description.
    @Test
    func errorDescriptionMatchesDescription()
    {
        let error = RAWError.unsupportedFormat

        #expect( error.errorDescription == error.description )
    }
}
