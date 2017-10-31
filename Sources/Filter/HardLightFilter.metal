//
//  HardLightFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void HardLightFilter(
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
    if (2.0 * adjustColor.r < adjustColor.a) {
        ra = 2.0 * adjustColor.r * inColor.r + adjustColor.r * (1.0 - inColor.a) + inColor.r * (1.0 - adjustColor.a);
    } else {
        ra = adjustColor.a * inColor.a - 2.0 * (inColor.a - inColor.r) * (adjustColor.a - adjustColor.r) + adjustColor.r * (1.0 - inColor.a) + inColor.r * (1.0 - adjustColor.a);
    }
    
    float ga;
    if (2.0 * adjustColor.g < adjustColor.a) {
        ga = 2.0 * adjustColor.g * inColor.g + adjustColor.g * (1.0 - inColor.a) + inColor.g * (1.0 - adjustColor.a);
    } else {
        ga = adjustColor.a * inColor.a - 2.0 * (inColor.a - inColor.g) * (adjustColor.a - adjustColor.g) + adjustColor.g * (1.0 - inColor.a) + inColor.g * (1.0 - adjustColor.a);
    }
    
    float ba;
    if (2.0 * adjustColor.b < adjustColor.a) {
        ba = 2.0 * adjustColor.b * inColor.b + adjustColor.b * (1.0 - inColor.a) + inColor.b * (1.0 - adjustColor.a);
    } else {
        ba = adjustColor.a * inColor.a - 2.0 * (inColor.a - inColor.b) * (adjustColor.a - adjustColor.b) + adjustColor.b * (1.0 - inColor.a) + inColor.b * (1.0 - adjustColor.a);
    }
    
    const float4 outColor = float4(ra, ga, ba, 1.0);
    outTexture.write(outColor, gid);
}
