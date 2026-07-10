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

/// Tests for lens metadata, including the deterministic focal-type mapping and
/// fixture-driven lens reads.
struct RAWLensInfoTests
{
    /// LibRAW's `FocalType` codes map to the expected cases; unexpected values
    /// fall back to `unknown`.
    @Test
    func focalTypeMapping()
    {
        #expect( RAWMakerNoteLensInfo.FocalType( rawValue:  1 ) == .fixed )
        #expect( RAWMakerNoteLensInfo.FocalType( rawValue:  2 ) == .zoom )
        #expect( RAWMakerNoteLensInfo.FocalType( rawValue:  0 ) == .unknown )
        #expect( RAWMakerNoteLensInfo.FocalType( rawValue: -1 ) == .unknown )
        #expect( RAWMakerNoteLensInfo.FocalType( rawValue: 99 ) == .unknown )
    }

    /// Lens information reads without crashing and has non-negative focal
    /// values for real samples. Runs no cases until fixtures are supplied.
    @Test( arguments: TestUtilities.rawFileURLs )
    func lensInfoIsReadable( url: URL ) throws
    {
        let file = try RAWFile( url: url )
        let lens = file.lensInfo

        #expect( lens.minFocal >= 0 )
        #expect( lens.maxFocal >= 0 )
        #expect( lens.focalLengthIn35mmFormat >= 0 )
        #expect( lens.dng.minFocal >= 0 )
        #expect( lens.makerNotes.minFocal >= 0 )
    }
}
