//
//  CZGSpinLayer.m
//  word-game-3
//
//  Created by Garrett Christopher on 3/30/12.
//  Copyright (c) 2012 ZWorkbench, Inc. All rights reserved.
//

#import "CZGSpinLayer.h"
#import "Constants.h"
#import "Macros.h"
#import "GameAudio.h"

#import "WordGameAppDelegate.h"

#define SPIN_DECELERATION 0.1
#define MIN_MOVEMENTS_FOR_MOMENTUM 3
#define MOVEMENT_FILTER (1.0/MIN_MOVEMENTS_FOR_MOMENTUM)

#define AUTOSPIN_TIME_INTERVAL 9.0

@interface CZGSpinLayer() {
   BOOL _spinning;
   BOOL _touchMoved;
   CGFloat _spinDr;
   NSTimeInterval _spinDt;
   NSInteger _movementCount;
   NSTimeInterval _previousTouchTimestamp;
   NSInteger _previousClickTime;
   BOOL _playedFirstSpinClick;
    BOOL _checkedWhetherCurrentSpinDivisionIsOkay;
    ccTime _autospinTime;
}

@property (nonatomic, assign) UIEvent *spinningEvent;

@property (nonatomic, assign) float touchStartAngle;
@property (nonatomic, assign) float previousTouchAngle;
@property (nonatomic, assign) float contentStartAngle;


@property (nonatomic, assign) float spinTo;

- (CZGCoordinate) polarCoordinateForTouch: (UITouch *)touch;
- (void) playClick;
- (NSUInteger) divisionForRotationDegrees: (float) rotation;
- (float) radianRotationForDivision: (NSUInteger) division;

@end

@implementation CZGSpinLayer

// public
@synthesize contentNode = _contentNode, divisions = _divisions, spinOffsetRadians = _spinOffsetRadians, currentDivision = _currentDivision, delegate = _delegate,
innerTouchRadius= _innerTouchRadius, outerTouchRadius = _outerTouchRadius, autospin = _autospin;
// private
@synthesize spinningEvent = _spinningEvent, 
            touchStartAngle = _touchStartAngle, previousTouchAngle = _previousTouchAngle, spinTo = _spinTo, contentStartAngle = _contentStartAngle;

#pragma mark
#pragma mark Constructors

- (void) dealloc {
    _contentNode = nil;
}

- (id)init
{
   self = [super init];
   if (self) {
       _checkedWhetherCurrentSpinDivisionIsOkay = YES;
       _autospin = NO;
      self.isTouchEnabled = YES;
      self.ignoreAnchorPointForPosition = NO;
      self.contentNode = [CCNode node];
      self.divisions = 53;
      _contentNode.anchorPoint = ccp(0.5, 0.5);
      [self addChild: _contentNode];
      [self scheduleUpdate];
      _currentDivision = 0;
      
   }
   return self;
}


#pragma mark
#pragma mark Inherited

- (void)onEnter
{
   [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:-2 swallowsTouches:YES];
    self.innerTouchRadius = 0.0;
    self.outerTouchRadius = MIN(self.contentSize.width/2, self.contentSize.height/2);

   [super onEnter];
}

#pragma mark scrolling support

- (void) spinToSegment: (NSUInteger) segment {
   [self spinToAngleRadians: [self radianRotationForDivision: segment]];
}


- (void) spinToAngleRadians: (float) newAngle {
    int delta = 0;
    int startingDivision = [self divisionForRotationDegrees: 180.0*newAngle / M_PI];
    BOOL foundClosest = NO;
    int closestDivision = startingDivision;
    while (self.delegate && !foundClosest && delta < (_divisions/2 + 1)) {
        if ([self.delegate spinLayer: self canSpinToDivision: (startingDivision + delta) % _divisions]) {
            foundClosest = YES;
            closestDivision = (startingDivision + delta) % _divisions;
        }
        if (!foundClosest && [self.delegate spinLayer: self canSpinToDivision: (startingDivision - delta + _divisions) % _divisions]) {
            foundClosest = YES;
            closestDivision = (startingDivision - delta) % _divisions;
        }
        delta++;
    }
    float newSpinToDelta = [self radianRotationForDivision: closestDivision] - _spinTo;
    float shorterDelta = CGSignedAngleRadians(newSpinToDelta);
    float newSpinTo = _spinTo + shorterDelta;
    if (newSpinTo != _spinTo) {
        _spinTo = newSpinTo;
        _spinning = YES;
    }
}

- (float) radianRotationForDivision: (NSUInteger) division {
   return -(2.0 * M_PI * division) / _divisions + _spinOffsetRadians;
}

- (NSUInteger) divisionForRotationDegrees: (float) rotation {
   // signed angle goes from -180 to +180
   // signed relative angle goes from -0.5 to +0.5
   // So we add 1.0 so that it goes from 0.5 to 1.5
   float relativeAngle = 1.0 + CGSignedAngleDegrees(-rotation + RADIANS_TO_DEGREES(_spinOffsetRadians))/360.0;
   return ((NSUInteger)(0.5 + relativeAngle*_divisions)) % _divisions;
   //return ((NSUInteger)(relativeAngle*_divisions)) % _divisions;
}

- (NSUInteger) calculateDivisionForCurrentRotation {
   return [self divisionForRotationDegrees: _contentNode.rotation];
}

