//
//  AVCaptureDevice+bestForBuiltInCamera.swift
//  https://github.com/twostraws/CodeScanner
//
//  Created by Karol Bielski on 10/02/2024.
//  Copyright © 2024 Paul Hudson. All rights reserved.
//

#if os(iOS)
import AVFoundation

@available(macCatalyst 14.0, *)
extension AVCaptureDevice {
    
    /// Returns best built in back camera for scanning QR codes zoomed for a given minimum code size.
    public static func zoomedCameraForQRCode(withMinimumCodeSize minimumCodeSize: Float = 20) -> AVCaptureDevice? {
        let captureDevice = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .back
        ).devices.first ?? AVCaptureDevice.default(for: .video)
        
        if #available(iOS 15.0, *) {
            captureDevice?.setRecommendedZoomFactor(forMinimumCodeSize: minimumCodeSize)
        }
        
        return captureDevice
    }
    
    /// Sets recommended zoom factor for a given minimum code size.
    @available(iOS 15.0, *)
    func setRecommendedZoomFactor(forMinimumCodeSize minimumCodeSize: Float) {
        /*
         Optimize the user experience for scanning QR codes down to given size.
         When scanning a QR code of that size, the user may need to get closer than
         the camera's minimum focus distance to fill the rect of interest.
         To have the QR code both fill the rect and still be in focus, we may need to apply some zoom.
         */
        let deviceMinimumFocusDistance = Float(minimumFocusDistance)
        guard deviceMinimumFocusDistance != -1 else { return }
        
        let deviceFieldOfView = activeFormat.videoFieldOfView
        let formatDimensions = CMVideoFormatDescriptionGetDimensions(activeFormat.formatDescription)
        let rectOfInterestWidth = Double(formatDimensions.height) / Double(formatDimensions.width)
        let minimumSubjectDistanceForCode = minimumSubjectDistanceForCode(
            fieldOfView: deviceFieldOfView,
            minimumCodeSize: minimumCodeSize,
            previewFillPercentage: Float(rectOfInterestWidth)
        )
        
        guard minimumSubjectDistanceForCode < deviceMinimumFocusDistance else { return }
        
        let zoomFactor = deviceMinimumFocusDistance / minimumSubjectDistanceForCode
        do {
            try lockForConfiguration()
            videoZoomFactor = CGFloat(zoomFactor)
            unlockForConfiguration()
        } catch {
            print("Could not lock for configuration: \(error)")
        }
    }
    
    private func minimumSubjectDistanceForCode(
        fieldOfView: Float,
        minimumCodeSize: Float,
        previewFillPercentage: Float
    ) -> Float {
        /*
         Given the camera horizontal field of view, we can compute the distance (mm) to make a code
         of minimumCodeSize (mm) fill the previewFillPercentage.
         */
        let radians = (fieldOfView / 2).radians
        let filledCodeSize = minimumCodeSize / previewFillPercentage
        return filledCodeSize / tan(radians)
    }
}

private extension Float {
    var radians: Float {
        self * Float.pi / 180
    }
}
#endif

/*
 Part of this code is copied from Apple sample project "AVCamBarcode: Using AVFoundation to capture barcodes".

 IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 */
