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

/// Helpers for locating the user-supplied RAW fixture files.
///
/// Fixtures live in a `Test Files/` directory at the repository root, outside
/// any target directory, so they cannot be declared as SwiftPM package resources
/// and are deliberately not bundled into the test bundle either. They are
/// discovered relative to this source file via `#filePath`, which resolves on
/// the machine that built the tests under both SwiftPM and Xcode.
///
/// Missing fixtures are a hard failure, not a skip: ``hasTestFiles`` is asserted
/// by `RAWFileTests.testFilesArePresent()`, so an incomplete checkout fails the
/// suite instead of silently reducing the fixture-driven tests to zero cases.
enum TestUtilities
{
    /// The `Test Files/` directory at the repository root.
    static let testFilesDirectory: URL = .init( fileURLWithPath: #filePath )
        .deletingLastPathComponent() // SwiftRAWTests/
        .deletingLastPathComponent() // repository root
        .appendingPathComponent( "Test Files", isDirectory: true )

    /// The file extensions recognized as RAW fixtures, lowercased.
    static let rawFileExtensions: Set< String > =
        [
            "cr2", "cr3", "crw", "nef", "nrw", "arw", "sr2", "srf",
            "dng", "raf", "rw2", "orf", "pef", "srw", "rwl", "iiq",
            "3fr", "fff", "mos", "mrw", "kdc", "dcr", "erf", "x3f",
        ]

    /// All RAW fixture URLs found under ``testFilesDirectory``, searched
    /// recursively and sorted for deterministic ordering.
    static var rawFileURLs: [ URL ]
    {
        guard let enumerator = FileManager.default.enumerator( at: testFilesDirectory, includingPropertiesForKeys: nil )
        else
        {
            return []
        }

        let urls = enumerator.compactMap
        {
            $0 as? URL
        }
        .filter
        {
            rawFileExtensions.contains( $0.pathExtension.lowercased() )
        }

        return urls.sorted
        {
            $0.absoluteString < $1.absoluteString
        }
    }

    /// Whether any RAW fixtures are available.
    static var hasTestFiles: Bool
    {
        self.rawFileURLs.isEmpty == false
    }
}
