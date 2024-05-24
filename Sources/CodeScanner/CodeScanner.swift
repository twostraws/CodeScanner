//
//  CodeScanner.swift
//  https://github.com/twostraws/CodeScanner
//
//  Created by Paul Hudson on 14/12/2021.
//  Copyright © 2021 Paul Hudson. All rights reserved.
//

#if os(iOS)
import AVFoundation
import SwiftUI

/// An enum describing the ways CodeScannerView can hit scanning problems.
public enum ScanError: Error {
    /// The camera could not be accessed.
    case badInput

    /// The camera was not capable of scanning the requested codes.
    case badOutput

    /// Initialization failed.
    case initError(_ error: Error)
  
    /// The camera permission is denied 
    case permissionDenied
}

/// The result from a successful scan: the string that was scanned, and also the type of data that was found.
/// The type is useful for times when you've asked to scan several different code types at the same time, because
/// it will report the exact code type that was found.
@available(macCatalyst 14.0, *)
public struct ScanResult {
    /// The contents of the code.
    public let string: String

    /// The type of code that was matched.
    public let type: AVMetadataObject.ObjectType
    
    /// The image of the code that was matched
    public let image: UIImage?
  
    /// The corner coordinates of the scanned code.
    public let corners: [CGPoint]
}

/// The operating mode for CodeScannerView.
public enum ScanMode {
    /// Scan exactly one code, then stop.
    case once

    /// Scan each code no more than once.
    case oncePerCode

    /// Keep scanning all codes until dismissed.
    case continuous

    /// Keep scanning all codes - except the ones from the ignored list - until dismissed.
    case continuousExcept(ignoredList: Set<String>)

    /// Scan only when capture button is tapped.
    case manual

    var isManual: Bool {
        switch self {
        case .manual:
            return true
        case .once, .oncePerCode, .continuous, .continuousExcept:
            return false
        }
    }
}

/// A SwiftUI view that is able to scan barcodes, QR codes, and more, and send back what was found.
/// To use, set `codeTypes` to be an array of things to scan for, e.g. `[.qr]`, and set `completion` to
/// a closure that will be called when scanning has finished. This will be sent the string that was detected or a `ScanError`.
/// For testing inside the simulator, set the `simulatedData` property to some test data you want to send back.
@available(macCatalyst 14.0, *)
public struct CodeScannerView: UIViewControllerRepresentable {
    
    public let codeTypes: [AVMetadataObject.ObjectType]
    public let scanMode: ScanMode
    public let manualSelect: Bool
    public let scanInterval: Double
    public let showViewfinder: Bool
    public let requiresPhotoOutput: Bool
    public var simulatedData = ""
    public var shouldVibrateOnSuccess: Bool
    public var isTorchOn: Bool
    public var isPaused: Bool
    public var isGalleryPresented: Binding<Bool>
    public var videoCaptureDevice: AVCaptureDevice?
    public var completion: (Result<ScanResult, ScanError>) -> Void

    public init(
        codeTypes: [AVMetadataObject.ObjectType],
        scanMode: ScanMode = .once,
        manualSelect: Bool = false,
        scanInterval: Double = 2.0,
        showViewfinder: Bool = false,
        requiresPhotoOutput: Bool = true,
        simulatedData: String = "",
        shouldVibrateOnSuccess: Bool = true,
        isTorchOn: Bool = false,
        isPaused: Bool = false,
        isGalleryPresented: Binding<Bool> = .constant(false),
        videoCaptureDevice: AVCaptureDevice? = AVCaptureDevice.bestForVideo,
        completion: @escaping (Result<ScanResult, ScanError>) -> Void
    ) {
        self.codeTypes = codeTypes
        self.scanMode = scanMode
        self.manualSelect = manualSelect
        self.showViewfinder = showViewfinder
        self.requiresPhotoOutput = requiresPhotoOutput
        self.scanInterval = scanInterval
        self.simulatedData = simulatedData
        self.shouldVibrateOnSuccess = shouldVibrateOnSuccess
        self.isTorchOn = isTorchOn
        self.isPaused = isPaused
        self.isGalleryPresented = isGalleryPresented
        self.videoCaptureDevice = videoCaptureDevice
        self.completion = completion
    }

    public func makeUIViewController(context: Context) -> ScannerViewController {
        return ScannerViewController(showViewfinder: showViewfinder, parentView: self)
    }

    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        uiViewController.parentView = self
        uiViewController.updateViewController(
            isTorchOn: isTorchOn,
            isGalleryPresented: isGalleryPresented.wrappedValue,
            isManualCapture: scanMode.isManual,
            isManualSelect: manualSelect
        )
    }
    
}

@available(macCatalyst 14.0, *)
extension CodeScannerView {

    @available(*, deprecated, renamed: "requiresPhotoOutput")
    public var requirePhotoOutput: Bool {
        requiresPhotoOutput
    }
}

@available(macCatalyst 14.0, *)
struct CodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            // do nothing
        }
    }
}
#endif
