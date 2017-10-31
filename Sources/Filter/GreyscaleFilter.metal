//
//  GreyscaleFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void GreyscaleFilter(
                            texture2d<float, access::write> outTexture [[texture(0)]],
                            texture2d<float, access::read> inTexture [[texture(1)]],
                            const device float *threshold [[buffer(0)]],
                            uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    const float grey = inColor.r * 0.299 + inColor.g * 0.587 + inColor.b * 0.114;

    const float4 outColor = float4(mix(inColor.rgb, float3(grey), *threshold), inColor.a);
    outTexture.write(outColor, gid);
}
