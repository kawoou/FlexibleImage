//
//  SaturationFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

float SaturationFilter_HueToRGB(float f1, float f2, float hue);
float3 SaturationFilter_HSLToRGB(float3 hsl);
float3 SaturationFilter_RGBToHSL(float3 color);

float SaturationFilter_HueToRGB(float f1, float f2, float hue) {
    if (hue < 0.0)
        hue += 1.0;
    else if (hue > 1.0)
        hue -= 1.0;
    
    float res;
    if ((6.0 * hue) < 1.0)
        res = f1 + (f2 - f1) * 6.0 * hue;
    else if ((2.0 * hue) < 1.0)
        res = f2;
    else if ((3.0 * hue) < 2.0)
        res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
    else
        res = f1;
    
    return res;
}

float3 SaturationFilter_HSLToRGB(float3 hsl) {
    float3 rgb;
    
    if (hsl.y == 0.0) {
        rgb = float3(hsl.z);
    } else {
        float f2;
        
        if (hsl.z < 0.5)
            f2 = hsl.z * (1.0 + hsl.y);
        else
            f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
        
        float f1 = 2.0 * hsl.z - f2;
        
        rgb.r = SaturationFilter_HueToRGB(f1, f2, hsl.x + (1.0/3.0));
        rgb.g = SaturationFilter_HueToRGB(f1, f2, hsl.x);
        rgb.b = SaturationFilter_HueToRGB(f1, f2, hsl.x - (1.0/3.0));
    }
    
    return rgb;
}

float3 SaturationFilter_RGBToHSL(float3 color) {
    float3 hsl;
    
    float fmin = min(min(color.r, color.g), color.b);
    float fmax = max(max(color.r, color.g), color.b);
    float delta = fmax - fmin;
    
    hsl.z = (fmax + fmin) / 2.0;
    
    if (delta == 0.0) {
        hsl.x = 0.0;
        hsl.y = 0.0;
    } else {
        if (hsl.z < 0.5)
            hsl.y = delta / (fmax + fmin);
        else
            hsl.y = delta / (2.0 - fmax - fmin);
        
        float deltaR = (((fmax - color.r) / 6.0) + (delta / 2.0)) / delta;
        float deltaG = (((fmax - color.g) / 6.0) + (delta / 2.0)) / delta;
        float deltaB = (((fmax - color.b) / 6.0) + (delta / 2.0)) / delta;
        
        if (color.r == fmax)
            hsl.x = deltaB - deltaG;
        else if (color.g == fmax)
            hsl.x = (1.0 / 3.0) + deltaR - deltaB;
        else if (color.b == fmax)
            hsl.x = (2.0 / 3.0) + deltaG - deltaR;
        
        if (hsl.x < 0.0)
            hsl.x += 1.0;
        else if (hsl.x > 1.0)
            hsl.x -= 1.0;
    }
    
    return hsl;
}

kernel void SaturationFilter(
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
    
    const float3 baseHSL = SaturationFilter_RGBToHSL(inColor.rgb);
    const float4 outColor = float4(SaturationFilter_HSLToRGB(float3(baseHSL.r, SaturationFilter_RGBToHSL(adjustColor.rgb).g, baseHSL.b)), inColor.a);
    outTexture.write(outColor, gid);
}
