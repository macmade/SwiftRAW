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

/// Tests for opening and unpacking a ``RAWFile``.
struct RAWFileTests
{
    /// Opening a non-file URL fails with ``RAWError/invalidFileURL(_:)``.
    @Test
    func invalidFileURL() throws
    {
        let url = try #require( URL( string: "https://example.com/photo.cr2" ) )

        #expect( url.isFileURL == false )
        #expect
        {
            _ = try RAWFile( url: url )
        }
        throws:
        {
            error in

            guard let error = error as? RAWError, case .invalidFileURL = error
            else
            {
                return false
            }

            return true
        }
    }

    /// Opening a file URL that does not exist fails with
    /// ``RAWError/cannotReadFile(_:)``.
    @Test
    func nonexistentFile() throws
    {
        let url = URL( fileURLWithPath: "/nonexistent/\( UUID().uuidString ).cr2" )

        #expect
        {
            _ = try RAWFile( url: url )
        }
        throws:
        {
            error in

            guard let error = error as? RAWError, case .cannotReadFile = error
            else
            {
                return false
            }

            return true
        }
    }

    /// Opening non-RAW data fails with a ``RAWError``.
    @Test
    func garbageDataThrows() throws
    {
        let data = Data( "this is definitely not a RAW file".utf8 )

        #expect( throws: RAWError.self )
        {
            _ = try RAWFile( data: data )
        }
    }

    /// Opening empty data fails with a ``RAWError``.
    @Test
    func emptyDataThrows() throws
    {
        #expect( throws: RAWError.self )
        {
            _ = try RAWFile( data: Data() )
        }
    }

    /// The fixture directory is located next to the repository root.
    @Test
    func testFilesDirectoryIsResolved()
    {
        #expect( TestUtilities.testFilesDirectory.lastPathComponent == "Test Files" )
    }

    /// Every provided RAW fixture opens and unpacks eagerly, and reports a
    /// non-empty description. Runs no cases until fixtures are supplied.
    @Test( arguments: TestUtilities.rawFileURLs )
    func openFixtureEagerly( url: URL ) throws
    {
        let file = try RAWFile( url: url )

        #expect( file.description.isEmpty == false )
    }

    /// Every provided RAW fixture can be opened lazily and unpacked on demand.
    /// Runs no cases until fixtures are supplied.
    @Test( arguments: TestUtilities.rawFileURLs )
    func openFixtureLazily( url: URL ) throws
    {
        let file = try RAWFile( url: url, options: RAWParsingOptions( unpacksImmediately: false ) )

        try file.unpack()
        try file.unpack() // idempotent

        #expect( file.description.isEmpty == false )
    }

    /// A fixture opened from in-memory data behaves like one opened from a URL.
    /// Runs no cases until fixtures are supplied.
    @Test( arguments: TestUtilities.rawFileURLs )
    func openFixtureFromData( url: URL ) throws
    {
        let data = try Data( contentsOf: url )
        let file = try RAWFile( data: data )

        #expect( file.description.isEmpty == false )
    }
}
