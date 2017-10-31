//
//  BlurFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void BlurFilter(
                       texture2d<float, access::write> outTexture [[texture(0)]],
                       texture2d<float, access::read> inTexture [[texture(1)]],
                       texture2d<float, access::read> weights [[texture(2)]],
                       const device float *radius [[buffer(0)]],
                       uint2 gid [[thread_position_in_grid]])
{
    const int size = int(*radius) * 2;
    float4 accumColor(0, 0, 0, 0);
    
    for (int j = 0; j < size; ++j)
    {
        for (int i = 0; i < size; ++i)
        {
            uint2 kernelIndex(i, j);
            uint2 textureIndex(gid.x + (i - *radius), gid.y + (j - *radius));
            float4 color = inTexture.read(textureIndex).rgba;
            float4 weight = weights.read(kernelIndex).rrrr;
            accumColor += weight * color;
        }
    }
    
    outTexture.write(accumColor, gid);
}

