//
//  ValueTransformers.swift
//  EasySessions
//
//  Created by Harshad on 08/02/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Foundation

public protocol StringRepresentable {
    func toString() -> String
}

extension Double: StringRepresentable {
    public func toString() -> String {
        return String(stringInterpolationSegment: Float64(self))
    }
}

extension Int: StringRepresentable {
    public func toString() -> String {
        return String(stringInterpolationSegment: self)
    }
}

extension String: StringRepresentable {
    public func toString() -> String {
        return self
    }
}

extension Float: StringRepresentable {
    public func toString() -> String {
        return String(stringInterpolationSegment: self)
    }
}
