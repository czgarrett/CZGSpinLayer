//
//  HelloWorldLayer.h
//  CZGSpinLayerExample
//
//  Created by Christopher Garrett on 1/15/13.
//  Copyright ZWorkbench 2013. All rights reserved.
//


#import "CZGSpinLayer.h"

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <CZGSpinLayerDelegate>
{
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
