//
//  LevelInfoLayer.h
//  lele
//
//  Created by Michael Gao on 1/30/13.
//
//

#import "CCLayer.h"
#import "MainMenuScene.h"

@interface LevelInfoLayer : CCLayer

@property (nonatomic, weak) MainMenuScene *delegate;
-(void)showDescriptionForLevel:(int)levelNum;

@end
