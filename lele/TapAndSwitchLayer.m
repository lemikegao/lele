//
//  TapBattleLayer.m
//  lele
//
//  Created by Michael Gao on 1/31/13.
//
//

#import "TapAndSwitchLayer.h"

@interface TapAndSwitchLayer ()

@property (nonatomic) CGSize screenSize;
@property (nonatomic) GameStates currentGameState;
@property (nonatomic, strong) CCLayerColor *player1ColorSpace;
@property (nonatomic, strong) CCLayerColor *player2ColorSpace;
@property (nonatomic, strong) CCSprite *player1TapSpace;
@property (nonatomic, strong) CCSprite *player2TapSpace;
@property (nonatomic, strong) CCSprite *player1TapSpaceInnerCircle;
@property (nonatomic, strong) CCSprite *player2TapSpaceInnerCircle;
@property (nonatomic, strong) CCSprite *player1Switch;
@property (nonatomic, strong) CCSprite *player2Switch;
@property (nonatomic) int player1SwitchNum;
@property (nonatomic) int player2SwitchNum;
@property (nonatomic, strong) CCSpriteBatchNode *playerSwitchesBatchNode;
@property (nonatomic, strong) NSMutableArray *player1SwitchSprites;
@property (nonatomic, strong) NSMutableArray *player2SwitchSprites;
@property (nonatomic) BOOL areColorsSwapped;
@property (nonatomic) float moveIncrement;
@property (nonatomic) BOOL isPlayer1FingerOnScreen;
@property (nonatomic) BOOL isPlayer2FingerOnScreen;
@property (nonatomic, strong) UITouch *player1Touch;
@property (nonatomic, strong) UITouch *player2Touch;
@property (nonatomic) int timeToPlay;
@property (nonatomic, strong) CCLabelTTF *timerLabel;

@end

@implementation TapAndSwitchLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"TapBattleLayer.m->init");
        self.isTouchEnabled = YES;
        self.areColorsSwapped = NO;
        self.isPlayer1FingerOnScreen = NO;
        self.isPlayer2FingerOnScreen = NO;
        self.currentGameState = kGameStateNone;
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.moveIncrement = 10;
        
        [self initPlayerColorSpaces];
        [self initPlayerTapSpaces];
        [self initSwitches];
    }
    
    return self;
}

-(void)initPlayerColorSpaces {
    ccColor4B player1ColorSpaceColor = ccc4(132, 40, 91, 255);
    ccColor4B player2ColorSpaceColor = ccc4(51, 124, 51, 255);
    self.player1ColorSpace = [CCLayerColor layerWithColor:player1ColorSpaceColor];
    self.player2ColorSpace = [CCLayerColor layerWithColor:player2ColorSpaceColor];
    self.player1ColorSpace.position = ccp(-self.screenSize.width * 0.5, 0);
    self.player2ColorSpace.position = ccp(self.screenSize.width * 0.5, 0);
    
    [self addChild:self.player1ColorSpace];
    [self addChild:self.player2ColorSpace];
}

