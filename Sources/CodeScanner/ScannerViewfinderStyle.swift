//
//  ScannerViewfinderStyle.swift
//  CodeScanner
//
//  Created by Bartłomiej Bukowiecki on 28/01/2025.
//

#if os(iOS)
import SwiftUI

public protocol ScannerViewfinderStyle {
    associatedtype Content: View
    
    @ViewBuilder func makeBody() -> Content
}

struct AnyScannerViewfinderStyle: ScannerViewfinderStyle {
    private let wrappedBody: () -> AnyView
    
    init<S>(style: S) where S: ScannerViewfinderStyle {
        self.wrappedBody = {
            AnyView(style.makeBody())
        }
    }
    
    func makeBody() -> AnyView {
        wrappedBody()
    }
}

public struct DefaultScannerViewfinderStyle: ScannerViewfinderStyle {
    public func makeBody() -> some View {
        Image("viewfinder", bundle: .module)
            .resizable()
            .frame(width: 200, height: 200)
    }
}

extension ScannerViewfinderStyle where Self == DefaultScannerViewfinderStyle {
    public static var `default`: DefaultScannerViewfinderStyle {
        DefaultScannerViewfinderStyle()
    }
}
#endif
