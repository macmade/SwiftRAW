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

/// Tests for the image geometry and identification metadata exposed by
/// ``RAWFile``. These run against user-supplied fixtures and have no cases until
/// RAW samples are provided.
struct RAWImageMetadataTests
{
    /// Image sizes are populated and internally consistent: the visible output
    /// fits within the full sensor dimensions.
    @Test( arguments: TestUtilities.rawFileURLs )
    func imageSizesAreSane( url: URL ) throws
    {
        let file  = try RAWFile( url: url )
        let sizes = file.imageSizes

        #expect( sizes.rawWidth > 0 )
        #expect( sizes.rawHeight > 0 )
        #expect( sizes.width > 0 )
        #expect( sizes.height > 0 )
        #expect( sizes.width <= sizes.rawWidth )
        #expect( sizes.height <= sizes.rawHeight )
        #expect( sizes.pixelAspect > 0 )
    }

    /// Camera identification is populated for real samples.
    @Test( arguments: TestUtilities.rawFileURLs )
    func imageInfoIsPopulated( url: URL ) throws
    {
        let file = try RAWFile( url: url )
        let info = file.imageInfo

        #expect( info.make.isEmpty == false )
        #expect( info.model.isEmpty == false )
        #expect( info.colors > 0 )
    }

    /// The CFA pattern derived off ``RAWFile`` is consistent with the raw
    /// identification metadata it comes from.
    @Test( arguments: TestUtilities.rawFileURLs )
    func cfaPatternMatchesImageInfo( url: URL ) throws
    {
        let file = try RAWFile( url: url )
        let cfa  = file.cfaPattern

        #expect( cfa.filters == file.imageInfo.filters )
        #expect( cfa.colorDescription == file.imageInfo.colorDescription )
    }
}
