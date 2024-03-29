//
//  FilteringPipeline.swift
//  Polarr
//
//  Created by developer on 8/6/19.
//  Copyright © 2019 iOSDevLog. All rights reserved.
//

import MetalKit

class FilteringPipeline {
    private var filters = [BasicImageFilter]()
    let dispatch = DispatchQueue.global(qos: .userInteractive)
    
    lazy var metalDevice:  MTLDevice? = {
        return MTLCreateSystemDefaultDevice()
    }()
    
    lazy var commandQueue: MTLCommandQueue? = {
        return metalDevice?.makeCommandQueue()
    }()
    
    func addFilter(filter: BasicImageFilter) {
        self.filters.append(filter)
    }
    
    init(_ filters: BasicImageFilter...) {
        self.filters = filters
    }
    
    func filter(inputTexture: MTLTexture) -> MTLTexture? {
        
        var texture:MTLTexture? = inputTexture
        
        // Walk through each of our filters and add to commandQueue
        for filter in filters {
            guard let currentTexture = texture,
                let emptyTexture = currentTexture.sameSizeEmptyTexture(),
                let pipelineState = filter.pipelineState else {
                    continue
            }
            var textures = [MTLTexture]()
            textures.append(emptyTexture)
            textures.append(currentTexture)
            self.commandQueue?.addCommand(pipelineState: (pipelineState), textures: textures, factors: filter.getFactors())
            
            texture = textures.first
        }
        
        return texture
    }
    
    func filter(inputTexture: MTLTexture, callBack:@escaping (_ resultTexture: MTLTexture?) -> ())  {
       dispatch.async { [weak self] in
            var texture:MTLTexture? = inputTexture
            
            // Walk through each of our filters and add to commandQueue
            for filter in self!.filters {
                guard let currentTexture = texture,
                    let emptyTexture = currentTexture.sameSizeEmptyTexture(),
                    let pipelineState = filter.pipelineState else {
                        continue
                }
                var textures = [MTLTexture]()
                textures.append(emptyTexture)
                textures.append(currentTexture)
                self?.commandQueue?.addCommand(pipelineState: (pipelineState), textures: textures, factors: filter.getFactors())
                
                texture = textures.first
            }
            callBack(texture)
        }
    }
}
