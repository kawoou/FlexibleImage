//
//  NormalFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void NormalFilter(
                         texture2d<float, access::write> outTexture [[texture(0)]],
                         texture2d<float, access::read> inTexture [[texture(1)]],
                         const device float *colorRed [[buffer(0)]],
                         const device float *colorGreen [[buffer(1)]],
                         const device float *colorBlue [[buffer(2)]],
                         const device float *colorAlpha [[buffer(3)]],
                         uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    const float adjustAlpha = *colorAlpha;
    const float3 adjustColor = float3(*colorRed, *colorGreen, *colorBlue) * adjustAlpha;
    
    const float a = inColor.a + adjustAlpha * (1.0 - inColor.a);
    const float alphaDivisor = a + step(a, 0.0);
    
    const float4 outColor = float4((inColor.rgb * (1.0 - inColor.a) + adjustColor * inColor.a) / alphaDivisor, inColor.a);
    outTexture.write(outColor, gid);
}
