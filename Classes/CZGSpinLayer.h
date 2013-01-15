//
//  CZGSpinLayer.h
//  word-game-3
//
//  Created by Garrett Christopher on 3/30/12.
//  Copyright (c) 2012 ZWorkbench, Inc. All rights reserved.
//

#import "cocos2d.h" 

@class CZGSpinLayer;

@protocol CZGSpinLayerDelegate <NSObject>

- (void) spinLayerDidFinishSpinning: (CZGSpinLayer *) spinLayer;

@optional 
- (BOOL) spinLayer: (CZGSpinLayer *) spinLayer canSpinToDivision: (int) division;
- (void) spinLayerDidRotate: (CZGSpinLayer *) spinLayer;
- (void) spinLayerPlayClick: (CZGSpinLayer *) spinLayer;

@end

@interface CZGSpinLayer : CCLayer

@property (nonatomic, strong) CCNode *contentNode;
@property (nonatomic, assign) NSUInteger divisions;
@property (nonatomic, assign) float spinOffsetRadians;
@property (nonatomic, readonly) int currentDivision;
@property (nonatomic, assign) float innerTouchRadius;
@property (nonatomic, assign) float outerTouchRadius;
@property (nonatomic, assign) BOOL autospin;

@property (nonatomic, assign) NSObject <CZGSpinLayerDelegate> *delegate;

- (void) spinToAngleRadians: (float) newAngle;
- (void) spinToSegment: (NSUInteger) segment;
- (float) radianRotationForDivision: (NSUInteger) division;

@end
