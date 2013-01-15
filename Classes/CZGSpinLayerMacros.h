//
//  CZGSpinLayerMacros.h
//  CZGSpinLayerExample
//
//  Created by Christopher Garrett on 1/15/13.
//  Copyright (c) 2013 ZWorkbench. All rights reserved.
//

#ifndef CZGSpinLayerExample_CZGSpinLayerMacros_h
#define CZGSpinLayerExample_CZGSpinLayerMacros_h

struct _PolarCoordinate {
    CGFloat r;
    CGFloat theta;
};
typedef struct _PolarCoordinate PolarCoordinate;

union _CZGCoordinate {
    struct {
        CGFloat r;
        CGFloat theta;
    };
    struct {
        CGFloat x;
        CGFloat y;
    };
    CGPoint point;
};
typedef union _CZGCoordinate CZGCoordinate;

CG_INLINE float
CGSignedAngleDegrees(float angle) {
    float result = angle;
    while (result > 180.0) result -=360.0;
    while (result < -180.0) result += 360.0;
    return result;
}

CG_INLINE float
CGSignedAngleRadians(float angle) {
    float result = angle;
    while (result > M_PI) result -= M_PI*2;
    while (result < -M_PI) result += M_PI*2;
    return result;
}

#define DEGREES_TO_RADIANS(x) ((x)*M_PI/180.0)
#define RADIANS_TO_DEGREES(x) ((x)*180.0/M_PI)
#define CGPointMakePolar(r,theta) CGPointMake((r)*cosf(theta), (r)*sinf(theta))

#endif
