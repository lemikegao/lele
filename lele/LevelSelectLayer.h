//
//  LevelSelectLayer.h
//  lele
//
//  Created by Michael Gao on 1/29/13.
//
//

#import "CCLayer.h"
#import "MainMenuScene.h"

@interface LevelSelectLayer : CCLayer

@property (nonatomic, weak) MainMenuScene *delegate;
@property (nonatomic, strong) CCMenu *levelsMenu;

@end