-(void)initPlayerTapSpaces {
    self.player1TapSpace = [CCSprite spriteWithFile:@"circle_outer.png"];
    self.player1TapSpace.color = ccc3(206, 46, 134);
    self.player1TapSpace.position = ccp(self.screenSize.width * 0.25, self.screenSize.height * 0.5);
    self.player1TapSpace.opacity = 128;
    
    self.player1TapSpaceInnerCircle = [CCSprite spriteWithFile:@"circle_outer.png"];
    self.player1TapSpaceInnerCircle.color = ccc3(206, 46, 134);
    self.player1TapSpaceInnerCircle.position = ccp(self.player1TapSpace.contentSize.width * 0.5, self.player1TapSpace.contentSize.height * 0.5);
    self.player1TapSpaceInnerCircle.scale = 0.40;
    
    [self.player1TapSpace addChild:self.player1TapSpaceInnerCircle];
    [self addChild:self.player1TapSpace z:100];
    
    [self.player1TapSpaceInnerCircle runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.50 scale:0.80], [CCScaleTo actionWithDuration:0.50 scale:0.40], nil]]];
    
    self.player2TapSpace = [CCSprite spriteWithFile:@"circle_outer.png"];
    self.player2TapSpace.color = player2Color;
    self.player2TapSpace.position = ccp(self.screenSize.width * 0.75, self.screenSize.height * 0.5);
    self.player2TapSpace.opacity = 128;
    
    self.player2TapSpaceInnerCircle = [CCSprite spriteWithFile:@"circle_outer.png"];
    self.player2TapSpaceInnerCircle.color = player2Color;
    self.player2TapSpaceInnerCircle.position = ccp(self.player2TapSpace.contentSize.width * 0.5, self.player2TapSpace.contentSize.height * 0.5);
    self.player2TapSpaceInnerCircle.scale = 0.40;
    
    [self.player2TapSpace addChild:self.player2TapSpaceInnerCircle];
    [self addChild:self.player2TapSpace z:100];
    
    [self.player2TapSpaceInnerCircle runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.50 scale:0.80], [CCScaleTo actionWithDuration:0.50 scale:0.40], nil]]];
}

