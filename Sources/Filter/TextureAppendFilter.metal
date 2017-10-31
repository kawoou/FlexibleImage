//
//  TextureAppendFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 13..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void TextureAppendFilter(
                                texture2d<float, access::write> outTexture [[texture(0)]],
                                texture2d<float, access::read> inTexture [[texture(1)]],
                                texture2d<float, access::read> appendTexture [[texture(2)]],
                                const device float *sizeX [[buffer(0)]],
                                const device float *sizeY [[buffer(1)]],
                                const device float *threshold [[buffer(2)]],
                                uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    if (gid.x <= *sizeX && gid.y <= *sizeY) {
        float4 mixColor = appendTexture.read(gid);
        
        const float a = inColor.a + mixColor.a * (1.0 - inColor.a);
        const float alphaDivisor = a + step(a, 0.0);
        
        const float4 outColor = float4((inColor.rgb * (1.0 - mixColor.a) + mixColor.rgb * mixColor.a) / alphaDivisor, inColor.a);
        outTexture.write(outColor, gid);
    } else {
        outTexture.write(inColor, gid);
    }
}
