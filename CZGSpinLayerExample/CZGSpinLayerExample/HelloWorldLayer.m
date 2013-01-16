//
//  HelloWorldLayer.m
//  CZGSpinLayerExample
//
//  Created by Christopher Garrett on 1/15/13.
//  Copyright ZWorkbench 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Spin Me" fontName:@"Marker Felt" fontSize:64];
        label.color = ccc3(255,255,255);
		// position the label on the center of the spin layer
		label.position =  ccp(0,0);

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];

        CZGSpinLayer *spinLayer = [CZGSpinLayer node];
        spinLayer.position = ccp(size.width/2, size.height/2);
        spinLayer.contentSize = CGSizeMake(768.0, 768.0);
        spinLayer.contentNode.position = ccp(384,384);
        spinLayer.divisions = 4;
        spinLayer.spinOffsetRadians = 0.0;
        
        spinLayer.delegate = self;

		
		// add the label as a child to this Layer
        [self addChild: spinLayer];
        // Important:  add the item you want to spin to the spin layer's content node.
		[spinLayer.contentNode addChild: label];
        
        //label.position = ccp(size.width/2, size.height/2);
		//[self addChild: label];
		
		
    }
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark CZGSpinLayerDelegate methods

- (void) spinLayerDidFinishSpinning: (CZGSpinLayer *) spinLayer {
    
}

- (BOOL) spinLayer: (CZGSpinLayer *) spinLayer canSpinToDivision: (int) division {
    return YES;
}

- (void) spinLayerDidRotate: (CZGSpinLayer *) spinLayer {
    
}

- (void) spinLayerPlayClick: (CZGSpinLayer *) spinLayer {
    
}


@end