-(void)initSwitches {
    self.player1Switch = [CCSprite spriteWithFile:@"switch_circle_dashed.png"];
    self.player1Switch.color = ccc3(206, 46, 134);
    self.player1Switch.anchorPoint = ccp(0, 1);
    self.player1Switch.position = ccp(10, self.screenSize.height * 0.98);
    
    CCSprite *innerCircle1 = [CCSprite spriteWithFile:@"circle_outer.png"];
    innerCircle1.color = ccc3(206, 46, 134);
    innerCircle1.position = ccp(self.player1Switch.contentSize.width * 0.5, self.player1Switch.contentSize.height * 0.5);
    innerCircle1.scale = 0.30;
    
    [self.player1Switch addChild:innerCircle1];
    [self addChild:self.player1Switch z:100];
    
    self.player2Switch = [CCSprite spriteWithFile:@"switch_circle_dashed.png"];
    self.player2Switch.color = player2Color;
    self.player2Switch.anchorPoint = ccp(1, 0);
    self.player2Switch.position = ccp(self.screenSize.width - 10, self.screenSize.height * 0.02);
    
    CCSprite *innerCircle2 = [CCSprite spriteWithFile:@"circle_outer.png"];
    innerCircle2.color = player2Color;
    innerCircle2.position = ccp(self.player2Switch.contentSize.width * 0.5, self.player2Switch.contentSize.height * 0.5);
    innerCircle2.scale = 0.30;
    
    [self.player2Switch addChild:innerCircle2];
    [self addChild:self.player2Switch z:100];
    
    // add switch label above switch sprites
    CCLabelBMFont *player1SwitchLabel = [CCLabelBMFont labelWithString:@"SWITCH" fntFile:@"nexalight_30px.fnt"];
    player1SwitchLabel.color = ccc3(206, 46, 134);
    player1SwitchLabel.rotation = 90;
    player1SwitchLabel.anchorPoint = ccp(0.5, 0);
    player1SwitchLabel.position = ccp(self.player1Switch.position.x + self.player1Switch.contentSize.width * 0.98, self.player1Switch.position.y - self.player1Switch.contentSize.height * 0.5);
    [self addChild:player1SwitchLabel z:100];
    
    CCLabelBMFont *player2SwitchLabel = [CCLabelBMFont labelWithString:@"SWITCH" fntFile:@"nexalight_30px.fnt"];
    player2SwitchLabel.color = player2Color;
    player2SwitchLabel.rotation = -90;
    player2SwitchLabel.anchorPoint = ccp(0.5, 0);
    player2SwitchLabel.position = ccp(self.player2Switch.position.x - self.player2Switch.contentSize.width * 0.98, self.player2Switch.position.y + self.player2Switch.contentSize.height * 0.5);
    [self addChild:player2SwitchLabel z:100];
    
    self.player1SwitchNum = 3;
    self.player2SwitchNum = 3;
    self.playerSwitchesBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"lives.png"];
    self.player1SwitchSprites = [[NSMutableArray alloc] initWithCapacity:self.player1SwitchNum];
    self.player2SwitchSprites = [[NSMutableArray alloc] initWithCapacity:self.player2SwitchNum];
    
    CCLabelBMFont *player1SwitchesLabel = [CCLabelBMFont labelWithString:@"Switches Left" fntFile:@"nexalight_26px.fnt"];
    player1SwitchesLabel.color = ccc3(206, 46, 134);
    player1SwitchesLabel.anchorPoint = ccp(1, 0);
    player1SwitchesLabel.rotation = 90;
    player1SwitchesLabel.position = ccp(10, self.screenSize.height * 0.03);
    [self addChild:player1SwitchesLabel];
    
    for (int i=0; i<self.player1SwitchNum; i++) {
        CCSprite *switchSprite = [CCSprite spriteWithFile:@"lives.png"];
        switchSprite.color = ccc3(206, 46, 134);
        switchSprite.opacity = 150;
        switchSprite.anchorPoint = ccp(0, 1);
        switchSprite.position = ccp(player1SwitchesLabel.position.x, player1SwitchesLabel.position.y + player1SwitchesLabel.contentSize.width + switchSprite.contentSize.height * 1.4 + i*switchSprite.contentSize.height*1.3);
        [self.playerSwitchesBatchNode addChild:switchSprite];
        [self.player1SwitchSprites addObject:switchSprite];
    }
    
    CCLabelBMFont *player2SwitchesLabel = [CCLabelBMFont labelWithString:@"Switches Left" fntFile:@"nexalight_26px.fnt"];
    player2SwitchesLabel.color= player2Color;
    player2SwitchesLabel.anchorPoint = ccp(1, 0);
    player2SwitchesLabel.rotation = -90;
    player2SwitchesLabel.position = ccp(self.screenSize.width - 10, self.screenSize.height * 0.97);
    [self addChild:player2SwitchesLabel];
    
    for (int i=0; i<self.player2SwitchNum; i++) {
        CCSprite *switchSprite = [CCSprite spriteWithFile:@"lives.png"];
        switchSprite.color = player2Color;
        switchSprite.opacity = 150;
        switchSprite.anchorPoint = ccp(1, 1);
        switchSprite.position = ccp(player2SwitchesLabel.position.x, player2SwitchesLabel.position.y - player2SwitchesLabel.contentSize.width - switchSprite.contentSize.height*0.4 - i*switchSprite.contentSize.height*1.3);
        [self.playerSwitchesBatchNode addChild:switchSprite];
        [self.player2SwitchSprites addObject:switchSprite];
    }
    
    [self addChild:self.playerSwitchesBatchNode];
}

-(void)enlargeTapSpaceInnerCircleForCountdownForPlayer:(int)playerNum {
    if (playerNum == 1) {
        [self.player1TapSpaceInnerCircle stopAllActions];
        self.player1TapSpaceInnerCircle.scale = 0.1;
        [self.player1TapSpaceInnerCircle runAction:[CCScaleTo actionWithDuration:0.35 scale:1]];
    } else if (playerNum == 2) {
        [self.player2TapSpaceInnerCircle stopAllActions];
        self.player2TapSpaceInnerCircle.scale = 0.1;
        [self.player2TapSpaceInnerCircle runAction:[CCScaleTo actionWithDuration:0.35 scale:1]];
    }
}

