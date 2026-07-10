SwiftRAW
========

[![Build Status](https://img.shields.io/github/actions/workflow/status/macmade/SwiftRAW/ci-mac.yaml?label=macOS&logo=apple)](https://github.com/macmade/SwiftRAW/actions/workflows/ci-mac.yaml)
[![Issues](http://img.shields.io/github/issues/macmade/SwiftRAW.svg?logo=github)](https://github.com/macmade/SwiftRAW/issues)
![Status](https://img.shields.io/badge/status-active-brightgreen.svg?logo=git)
![License](https://img.shields.io/badge/license-mit-brightgreen.svg?logo=open-source-initiative)  
[![Contact](https://img.shields.io/badge/follow-@macmade-blue.svg?logo=twitter&style=social)](https://twitter.com/macmade)
[![Sponsor](https://img.shields.io/badge/sponsor-macmade-pink.svg?logo=github-sponsors&style=social)](https://github.com/sponsors/macmade)

### About

**SwiftRAW** is a read-only Swift library for reading camera RAW files, built as a thin
wrapper around [LibRAW](https://www.libraw.org).

It exposes a RAW file through a clean, Swift-native API: structured metadata (camera and
lens identification, exposure, image geometry, color-filter array, color calibration, GPS
and timestamp) plus safe access to the unpacked raw sensor (Bayer) buffer.

LibRAW is a C++ library, and SwiftRAW talks to it directly through
[Swift/C++ interoperability](https://www.swift.org/documentation/cxx-interop/) rather than
a hand-written C shim: a Clang module exposes the C++ `LibRaw` class, and the Swift layer
drives its lifecycle and reads structured data off its `imgdata` member.

### Status

SwiftRAW is intentionally **read-only**. It opens and unpacks a RAW file and surfaces its
metadata and raw sensor samples, but it does **not**:

- demosaic / interpolate the sensor data to an RGB image,
- extract or decode embedded thumbnails or previews,
- write, edit, or re-encode RAW files.

### Requirements

- macOS 15 or later
- Swift 6 (C++ interoperability enabled)
- LibRAW 0.22.1 — a universal (`x86_64` + `arm64`) static library is vendored in the
  repository under `LibRAW/`, along with its headers; there is nothing to install
  separately.

### Conformance & Limitations

- **Metadata** is a curated, cross-vendor subset. Camera identification, image geometry,
  the color-filter array, exposure and shot info, GPS, color calibration data, lens info,
  and common maker-note fields are exposed. The large per-vendor maker-note structures
  (Canon / Nikon / Sony / … specific), mount/format codes, accessory identifiers, and
  autofocus-point data blobs are out of scope.
- **Raw sensor data** exposes the 16-bit single-channel Bayer buffer (`raw_image`), both
  as a copy and as a zero-copy borrowed view; a descriptor reports the presence of the
  rarer multi-channel and floating-point buffer layouts.
- `RAWFile` owns a LibRAW instance for its lifetime and is a reference type. It is **not**
  `Sendable`: the underlying LibRAW instance is not safe to share across concurrency
  domains.

### Swift Package Manager

SwiftRAW ships a `Package.swift` and can be consumed as a Swift package. Add it to your
dependencies:

```swift
.package( url: "https://github.com/macmade/SwiftRAW.git", branch: "main" )
```

Because SwiftRAW links the vendored LibRAW static library through linker flags, it must be
consumed via a `branch:` or `revision:` requirement rather than a versioned tag.

### Cloning

This project uses submodules.  
To clone it, use the following command:

```bash
git clone --recursive https://github.com/macmade/SwiftRAW.git
```

### Example Usage

```swift
import SwiftRAW

// Open and unpack a RAW file from a URL (or from in-memory `Data`).
let file = try RAWFile( url: URL( fileURLWithPath: "photo.cr3" ) )

// A rich, one-line summary of the file.
print( file )
// Canon EOS R7, 7128×4732, Bayer (RGBG), ISO 100, 1/250s, f/2.8, 50mm, RF50mm F1.8 STM

// Camera identification and geometry.
print( file.imageInfo )  // Canon EOS R7 — 3 colors (RGBG)
print( file.imageSizes ) // raw 7128×4732, output 6984×4660

// Color-filter array: per-pixel color / channel lookup.
let cfa = file.cfaPattern
print( cfa )                                 // Bayer (RGBG)
print( cfa.color( atRow: 0, column: 0 ) )    // 0

if let channel = cfa.channel( atRow: 0, column: 1 )
{
    print( channel )                         // G
}

// Exposure, lens, and (when present) GPS.
print( file.shotInfo )   // ISO 100, 1/250s, f/2.8, 50mm
print( file.lensInfo )   // RF50mm F1.8 STM (50mm)

if let gps = file.gpsInfo
{
    print( gps )
}

// The unpacked 16-bit Bayer sensor buffer, as a copy...
if let pixels = file.rawImage
{
    print( "\( pixels.count ) samples, peak \( pixels.max() ?? 0 )" )
}

// ...or as a zero-copy view (valid only inside the closure).
let peak = file.withRawImage
{
    buffer in

    buffer.max() ?? 0
}

print( "peak sample: \( peak ?? 0 )" )
```

License
-------

Project is released under the terms of the MIT License.

Repository Infos
----------------

    Owner:          Jean-David Gadina - XS-Labs
    Web:            www.xs-labs.com
    Blog:           www.noxeos.com
    Twitter:        @macmade
    GitHub:         github.com/macmade
    LinkedIn:       ch.linkedin.com/in/macmade/
    StackOverflow:  stackoverflow.com/users/182676/macmade
