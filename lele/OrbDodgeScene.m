//
//  OrbDodgeScene.m
//  lele
//
//  Created by Michael Gao on 1/26/13.
//
//

#import "OrbDodgeScene.h"
#import "OrbDodgeLayer.h"
#import "GameOverLayer.h"

@interface OrbDodgeScene ()

@property (nonatomic, strong) OrbDodgeLayer *gameLayer;
@property (nonatomic, strong) GameOverLayer *gameOverLayer;

@end

@implementation OrbDodgeScene

-(id)init {
    self = [super init];
    if (self != nil) {
        self.gameLayer = [OrbDodgeLayer node];
        self.gameLayer.delegate = self;
        [self addChild:self.gameLayer z:1];
        
        self.gameOverLayer = [GameOverLayer layerForSceneType:kSceneTypeOrbDodge];
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
