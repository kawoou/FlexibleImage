//
//  SolarizeFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void SolarizeFilter(
                           texture2d<float, access::write> outTexture [[texture(0)]],
                           texture2d<float, access::read> inTexture [[texture(1)]],
                           const device float *threshold [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    const float3 solarizeVector = float3(0.2125, 0.7154, 0.0721);
    const float l = dot(inColor.rgb, solarizeVector);
    const float t = step(l, *threshold);
    
    const float4 outColor = float4(abs(float3(t) - inColor.rgb), inColor.a);
    outTexture.write(outColor, gid);
}