-(void) update: (ccTime) dt {
    if (_autospin) {
        _autospinTime += dt;
        if (_autospinTime > AUTOSPIN_TIME_INTERVAL) {
            _autospinTime = 0.0;
            int division = (_currentDivision + 1) % _divisions;
            while (![self.delegate spinLayer: self canSpinToDivision: division] && division != _currentDivision) {
                division = (division + 1) % _divisions;
            }
            if (division != _currentDivision) {
                [self spinToSegment: division];
            }
        }
    }
    if (_spinning) {
        float spinToDegrees = RADIANS_TO_DEGREES(_spinTo);
        float spinDiff = spinToDegrees - self.contentNode.rotation;
        if (abs(spinDiff) < 0.1) {
            //NSLog(@"Final content node rotation = %f (%f degrees)", _spinTo, spinToDegrees);
            _contentNode.rotation = spinToDegrees;
            NSUInteger newDivision = [self calculateDivisionForCurrentRotation];
            _currentDivision = newDivision;
            _spinning = NO;
            if (!self.spinningEvent) {
                [self playClick];
                if (self.delegate) {
                    [self.delegate spinLayerDidFinishSpinning: self];
                }
            } else if (self.delegate && [self.delegate respondsToSelector: @selector(spinLayerDidRotate:)]) {
                [self.delegate spinLayerDidRotate: self];
            }
        } else {
            _contentNode.rotation = _contentNode.rotation + spinDiff * SPIN_DECELERATION;
            NSUInteger newDivision = [self calculateDivisionForCurrentRotation];
            if (newDivision != _currentDivision) {
                [self playClick];
                _currentDivision = newDivision;
            }
            if (self.delegate && [self.delegate respondsToSelector: @selector(spinLayerDidRotate:)]) {
                [self.delegate spinLayerDidRotate: self];
            }
        }
    }
}


#pragma mark
#pragma mark Protocols


#pragma mark CCTargetedTouchDelegate classes

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
   CZGCoordinate coord = [self polarCoordinateForTouch: touch];
   _touchMoved = NO;
   if (coord.r <= self.outerTouchRadius && coord.r >= self.innerTouchRadius && self.visible) {
       _autospin = NO;
      _playedFirstSpinClick = NO;
      self.contentStartAngle = DEGREES_TO_RADIANS(self.contentNode.rotation);
      self.spinningEvent = event;
      self.touchStartAngle = coord.theta;
      self.previousTouchAngle = coord.theta;
      _previousTouchTimestamp = touch.timestamp;
      _spinDr = 0;
      _spinDt = 0;
      _movementCount = 0;
      return YES;
   } else {
      return NO;
   }
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
   _touchMoved = YES;
   if (self.spinningEvent) {
      if (!_playedFirstSpinClick) {
         [self playClick];
         _playedFirstSpinClick = YES;
      }
      _spinning = YES;
      CZGCoordinate coord = [self polarCoordinateForTouch: touch];
      float spinDiff = CGSignedAngleRadians(coord.theta - self.previousTouchAngle);
      _spinTo = _spinTo + spinDiff; 
      //NSLog(@"touchesMoved, _spinTo = %f", _spinTo);
      // Smooth dx, dy, and dt by averaging movements
      _spinDt = _spinDt*(1-MOVEMENT_FILTER) + (touch.timestamp - _previousTouchTimestamp) * MOVEMENT_FILTER;
      _spinDr = _spinDr*(1-MOVEMENT_FILTER) + spinDiff * MOVEMENT_FILTER;
      _previousTouchTimestamp = touch.timestamp;
      _movementCount++;
      
      self.previousTouchAngle = coord.theta;
   } 
}

- (void)ccTouchEnded: (UITouch *) touch withEvent:(UIEvent *)event {
   float movement = 0.0;
   if (event == self.spinningEvent) {
      if (_touchMoved) {
         if (_spinDt>0 && _movementCount>=MIN_MOVEMENTS_FOR_MOMENTUM && touch.timestamp - _previousTouchTimestamp < 0.25) {
            movement = 0.25*_spinDr/_spinDt;
         }
         [self spinToAngleRadians: movement + DEGREES_TO_RADIANS(_contentNode.rotation)];
      } else {
         // Single tap
         CGPoint touchStartPosition = [self convertTouchToNodeSpace: touch];
         CGPoint center = ccp(self.contentSize.width/2.0, self.contentSize.height/2.0);
         CGPoint diff = ccpSub(touchStartPosition, center);
         float theta = -atan2f(diff.y, diff.x); // switch from counterclockwise to clockwise theta to be consistent with CCNode
         //float newTheta = CGSignedAngleRadians(_spinTo - theta - _spinOffsetRadians);
          float newTheta = _spinTo - theta + _spinOffsetRadians;
         NSLog(@"Theta = %f, _spinTo = %f, spinning to %f", theta, _spinTo, newTheta);
         [self spinToAngleRadians: newTheta];
      }
      self.spinningEvent = nil;
   }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
   [self ccTouchEnded: touch withEvent: event];
}

#pragma mark
#pragma mark Public

#pragma mark
#pragma mark Dynamic

#pragma mark
#pragma mark Actions

#pragma mark
#pragma mark Private

- (void) playClick {
   NSTimeInterval clickTime = [NSDate timeIntervalSinceReferenceDate];
   if (clickTime - _previousClickTime > 0.1) {
      [[WordGameAppDelegate sharedInstance].audio playClick];
      _previousClickTime = clickTime;
   }
}

- (CZGCoordinate) polarCoordinateForTouch: (UITouch *)touch {
   CGPoint touchStartPosition = [self convertTouchToNodeSpace: touch];
   //NSLog(@"Touch at %@", NSStringFromCGPoint(touchStartPosition));
   CGPoint center = ccp(self.contentSize.width/2.0, self.contentSize.height/2.0);
   CGPoint diff = ccpSub(touchStartPosition, center);
   CZGCoordinate result;
   result.theta = -atan2f(diff.y, diff.x); // switch from counterclockwise to clockwise theta to be consistent with CCNode
   result.r = ccpDistance(touchStartPosition, center);
   return result;
}


@end