-(void)resetTapSpaceInnerCircleForPlayer:(int)playerNum {
    if (playerNum == 1) {
        [self.player1TapSpaceInnerCircle stopAllActions];
        self.player1TapSpaceInnerCircle.scale = 0.4;
        [self.player1TapSpaceInnerCircle runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.50 scale:0.80], [CCScaleTo actionWithDuration:0.50 scale:0.40], nil]]];
    } else if (playerNum == 2) {
        [self.player2TapSpaceInnerCircle stopAllActions];
        self.player2TapSpaceInnerCircle.scale = 0.4;
        [self.player2TapSpaceInnerCircle runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.50 scale:0.80], [CCScaleTo actionWithDuration:0.50 scale:0.40], nil]]];
    }
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        if (self.currentGameState == kGameObjectTypeNone) {
            if (self.isPlayer1FingerOnScreen == NO) {
                if (CGRectContainsPoint(self.player1TapSpace.boundingBox, location)) {
                    CCLOG(@"player 1 is ready");
                    self.isPlayer1FingerOnScreen = YES;
                    self.player1Touch = touch;
                    
                    [self enlargeTapSpaceInnerCircleForCountdownForPlayer:1];
                    
                    // start game if player 2 is ready
                    if (self.isPlayer2FingerOnScreen == YES && self.currentGameState == kGameStateNone) {
                        [self startCountdown];
                    }
                }
            }
            
            // check if player 2 is ready
            if (self.isPlayer2FingerOnScreen == NO) {
                if (CGRectContainsPoint(self.player2TapSpace.boundingBox, location)) {
                    CCLOG(@"player 2 is ready");
                    self.isPlayer2FingerOnScreen = YES;
                    self.player2Touch = touch;
                    
                    [self enlargeTapSpaceInnerCircleForCountdownForPlayer:2];
                    
                    // start game if player 1 is ready
                    if (self.isPlayer1FingerOnScreen == YES && self.currentGameState == kGameStateNone) {
                        [self startCountdown];
                    }
                }
            }

        } else if (self.currentGameState == kGameStatePlay) {
            if (CGRectContainsPoint(self.player1TapSpace.boundingBox, location)) {
                self.player1ColorSpace.position = ccpAdd(self.player1ColorSpace.position, ccp(self.moveIncrement, 0));
                self.player2ColorSpace.position = ccpAdd(self.player2ColorSpace.position, ccp(self.moveIncrement, 0));
            } else if (CGRectContainsPoint(self.player2TapSpace.boundingBox, location)) {
                self.player1ColorSpace.position = ccpSub(self.player1ColorSpace.position, ccp(self.moveIncrement, 0));
                self.player2ColorSpace.position = ccpSub(self.player2ColorSpace.position, ccp(self.moveIncrement, 0));
            } else if (CGRectContainsPoint(self.player1Switch.boundingBox, location)) {
                if (self.player1SwitchNum > 0) {
                    [self activateSwitchFromPlayer:1];
                }
            } else if (CGRectContainsPoint(self.player2Switch.boundingBox, location)) {
                if (self.player2SwitchNum > 0) {
                    [self activateSwitchFromPlayer:2];
                }
            }
            
            if (self.areColorsSwapped == NO) {
                if (self.player1ColorSpace.position.x >= 0) {
                    [self endGameWithWinner:1];
                } else if (self.player2ColorSpace.position.x <= 0) {
                    [self endGameWithWinner:2];
                }
            } else {
                if (self.player1ColorSpace.position.x <= 0) {
                    [self endGameWithWinner:1];
                } else if (self.player2ColorSpace.position.x >= 0) {
                    [self endGameWithWinner:2];
                }
            }
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (self.currentGameState == kGameStateNone || self.currentGameState == kGameStateCountdown) {
            if (self.player1Touch == touch) {
                self.isPlayer1FingerOnScreen = NO;
                [self resetTapSpaceInnerCircleForPlayer:1];
            } else if (self.player2Touch == touch) {
                self.isPlayer2FingerOnScreen = NO;
                [self resetTapSpaceInnerCircleForPlayer:2];
            }
        }
        
        if (self.currentGameState == kGameStateCountdown) {
            if (self.player1Touch == touch || self.player2Touch == touch) {
                [self unscheduleAllSelectors];
                [self.timerLabel removeFromParentAndCleanup:YES];
                self.currentGameState = kGameStateNone;
            }
        }
    }
}

