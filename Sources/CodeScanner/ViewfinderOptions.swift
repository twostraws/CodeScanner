//
//  ViewfinderOptions.swift
//  CodeScanner
//
//  Created by Bartłomiej Bukowiecki on 23/01/2025.
//

#if os(iOS)
import UIKit

public struct ViewfinderOptions {
    public let customImage: UIImage?
    public let size: CGSize
    public let useAsRectOfInterest: Bool
    
    public static let `default`: ViewfinderOptions = .init(size: CGSize(width: 200, height: 200))
    
    public init(
        customImage: UIImage? = nil,
        size: CGSize,
        useAsRectOfInterest: Bool = false
    ) {
        self.customImage = customImage
        self.size = size
        self.useAsRectOfInterest = useAsRectOfInterest
    }
}
#endif
