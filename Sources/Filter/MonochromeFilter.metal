//
//  MonochromeFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void MonochromeFilter(
                             texture2d<float, access::write> outTexture [[texture(0)]],
                             texture2d<float, access::read> inTexture [[texture(1)]],
                             const device float *threshold [[buffer(0)]],
                             uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    const float3 luminanceVector = float3(0.2125, 0.7154, 0.0721);
    const float luminance = dot(inColor.rgb, luminanceVector);
    const float4 desat = float4(float3(luminance), 1.0);
    
    const float4 outColor = float4(mix(
                                       inColor.rgb,
                                       float3(
                                              (desat.r < 0.5 ? (2.0 * desat.r * 0.6)  : (1.0 - 2.0 * (1.0 - desat.r) * 0.4)),
                                              (desat.g < 0.5 ? (2.0 * desat.g * 0.45) : (1.0 - 2.0 * (1.0 - desat.g) * 0.55)),
                                              (desat.b < 0.5 ? (2.0 * desat.b * 0.3)  : (1.0 - 2.0 * (1.0 - desat.b) * 0.7))
                                              ),
                                       *threshold
                                       ),
                                   1.0);
    outTexture.write(outColor, gid);
}
