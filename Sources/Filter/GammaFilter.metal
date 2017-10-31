//
//  GammaFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void GammaFilter(
                        texture2d<float, access::write> outTexture [[texture(0)]],
                        texture2d<float, access::read> inTexture [[texture(1)]],
                        const device float *gamma [[buffer(0)]],
                        uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    const float4 outColor = float4(pow(inColor.rgb, float3(*gamma)), inColor.a);
    outTexture.write(outColor, gid);
}
