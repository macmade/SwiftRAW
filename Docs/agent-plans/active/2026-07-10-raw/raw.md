# RAW File Parser

## Goal

Create a Swift wrapper for LibRAW.  
An Xcode project is already setup. The C++ headers for LibRAW are available, and the project links with LibRAW as a universal static library.  
There is also a Swift package - make sure that it's setup properly and that it builds too.

You should be able to use C++ directly from Swift, by defining a Clang module for LibRAW.

Ideally, and if possible, I would like the Swift API to closely follow the architecture, conventions, and organization of the SwiftFITS and SwiftXISF projects:

- https://github.com/macmade/SwiftFITS.git
- https://github.com/macmade/SwiftXISF.git

Include complete and broad unit tests, just as SwiftFITS and SwiftXISF.  
Test files can be provided on demand.

Once implemented, update the README.md file, takinf the ones in SwiftFITS and SwiftXISF as examples.

The SwiftFITS and SwiftXISF repositories are checked out in the directory above this repository.  
Make sure to read and understand how the projects are structured and replicate as closely as possible whenever applicable.  
Do not reference any absolute file paths from SwiftFITS or SwiftXISF.

## LibRAW References:

- API Overview (C++): https://www.libraw.org/docs/API-overview.html
- Data Structures and Constants: https://www.libraw.org/docs/API-datastruct-eng.html
- C++ API: https://www.libraw.org/docs/API-CXX.html
- C API: https://www.libraw.org/docs/API-C.html
- General Notes on API: https://www.libraw.org/docs/API-notes.html
- Usage Examples: https://www.libraw.org/docs/Samples-LibRaw.html

## Other References

- Mixing Swift and C++: https://www.swift.org/documentation/cxx-interop/#enabling-c-interoperability
