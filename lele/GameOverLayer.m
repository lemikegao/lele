//
//  GameOverLayer.m
//  lele
//
//  Created by Michael Gao on 1/31/13.
//
//

#import "GameOverLayer.h"
#import "CCTouchDownMenu.h"
#import "GameManager.h"

@interface GameOverLayer ()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCLabelBMFont *winnerLabel;

@end

@implementation GameOverLayer

+(id)layerForSceneType:(SceneTypes)sceneType {
    return [[self alloc] initForSceneType:sceneType];
}

-(id)initForSceneType:(SceneTypes)sceneType {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.visible = NO;
        
        [self initStructureForSceneType:sceneType];
    }
    
    return self;
}

-(void)initStructureForSceneType:(SceneTypes)sceneType {
    self.winnerLabel = [CCLabelBMFont labelWithString:@"Player # Wins!" fntFile:@"nexabold_80px.fnt"];
    self.winnerLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.6);
    [self addChild:self.winnerLabel];
    
    CCMenuItem *mainMenuButton = [CCMenuItemImage itemWithNormalImage:@"gameover_button_mainmenu.png" selectedImage:nil block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    mainMenuButton.anchorPoint = ccp(1, 0.5);
    mainMenuButton.position = ccp(self.screenSize.width * 0.51, self.screenSize.height * 0.45);
    
    CCMenuItem *playAgainButton = [CCMenuItemImage itemWithNormalImage:@"gameover_button_playagain.png" selectedImage:nil block:^(id sender) {
        [[GameManager sharedGameManager] runSceneWithID:sceneType];
    }];
    playAgainButton.anchorPoint = ccp(0, 0.5);
    playAgainButton.position = ccp(self.screenSize.width * 0.52, mainMenuButton.position.y);
    
    CCMenu *gameOverMenu = [CCTouchDownMenu menuWithItems:mainMenuButton, playAgainButton, nil];
    gameOverMenu.anchorPoint = ccp(0,0);
    gameOverMenu.position = ccp(0,0);
    [self addChild:gameOverMenu];
}

-(void)showLayerWithWinner:(int)winnerNum {
    self.winnerLabel.string = [NSString stringWithFormat:@"Player %i Wins!", winnerNum];
    
    if (winnerNum == 1) {
        self.winnerLabel.color = player1Color;
    } else if (winnerNum == 2) {
        self.winnerLabel.color = player2Color;
    }
    
    self.visible = YES;
}

@end
