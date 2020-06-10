# CodeScanner

<p>
    <img src="https://img.shields.io/badge/iOS-13.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.1-ff69b4.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-lightgrey.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

CodeScanner is a simple wrapper SwiftUI framework that makes it easy to scan codes such as QR codes and barcodes. It provides a struct, `CodeScannerView`, that can be shown inside a sheet so that all scanning occurs in one place.


## Usage

You should create an instance of `CodeScannerView` with three parameters: an array of the types to scan for, some test data to send back when running in the simulator, and a closure that will be called when a result is ready. This closure must accept a `Result<String, ScanError>`, where the string is the code that was found on success and `ScanError` will be either `badInput` (if the camera cannot be accessed) or `badOutput` (if the camera is not capable of detecting codes.)

**Important:** iOS *requires* you to add the "Privacy - Camera Usage Description" key to your Info.plist file, providing a reason for why you want to access the camera.


## Examples

Here's some example code to create a QR code-scanning view that prints the code that was found or any error. If it's used in the simulator it will return a name, because that's provided as the simulated data:

```swift
CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { result in                    
    switch result {
    case .success(let code):
        print("Found code: \(code)")
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

Your completion closure is probably where you want to dismiss the `CodeScannerView`.

Here's an example on how to present the QR code-scanning view as a sheet and how the scanned barcode can be passed to the next view in a NavigationView:

```swift
struct QRCodeScannerExampleView: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if self.scannedCode != nil {
                    NavigationLink("Next page", destination: NextView(scannedCode: scannedCode!), isActive: .constant(true)).hidden()
                }
                Button("Scan Code") {
                    self.isPresentingScanner = true
                }
                .sheet(isPresented: $isPresentingScanner) {
                    self.scannerSheet
                }
                Text("Scan a QR code to begin")
            }

        }
    }

    var scannerSheet : some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code
                    self.isPresentingScanner = false
                }
            }
        )
    }
}
```


## Credits

CodeScanner was made by [Paul Hudson](https://twitter.com/twostraws), who writes [free Swift tutorials over at Hacking with Swift](https://www.hackingwithswift.com). It’s available under the MIT license, which permits commercial use, modification, distribution, and private use.


## License

MIT License.

Copyright (c) 2019 Paul Hudson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