-(void)startCountdown {
    CCLOG(@"start countdown!");
    self.currentGameState = kGameStateCountdown;
    self.timeToPlay = 3;
    self.timerLabel = [CCLabelBMFont labelWithString:@"3" fntFile:@"nexabold_200px.fnt"];
    self.timerLabel.position = ccp(self.screenSize.width/2, self.screenSize.height/2);
    self.timerLabel.color = timerColor;
    self.timerLabel.opacity = 0;
    [self addChild:self.timerLabel z:1000];
    [self.timerLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    
    [self schedule:@selector(initialCountdown:) interval:1];
}

-(void)initialCountdown:(ccTime)dt {
    self.timeToPlay--;
    
    if (self.timeToPlay == 0) {
        self.timerLabel.string = @"GO!";
        [self unschedule:@selector(initialCountdown:)];
        [self.timerLabel runAction:[CCSequence actions:[CCShow action], [CCFadeOut actionWithDuration:1.0f], [CCCallBlock actionWithBlock:^{
            [self.timerLabel removeFromParentAndCleanup:YES];
        }], nil]];
        [self startGame];
    } else {
        self.timerLabel.string = [NSString stringWithFormat:@"%i", self.timeToPlay];
        [self.timerLabel runAction:[CCSequence actions:[CCShow action], [CCFadeOut actionWithDuration:1.0f], nil]];
    }
}

-(void)startGame {
    self.currentGameState = kGameStatePlay;
}


-(void)activateSwitchFromPlayer:(int)playerNum {
    self.moveIncrement = -1*self.moveIncrement;
    if (playerNum == 1) {
        self.player1SwitchNum--;
        CCSprite *switchSprite = [self.player1SwitchSprites objectAtIndex:self.player1SwitchNum];
        switchSprite.visible = NO;
    } else if (playerNum == 2) {
        self.player2SwitchNum--;
        CCSprite *switchSprite = [self.player2SwitchSprites objectAtIndex:self.player2SwitchNum];
        switchSprite.visible = NO;
    }
    
    // swap color spaces
    float player1MovedAmount;
    float player2MovedAmount;
    float player1StartingPosition = -self.screenSize.width * 0.5;
    float player2StartingPosition = self.screenSize.width * 0.5;
    
    if (self.areColorsSwapped == NO) {
        player1MovedAmount = self.player1ColorSpace.position.x - player1StartingPosition;
        player2MovedAmount = -1*(self.player2ColorSpace.position.x - player2StartingPosition);
        
        self.player1ColorSpace.position = ccp(player2StartingPosition - player1MovedAmount, 0);
        self.player2ColorSpace.position = ccp(player1StartingPosition + player2MovedAmount, 0);
    } else {
        player1MovedAmount = -1*(self.player1ColorSpace.position.x - player2StartingPosition);
        player2MovedAmount = self.player2ColorSpace.position.x - player1StartingPosition;
        
        self.player1ColorSpace.position = ccp(player1StartingPosition + player1MovedAmount, 0);
        self.player2ColorSpace.position = ccp(player2StartingPosition - player2MovedAmount, 0);
    }

    // swap tap spaces
    CGPoint oldPlayer1TapSpacePosition = self.player1TapSpace.position;
    self.player1TapSpace.position = self.player2TapSpace.position;
    self.player2TapSpace.position = oldPlayer1TapSpacePosition;

    self.areColorsSwapped = !self.areColorsSwapped;
}

-(void)endGameWithWinner:(int)playerNum {
    self.currentGameState = kGameStateGameOver;
    self.isTouchEnabled = NO;
    CCLayerColor *flashScreen = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 0)];
    [self addChild:flashScreen z:5000];
    [flashScreen runAction:[CCSequence actions:[CCFadeIn actionWithDuration:0.25], [CCFadeOut actionWithDuration:2], [CCCallBlock actionWithBlock:^{
        [self.delegate showGameOverLayerForWinner:playerNum];
    }], nil]];
}

@end
