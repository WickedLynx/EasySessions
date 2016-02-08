//
//  ValueTransformers.swift
//  EasySessions
//
//  Created by Harshad on 08/02/16.
//  Copyright © 2016 Laughing Buddha Software. All rights reserved.
//

import Foundation

public protocol Stringify {
    func toString() -> String
}

extension Double: Stringify {
    public func toString() -> String {
        return String(stringInterpolationSegment: Float64(self))
    }
}

extension Int: Stringify {
    public func toString() -> String {
        return String(stringInterpolationSegment: self)
    }
}

extension String: Stringify {
    public func toString() -> String {
        return self
    }
}

extension Float: Stringify {
    public func toString() -> String {
        return String(stringInterpolationSegment: self)
    }
}
