//
//  SepiaFilter.metal
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void SepiaFilter(
                        texture2d<float, access::write> outTexture [[texture(0)]],
                        texture2d<float, access::read> inTexture [[texture(1)]],
                        uint2 gid [[thread_position_in_grid]])
{
    const float4 inColor = inTexture.read(gid);
    
    const float4 outColor = float4(
                                   inColor.r * 0.393 + inColor.g * 0.769 + inColor.b * 0.189,
                                   inColor.r * 0.349 + inColor.g * 0.686 + inColor.b * 0.168,
                                   inColor.r * 0.272 + inColor.g * 0.534 + inColor.b * 0.131,
                                   inColor.a);
    outTexture.write(outColor, gid);
}
