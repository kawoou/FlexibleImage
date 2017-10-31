//
//  VividLightFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void VividLightFilter(
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
        if (adjustColor.r == 0.0) {
            ra = 0.0;
        } else {
            ra = max((1.0 - ((1.0 - inColor.r) / adjustColor.r)), 0.0);
        }
    } else {
        if (adjustColor.r == 1.0) {
            ra = 1.0;
        } else {
            ra = min(inColor.r / (1.0 - adjustColor.r), 1.0);
        }
    }
    
    float ga;
    if (adjustColor.g < 0.5) {
        if (adjustColor.g == 0.0) {
            ga = 0.0;
        } else {
            ga = max((1.0 - ((1.0 - inColor.g) / adjustColor.g)), 0.0);
        }
    } else {
        if ((2 * (adjustColor.g - 0.5)) == 1.0) {
            ga = 1.0;
        } else {
            ga = min(inColor.g / (1.0 - adjustColor.g), 1.0);
        }
    }
    
    float ba;
    if (adjustColor.b < 0.5) {
        if (adjustColor.b == 0.0) {
            ba = 0.0;
        } else {
            ba = max((1.0 - ((1.0 - inColor.b) / adjustColor.b)), 0.0);
        }
    } else {
        if ((2 * (adjustColor.b - 0.5)) == 1.0) {
            ba = 1.0;
        } else {
            ba = min(inColor.b / (1.0 - adjustColor.b), 1.0);
        }
    }
    
    float aa;
    if (adjustColor.a < 0.5) {
        if (adjustColor.a == 0.0) {
            aa = 0.0;
        } else {
            aa = max((1.0 - ((1.0 - inColor.a) / adjustColor.a)), 0.0);
        }
    } else {
        if ((2 * (adjustColor.a - 0.5)) == 1.0) {
            aa = 1.0;
        } else {
            aa = min(inColor.a / (1.0 - adjustColor.a), 1.0);
        }
    }
    
    const float4 outColor = float4(ra, ga, ba, aa);
    outTexture.write(outColor, gid);
}
