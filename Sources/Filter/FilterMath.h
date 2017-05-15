//
//  FilterMath.h
//  Test Project
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#pragma once
using namespace metal;

float HueToRGB(float f1, float f2, float hue);
float3 HSLToRGB(float3 hsl);
float3 RGBToHSL(float3 color);
