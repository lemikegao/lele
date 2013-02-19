//
//  TapBattleScene.m
//  lele
//
//  Created by Michael Gao on 1/31/13.
//
//

#import "TapAndSwitchScene.h"
#import "TapAndSwitchLayer.h"
#import "GameOverLayer.h"

@interface TapAndSwitchScene ()

@property (nonatomic, strong) TapAndSwitchLayer *gameLayer;
@property (nonatomic, strong) GameOverLayer *gameOverLayer;

@end

@implementation TapAndSwitchScene

-(id)init {
    self = [super init];
    if (self != nil) {
        self.gameLayer = [TapAndSwitchLayer node];
        self.gameLayer.delegate = self;
        [self addChild:self.gameLayer z:1];
        
        self.gameOverLayer = [GameOverLayer layerForSceneType:kSceneTypeTapAndSwitch];
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
