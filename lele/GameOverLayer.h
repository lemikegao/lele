//
//  GameOverLayer.h
//  lele
//
//  Created by Michael Gao on 1/31/13.
//
//

#import "CCLayer.h"

@interface GameOverLayer : CCLayer

+(id)layerForSceneType:(SceneTypes)sceneType;
-(void)showLayerWithWinner:(int)winnerNum;

@end
