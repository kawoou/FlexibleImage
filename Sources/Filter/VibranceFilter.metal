//
//  VibranceFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void VibranceFilter(
                           texture2d<float, access::write> outTexture [[texture(0)]],
                           texture2d<float, access::read> inTexture [[texture(1)]],
                           const device float *vibrance [[buffer(0)]],
                           uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    float avg = (inColor.r + inColor.g + inColor.b) / 3.0;
    float mx = max(inColor.r, max(inColor.g, inColor.b));
    float amt = (mx - avg) * -(*vibrance * 3.0);
    
    const float4 outColor = float4(mix(inColor.rgb, float3(mx), amt), inColor.a);
    outTexture.write(outColor, gid);
}
