//
//  MainMenuScene.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import "MainMenuScene.h"
#import "MainMenuLayer.h"
#import "LevelSelectLayer.h"
#import "LevelInfoLayer.h"

@interface MainMenuScene ()

@property (nonatomic, strong) LevelSelectLayer *levelSelectLayer;
@property (nonatomic, strong) LevelInfoLayer *levelInfoLayer;

@end

@implementation MainMenuScene

-(id)init {
    self = [super init];
    if (self != nil) {
//        MainMenuLayer *mainMenuLayer = [MainMenuLayer node];
        self.levelSelectLayer = [LevelSelectLayer node];
        self.levelSelectLayer.delegate = self;
        
        self.levelInfoLayer = [LevelInfoLayer node];
        self.levelInfoLayer.visible = NO;
        self.levelInfoLayer.delegate = self;
        
        [self addChild:self.levelSelectLayer];
        [self addChild:self.levelInfoLayer];
    }
    
    return self;
}

-(void)showDescriptionForLevel:(int)levelNum {
    [self.levelInfoLayer showDescriptionForLevel:levelNum];
    self.levelSelectLayer.levelsMenu.isTouchEnabled = NO;
    self.levelSelectLayer.visible = NO;
    self.levelInfoLayer.visible = YES;
}

-(void)hideDescription {
    self.levelInfoLayer.visible = NO;
    self.levelSelectLayer.visible = YES;
    self.levelSelectLayer.levelsMenu.isTouchEnabled = YES;
}

@end
