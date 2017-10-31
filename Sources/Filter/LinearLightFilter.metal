//
//  LinearLightFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void LinearLightFilter(
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
        ra = max(inColor.r + 2 * adjustColor.r - 1.0, 0.0);
    } else {
        ra = min(2 * (adjustColor.r - 0.5) + inColor.r, 1.0);
    }
    
    float ga;
    if (adjustColor.g < 0.5) {
        ga = max(inColor.g + 2 * adjustColor.g - 1.0, 0.0);
    } else {
        ga = min(2 * (adjustColor.g - 0.5) + inColor.g, 1.0);
    }
    
    float ba;
    if (adjustColor.b < 0.5) {
        ba = max(inColor.b + 2 * adjustColor.b - 1.0, 0.0);
    } else {
        ba = min(2 * (adjustColor.b - 0.5) + inColor.b, 1.0);
    }
    
    float aa;
    if (adjustColor.a < 0.5) {
        aa = max(inColor.a + 2 * adjustColor.a - 1.0, 0.0);
    } else {
        aa = min(2 * (adjustColor.a - 0.5) + inColor.a, 1.0);
    }
    
    const float4 outColor = float4(ra, ga, ba, aa);
    outTexture.write(outColor, gid);
}
