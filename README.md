# CodeScanner

<p>
    <img src="https://img.shields.io/badge/iOS-13.0+-blue.svg" />
    <img src="https://img.shields.io/badge/Swift-5.1-ff69b4.svg" />
    <a href="https://twitter.com/twostraws">
        <img src="https://img.shields.io/badge/Contact-@twostraws-lightgrey.svg?style=flat" alt="Twitter: @twostraws" />
    </a>
</p>

CodeScanner is a SwiftUI framework that makes it easy to scan codes such as QR codes and barcodes. It provides a view struct, `CodeScannerView`, that can be shown inside a sheet so that all scanning occurs in one place.


## Basic usage

You should create an instance of `CodeScannerView` with at least two parameters: an array of the types to scan for, and a closure that will be called when a result is ready.

Your completion closure must accept a `Result<ScanResult, ScanError>`, where the success case is the code string and type that was found. For example, if you asked to scan for QR codes and bar codes, you might be told that a QR code containing the email address paul@hackingwithswift.com was found.

If things go wrong, your result will contain a `ScanError` set to one of these three cases:

- `badInput`, if the camera cannot be accessed
- `badOutput`, if the camera is not capable of detecting codes
- `initError`, if initialization failed.

**Important:** iOS *requires* you to add the "Privacy - Camera Usage Description" key to your Info.plist file, providing a reason for why you want to access the camera.


## Customization options

You can provide a variety of extra customization options to `CodeScannerView` in its initializer:

- `scanMode` can be `.once` to scan a single code, `.oncePerCode` to scan many codes but only trigger finding each unique code once, and `.continuous` will keep finding codes until you dismiss the scanner. Default: `.once`.
- `scanInterval` controls how fast individual codes should be scanned (in seconds) when running in `.continuous` scan mode.
- `showViewfinder` determines whether to show a box-like viewfinder over the UI. Default: false.
- `simulatedData` allows you to provide some test data to use in Simulator, when real scanning isn’t available. Default: an empty string.
- `shouldVibrateOnSuccess` allows you to determine whether device should vibrate when a code is found. Default: true.
- `videoCaptureDevice` allows you to choose different capture device that is most suitable for code to scan. 

If you want to add UI customization, such as a dedicated Cancel button, you should wrap your `CodeScannerView` instance in a `NavigationView` and use a `toolbar()` modifier to add whatever buttons you want.


## Examples

Here's some example code to create a QR code-scanning view that prints the code that was found or any error. If it's used in the simulator it will return a name, because that's provided as the simulated data:

```swift
CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson") { response in                    
    switch response {
    case .success(let result):
        print("Found code: \(result.string)")
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```

Your completion closure is probably where you want to dismiss the `CodeScannerView`.

Here's an example on how to present the QR code-scanning view as a sheet and how the scanned barcode can be passed to the next view in a `NavigationView`:

```swift
struct QRCodeScannerExampleView: View {
    @State private var isPresentingScanner = false
    @State private var scannedCode: String?

    var body: some View {
        VStack(spacing: 10) {
            if let code = scannedCode {
                NavigationLink("Next page", destination: NextView(scannedCode: code), isActive: .constant(true)).hidden()
            }

            Button("Scan Code") {
                isPresentingScanner = true
            }

            Text("Scan a QR code to begin")
        }
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr]) { response in
                if case let .success(result) = response {
                    scannedCode = result.string
                    isPresentingScanner = false
                }
            }
        }
    }
}
```

## Scanning small QR codes

Scanning small QR code on devices with dual or tripple cameras has to be adjusted because of minimum focus distance built in these cameras.
To have the best possible focus on the code we scan it is needed to choose the most suitable camera and apply recommended zoom factor.

Example for scanning 20x20mm QR codes.

```swift
CodeScannerView(codeTypes: [.qr], videoCaptureDevice: AVCaptureDevice.zoomedCameraForQRCode(withMinimumCodeSize: 20)) { response in                    
    switch response {
    case .success(let result):
        print("Found code: \(result.string)")
    case .failure(let error):
        print(error.localizedDescription)
    }
}
```


## Credits

CodeScanner was made by [Paul Hudson](https://twitter.com/twostraws), who writes [free Swift tutorials over at Hacking with Swift](https://www.hackingwithswift.com), and is now maintained by [Nathan Fallet](https://nathanfallet.me). It’s available under the MIT license, which permits commercial use, modification, distribution, and private use.


## License

MIT License.

Copyright (c) 2021 Paul Hudson

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
