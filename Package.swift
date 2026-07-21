// swift-tools-version:6.0

/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2025, Jean-David Gadina - www.xs-labs.com
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

import PackageDescription

let package = Package(
    name: "SwiftRAW",
    products: [
        .library( name: "SwiftRAW", targets: [ "SwiftRAW" ] ),
    ],
    targets: [
        .systemLibrary(
            name: "libraw",
            path: "LibRAW/include"
        ),
        .target(
            name: "SwiftRAW",
            dependencies: [ "libraw" ],
            path: "SwiftRAW",
            swiftSettings: [
                .interoperabilityMode( .Cxx ),
            ],
            linkerSettings: [
                // Linker flags are passed through verbatim, so a relative search
                // path would resolve against whichever package drives the build,
                // not this one — breaking the link as soon as SwiftRAW is consumed
                // as a dependency. `Context.packageDirectory` always names this
                // package's own directory, including when its manifest is
                // evaluated as a dependency of another.
                .unsafeFlags( [ "-L", "\( Context.packageDirectory )/LibRAW/lib" ] ),
            ]
        ),
        .testTarget(
            name: "SwiftRAWTests",
            dependencies: [ "SwiftRAW" ],
            path: "SwiftRAWTests",
            swiftSettings: [
                .interoperabilityMode( .Cxx ),
            ]
        ),
    ]
)
