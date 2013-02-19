//
//  SumoFingerScene.m
//  lele
//
//  Created by Michael Gao on 1/22/13.
//
//

#import "SumoFingerScene.h"
#import "SumoFingerLayer.h"
#import "GameOverLayer.h"

@interface SumoFingerScene ()

@property (nonatomic, strong) SumoFingerLayer *gameLayer;
@property (nonatomic, strong) GameOverLayer *gameOverLayer;

@end

@implementation SumoFingerScene

-(id)init {
    self = [super init];
    if (self != nil) {
        self.gameLayer = [SumoFingerLayer node];
        self.gameLayer.delegate = self;
        [self addChild:self.gameLayer z:1];
        
        self.gameOverLayer = [GameOverLayer layerForSceneType:kSceneTypeSumoFinger];
        [self addChild:self.gameOverLayer z:5];
    }
    
    return self;
}

-(void)showGameOverLayerForWinner:(int)winnerNum {
    self.gameLayer.isTouchEnabled = NO;
    CCLayerColor *dimLayer = [CCLayerColor layerWithColor:ccc4(0,0,0,200)];
    [self addChild:dimLayer z:2];
    [self.gameOverLayer showLayerWithWinner:winnerNum];
}


@end
