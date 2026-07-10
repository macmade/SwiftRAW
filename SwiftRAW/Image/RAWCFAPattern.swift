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

/// The color-filter-array (CFA) layout of a RAW sensor.
///
/// Describes how colors are arranged over the sensor's pixels and provides a
/// per-pixel color lookup equivalent to LibRAW's `COLOR(row, col)` for the two
/// common layouts: a repeating 2×2 Bayer mosaic and Fuji's 6×6 X-Trans mosaic.
/// Sensors without a CFA (Foveon, monochrome, or already-demosaiced input) are
/// reported as ``Kind/none``.
public struct RAWCFAPattern: Sendable, Equatable
{
    /// The kind of color-filter array.
    public enum Kind: Sendable, Equatable
    {
        /// No color-filter array (Foveon, monochrome, or full-color data).
        case none

        /// A repeating 2×2 Bayer mosaic.
        case bayer

        /// Fuji's 6×6 X-Trans mosaic.
        case xTrans
    }

    /// The kind of color-filter array.
    public let kind: Kind

    /// The packed CFA pattern value, as encoded by LibRAW (`filters`).
    public let filters: UInt32

    /// The color descriptor mapping color indices to channel letters (e.g.
    /// `"RGBG"`).
    public let colorDescription: String

    /// The 6×6 X-Trans color-index grid, present only when ``kind`` is
    /// ``Kind/xTrans``.
    public let xTransPattern: [ [ Int ] ]?

    /// The special color index LibRAW returns for sensors without a CFA,
    /// meaning "all channels" (`0 + 1 + 2 + 3`).
    public static let fullColorIndex = 6

    /// Creates a CFA pattern from explicit values.
    ///
    /// The ``kind`` is derived from `filters`: `0` is ``Kind/none``, `9` is
    /// ``Kind/xTrans``, and any other value is treated as ``Kind/bayer``.
    ///
    /// - Parameters:
    ///   - filters: The packed CFA pattern value.
    ///   - colorDescription: The color descriptor (channel letters).
    ///   - xTransPattern: The 6×6 X-Trans grid, for X-Trans sensors.
    public init( filters: UInt32, colorDescription: String, xTransPattern: [ [ Int ] ]? = nil )
    {
        self.filters          = filters
        self.colorDescription = colorDescription

        if filters == 0
        {
            self.kind          = .none
            self.xTransPattern = nil
        }
        else if filters == 9
        {
            self.kind          = .xTrans
            self.xTransPattern = xTransPattern
        }
        else
        {
            self.kind          = .bayer
            self.xTransPattern = nil
        }
    }

    /// Creates a CFA pattern from a LibRAW `libraw_iparams_t` value.
    ///
    /// - Parameter idata: The LibRAW identification structure.
    internal init( from idata: libraw_iparams_t )
    {
        let filters       = idata.filters
        let xTransPattern = filters == 9 ? RAWCFAPattern.readXTransPattern( from: idata.xtrans ) : nil

        self.init( filters: filters, colorDescription: String( cCharArray: idata.cdesc ), xTransPattern: xTransPattern )
    }

    /// The color index of the pixel at a given position.
    ///
    /// The returned index maps into ``colorDescription`` (e.g. index `0` is its
    /// first character). For ``Kind/none`` sensors this is
    /// ``fullColorIndex``.
    ///
    /// - Parameters:
    ///   - row: The pixel row.
    ///   - column: The pixel column.
    ///
    /// - Returns: The color index for the pixel.
    public func color( atRow row: Int, column: Int ) -> Int
    {
        switch self.kind
        {
            case .none:

                return RAWCFAPattern.fullColorIndex

            case .xTrans:

                guard let pattern = self.xTransPattern
                else
                {
                    return RAWCFAPattern.fullColorIndex
                }

                let r = ( ( row % 6 ) + 6 ) % 6
                let c = ( ( column % 6 ) + 6 ) % 6

                return pattern[ r ][ c ]

            case .bayer:

                let shift = ( ( ( row << 1 ) & 14 ) | ( column & 1 ) ) << 1

                return Int( ( self.filters >> UInt32( shift ) ) & 3 )
        }
    }

    /// The channel letter of the pixel at a given position.
    ///
    /// - Parameters:
    ///   - row: The pixel row.
    ///   - column: The pixel column.
    ///
    /// - Returns: The channel letter from ``colorDescription``, or `nil` if the
    ///   color index has no corresponding letter (e.g. ``Kind/none`` sensors).
    public func channel( atRow row: Int, column: Int ) -> Character?
    {
        let index      = self.color( atRow: row, column: column )
        let characters = Array( self.colorDescription )

        guard index >= 0, index < characters.count
        else
        {
            return nil
        }

        return characters[ index ]
    }

    /// Reads LibRAW's 6×6 `xtrans` array into a color-index grid.
    ///
    /// - Parameter xtrans: The LibRAW `xtrans` fixed C array value (a 6×6 tuple
    ///   of `char`).
    ///
    /// - Returns: A 6×6 grid of color indices.
    private static func readXTransPattern< T >( from xtrans: T ) -> [ [ Int ] ]
    {
        let flat = withUnsafeBytes( of: xtrans )
        {
            buffer in

            buffer.bindMemory( to: Int8.self ).map
            {
                Int( $0 )
            }
        }

        return ( 0 ..< 6 ).map
        {
            row in

            ( 0 ..< 6 ).map
            {
                column in

                flat[ ( row * 6 ) + column ]
            }
        }
    }
}
