//
//  GameScene.m
//  lele
//
//  Created by Michael Gao on 12/27/12.
//
//

#import "RainingColorsScene.h"
#import "RainingColorsLayer.h"
#import "GameOverLayer.h"

@interface RainingColorsScene ()

@property (nonatomic, strong) RainingColorsLayer *gameLayer;
@property (nonatomic, strong) GameOverLayer *gameOverLayer;

@end

@implementation RainingColorsScene

-(id)init {
    self = [super init];
    if (self != nil) {
        self.gameLayer = [RainingColorsLayer node];
        self.gameLayer.delegate = self;
        [self addChild:self.gameLayer z:1];
        
        self.gameOverLayer = [GameOverLayer layerForSceneType:kSceneTypeRainingColors];
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
