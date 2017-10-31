//
//  PinLightFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void PinLightFilter(
                           texture2d<float, access::write> outTexture [[texture(0)]],
                           texture2d<float, access::read> inTexture [[texture(1)]],
                           const device float *colorRed [[buffer(0)]],
                           const device float *colorGreen [[buffer(1)]],
                           const device float *colorBlue [[buffer(2)]],
                           const device float *colorAlpha [[buffer(3)]],
                           uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    const float4 adjustColor = float4(*colorRed, *colorGreen, *colorBlue, *colorAlpha);
    
    float ra;
    if (adjustColor.r < 0.5) {
        ra = min(2 * adjustColor.r, inColor.r);
    } else {
        ra = max(2 * (max(adjustColor.r, 0.5) - 0.5), inColor.r);
    }
    
    float ga;
    if (adjustColor.g < 0.5) {
        ga = min(2 * adjustColor.g, inColor.g);
    } else {
        ga = max(2 * (max(adjustColor.g, 0.5) - 0.5), inColor.g);
    }
    
    float ba;
    if (adjustColor.b < 0.5) {
        ba = min(2 * adjustColor.b, inColor.b);
    } else {
        ba = max(2 * (max(adjustColor.b, 0.5) - 0.5), inColor.b);
    }
    
    float aa;
    if (adjustColor.a < 0.5) {
        aa = min(2 * adjustColor.a, inColor.a);
    } else {
        aa = max(2 * (max(adjustColor.a, 0.5) - 0.5), inColor.a);
    }
    
    const float4 outColor = float4(ra, ga, ba, aa);
    outTexture.write(outColor, gid);
}
