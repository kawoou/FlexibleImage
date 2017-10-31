//
//  ContextType.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 13..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
#else
    import AppKit
#endif

public typealias ContextType = (
    _ context: CGContext,
    _ width: Int,
    _ height: Int,
    _ memoryPool: UnsafeMutablePointer<UInt8>
) -> ()
