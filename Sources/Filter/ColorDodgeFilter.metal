//
//  ColorDodgeFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void ColorDodgeFilter(
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
    if (adjustColor.r == 1.0) {
        ra = 1.0;
    } else {
        ra = min(inColor.r / (1.0 - adjustColor.r), 1.0);
    }
    
    float ga;
    if (adjustColor.g == 1.0) {
        ga = 1.0;
    } else {
        ga = min(inColor.g / (1.0 - adjustColor.g), 1.0);
    }
    
    float ba;
    if (adjustColor.b == 1.0) {
        ba = 1.0;
    } else {
        ba = min(inColor.b / (1.0 - adjustColor.b), 1.0);
    }
    
    float aa;
    if (adjustColor.a == 1.0) {
        aa = 1.0;
    } else {
        aa = min(inColor.a / (1.0 - adjustColor.a), 1.0);
    }
    
        
    const float4 outColor = float4(ra, ga, ba, aa);
    outTexture.write(outColor, gid);
}

