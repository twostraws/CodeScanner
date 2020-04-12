//
//  CodeScannerView.swift
//
//  Created by Paul Hudson on 10/12/2019.
//  Copyright © 2019 Paul Hudson. All rights reserved.
//

import AVFoundation
import SwiftUI

/// A SwiftUI view that is able to scan barcodes, QR codes, and more, and send back what was found.
/// To use, set `codeTypes` to be an array of things to scan for, e.g. `[.qr]`, and set `completion` to
/// a closure that will be called when scanning has finished. This will be sent the string that was detected or a `ScanError`.
/// For testing inside the simulator, set the `simulatedData` property to some test data you want to send back.
public struct CodeScannerView: UIViewControllerRepresentable {
    public enum ScanError: Error {
        case badInput, badOutput
    }
    
    public class ScannerCoordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: CodeScannerView
        var codeFound = false
        
        init(parent: CodeScannerView) {
            assert(parent.simulatedData.isEmpty == false, "The iOS simulator does not support using the camera, so you must set the simulatedData property of CodeScannerView.")
            self.parent = parent
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                guard codeFound == false else { return }
                
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
                
                // make sure we only trigger scans once per use
                codeFound = true
            }
        }
        
        func found(code: String) {
            #if targetEnvironment(simulator)
            parent.completion(.success(parent.simulatedData))
            #else
            parent.completion(.success(code))
            #endif
        }
        
        func didFail(reason: ScanError) {
            parent.completion(.failure(reason))
        }
    }
    
    #if targetEnvironment(simulator)
    public class ScannerViewController: UIViewController {
        var delegate: ScannerCoordinator?
        
        override public func loadView() {
            view = UIView()
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            
            label.text = "You're running in the simulator, which means the camera isn't available. Tap anywhere to send back some simulated data."
            
            view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                label.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
                label.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor)
            ])
        }
        
        override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            delegate?.found(code: "")
        }
    }
    #else
    public class ScannerViewController: UIViewController {
        var captureSession: AVCaptureSession!
        var previewLayer: AVCaptureVideoPreviewLayer!
        var delegate: ScannerCoordinator?

        override public func viewDidLoad() {
            super.viewDidLoad()

            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(updateOrientation),
                                                   name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                                                   object: nil)
            
            view.backgroundColor = UIColor.black
            captureSession = AVCaptureSession()

            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let videoInput: AVCaptureDeviceInput

            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                return
            }

            if (captureSession.canAddInput(videoInput)) {
                captureSession.addInput(videoInput)
            } else {
                delegate?.didFail(reason: .badInput)
                return
            }

            let metadataOutput = AVCaptureMetadataOutput()

            if (captureSession.canAddOutput(metadataOutput)) {
                captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = delegate?.parent.codeTypes
            } else {
                delegate?.didFail(reason: .badOutput)
                return
            }
        }

        override public func viewWillLayoutSubviews() {
            previewLayer.frame = view.layer.bounds
        }
        
        @objc func updateOrientation() {
            guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
                return
            }
            let previewConnection = captureSession.connections[1]
            previewConnection.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue) ?? .portrait
        }

        override public func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            updateOrientation()
            captureSession.startRunning()
        }
        
        override public func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)

            if (captureSession?.isRunning == false) {
                captureSession.startRunning()
            }
        }

        override public func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)

            if (captureSession?.isRunning == true) {
                captureSession.stopRunning()
            }
            
            NotificationCenter.default.removeObserver(self)
        }

        override public var prefersStatusBarHidden: Bool {
            return true
        }

        override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            return .all
        }
    }
    #endif
    
    public let codeTypes: [AVMetadataObject.ObjectType]
    public var simulatedData = ""
    public var completion: (Result<String, ScanError>) -> Void
    
    public init(codeTypes: [AVMetadataObject.ObjectType], simulatedData: String = "", completion: @escaping (Result<String, ScanError>) -> Void) {
        self.codeTypes = codeTypes
        self.simulatedData = simulatedData
        self.completion = completion
    }
    
    public func makeCoordinator() -> ScannerCoordinator {
        return ScannerCoordinator(parent: self)
    }
    
    public func makeUIViewController(context: Context) -> ScannerViewController {
        let viewController = ScannerViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    public func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        
    }
}

struct CodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            // do nothing
        }
    }
}
