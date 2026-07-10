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

/// Tests for the color calibration data exposed by ``RAWFile``. These run
/// against user-supplied fixtures and have no cases until RAW samples exist.
struct RAWColorDataTests
{
    /// The multiplier arrays and color matrices have the expected shapes and
    /// the saturation level is populated for real samples.
    @Test( arguments: TestUtilities.rawFileURLs )
    func colorArraysHaveExpectedShape( url: URL ) throws
    {
        let file  = try RAWFile( url: url )
        let color = file.colorData

        #expect( color.cameraMultipliers.count == 4 )
        #expect( color.preMultipliers.count == 4 )
        #expect( color.channelBlackLevels.count == 4 )

        #expect( color.rgbCamera.count == 3 )
        #expect( color.rgbCamera.allSatisfy { $0.count == 4 } )

        #expect( color.cameraXYZ.count == 4 )
        #expect( color.cameraXYZ.allSatisfy { $0.count == 3 } )

        #expect( color.colorMatrix.count == 3 )
        #expect( color.colorMatrix.allSatisfy { $0.count == 4 } )

        #expect( color.maximum > 0 )
    }
}
