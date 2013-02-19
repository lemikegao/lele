//
//  SumoFingerLayer.m
//  lele
//
//  Created by Michael Gao on 1/22/13.
//
//

#import "SumoFingerLayer.h"
#import "CCBlade.h"

@interface SumoFingerLayer ()

@property (nonatomic) CGSize screenSize;
@property (nonatomic) GameStates currentGameState;
@property (nonatomic) BOOL isPlayer1FingerOnScreen;
@property (nonatomic) BOOL isPlayer2FingerOnScreen;
@property (nonatomic, strong) UITouch *player1Touch;
@property (nonatomic, strong) UITouch *player2Touch;
@property (nonatomic, strong) CCSprite *player1Sprite;
@property (nonatomic, strong) CCSprite *player2Sprite;
@property (nonatomic, strong) CCBlade *player1Streak;
@property (nonatomic, strong) CCBlade *player2Streak;
@property (nonatomic) int player1Lives;
@property (nonatomic) int player2Lives;
@property (nonatomic, strong) CCSprite *battlegrounds;
@property (nonatomic) int timeToPlay;
@property (nonatomic, strong) CCLabelTTF *timerLabel;
@property (nonatomic) float elapsedTime;
@property (nonatomic) BOOL isBattlegroundsShrinking;
@property (nonatomic, strong) CCSpriteBatchNode *playerLivesBatchNode;
@property (nonatomic, strong) NSMutableArray *player1LivesSprites;
@property (nonatomic, strong) NSMutableArray *player2LivesSprites;

@end

@implementation SumoFingerLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"SumoFingerLayer.m->init");
        self.isTouchEnabled = YES;
        self.isPlayer1FingerOnScreen = NO;
        self.isPlayer2FingerOnScreen = NO;
        self.currentGameState = kGameStateNone;
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.elapsedTime = 0;
        self.isBattlegroundsShrinking = NO;
        
        [self addBattlegrounds];
        [self addStartingPointForPlayer:1 withFadeIn:NO];
        [self addStartingPointForPlayer:2 withFadeIn:NO];
        [self addLivesForBothPlayers];
    }
    
    return self;
}

-(void)addBattlegrounds {
    self.battlegrounds = [CCSprite spriteWithFile:@"battlegrounds.png"];
    self.battlegrounds.position = ccp(self.screenSize.width*0.5, self.screenSize.height*0.5);
    self.battlegrounds.opacity = 150;
    [self addChild:self.battlegrounds];
}

-(void)addStartingPointForPlayer:(int)playerNum withFadeIn:(BOOL)fadeIn {
    if (playerNum == 1) {
        self.player1Sprite = [CCSprite spriteWithFile:@"playercircle_white.png"];     // TODO: initialize in a separate method
        self.player1Sprite.color = player1Color;
        self.player1Sprite.anchorPoint = ccp(0, 0.5);
        self.player1Sprite.position = ccp(self.battlegrounds.position.x - self.battlegrounds.contentSize.width * 0.35, self.battlegrounds.position.y);
        self.player1Sprite.opacity = 0;
        
        CCSprite *innerCircle1 = [CCSprite spriteWithFile:@"playercircle_white.png"];
        innerCircle1.color = player1Color;
        innerCircle1.anchorPoint = ccp(0.5, 0.5);
        innerCircle1.position = ccp(self.player1Sprite.contentSize.width * 0.5, self.player1Sprite.contentSize.height * 0.5);
        innerCircle1.scale = 0.40;
        innerCircle1.opacity = 0;
        
        [self addChild:self.player1Sprite];
        [self.player1Sprite addChild:innerCircle1];
        
        if (fadeIn == YES) {
            [self.player1Sprite runAction:[CCFadeTo actionWithDuration:0.5 opacity:100]];
            [innerCircle1 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255], [CCCallBlock actionWithBlock:^{
                [innerCircle1 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.40 scale:0.80], [CCScaleTo actionWithDuration:0.40 scale:0.40], nil]]];
            }], nil]];
//            [innerCircle1 runAction:[CCFadeTo actionWithDuration:1 opacity:255]];
        } else {
            self.player1Sprite.opacity = 100;
            innerCircle1.opacity = 255;
            [innerCircle1 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.40 scale:0.80], [CCScaleTo actionWithDuration:0.40 scale:0.40], nil]]];
        }
    } else if (playerNum == 2) {
        self.player2Sprite = [CCSprite spriteWithFile:@"playercircle_white.png"];
        self.player2Sprite.color = player2Color;
        self.player2Sprite.anchorPoint = ccp(1, 0.5);
        self.player2Sprite.position = ccp(self.battlegrounds.position.x + self.battlegrounds.contentSize.width * 0.35, self.battlegrounds.position.y);
        self.player2Sprite.opacity = 0;
        
        CCSprite *innerCircle2 = [CCSprite spriteWithFile:@"playercircle_white.png"];
        innerCircle2.color = player2Color;
        innerCircle2.anchorPoint = ccp(0.5, 0.5);
        innerCircle2.position = ccp(self.player2Sprite.contentSize.width * 0.5, self.player2Sprite.contentSize.height * 0.5);
        innerCircle2.scale = 0.40;
        innerCircle2.opacity = 0;
        
        [self addChild:self.player2Sprite];
        [self.player2Sprite addChild:innerCircle2];
        
        if (fadeIn == YES) {
            [self.player2Sprite runAction:[CCFadeTo actionWithDuration:0.5 opacity:100]];
            [innerCircle2 runAction:[CCSequence actions:[CCFadeTo actionWithDuration:0.5 opacity:255], [CCCallBlock actionWithBlock:^{
                [innerCircle2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.40 scale:0.80], [CCScaleTo actionWithDuration:0.40 scale:0.40], nil]]];
            }], nil]];
        } else {
            self.player2Sprite.opacity = 100;
            innerCircle2.opacity = 255;
            [innerCircle2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.40 scale:0.80], [CCScaleTo actionWithDuration:0.40 scale:0.40], nil]]];
        }
    } else {
        CCLOG(@"GameLayer.m->addStartingPointForPlayer: Unknown player: %i", playerNum);
    }
}

-(void)removeStartingPointForPlayer:(int)playerNum {
    if (playerNum == 1) {
        [self.player1Sprite removeAllChildrenWithCleanup:YES];    //TODO: need to stop action of inner circle before removing?
        [self.player1Sprite stopAllActions];
        [self.player1Sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [self.player1Sprite removeAllChildrenWithCleanup:YES];
            [self.player1Sprite removeFromParentAndCleanup:YES];
            self.player1Sprite = nil;
        }], nil]];
        
    } else if (playerNum == 2) {
        [self.player2Sprite removeAllChildrenWithCleanup:YES];    //TODO: need to stop action of inner circle before removing?
        [self.player2Sprite stopAllActions];
        [self.player2Sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [self.player2Sprite removeAllChildrenWithCleanup:YES];
            [self.player2Sprite removeFromParentAndCleanup:YES];
            self.player2Sprite = nil;
        }], nil]];
    } else {
        CCLOG(@"GameLayer.m->removeStartingPointForPlayer: Unknown player: %i", playerNum);
    }
}

-(void)addLivesForBothPlayers {
    self.player1Lives = 3;
    self.player2Lives = 3;
    self.playerLivesBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"lives.png"];
    self.player1LivesSprites = [[NSMutableArray alloc] initWithCapacity:self.player1Lives];
    self.player2LivesSprites = [[NSMutableArray alloc] initWithCapacity:self.player2Lives];
    
    CCLabelBMFont *player1LivesLabel = [CCLabelBMFont labelWithString:@"Lives" fntFile:@"nexalight_26px.fnt"];
    player1LivesLabel.color = player1Color;
    player1LivesLabel.anchorPoint = ccp(0, 0);
    player1LivesLabel.rotation = 90;
    player1LivesLabel.position = ccp(self.screenSize.width * 0.03, self.screenSize.height * 0.95);
    [self addChild:player1LivesLabel];
    
    for (int i=0; i<self.player1Lives; i++) {
        CCSprite *lifeSprite = [CCSprite spriteWithFile:@"lives.png"];
        lifeSprite.color = player1Color;
        lifeSprite.anchorPoint = ccp(0, 1);
        lifeSprite.position = ccp(player1LivesLabel.position.x, player1LivesLabel.position.y - player1LivesLabel.contentSize.width - lifeSprite.contentSize.height*0.4 - i*lifeSprite.contentSize.height*1.3);
        [self.playerLivesBatchNode addChild:lifeSprite];
        [self.player1LivesSprites addObject:lifeSprite];
    }
    
    CCLabelBMFont *player2LivesLabel = [CCLabelBMFont labelWithString:@"Lives" fntFile:@"nexalight_26px.fnt"];
    player2LivesLabel.color= player2Color;
    player2LivesLabel.anchorPoint = ccp(0, 0);
    player2LivesLabel.rotation = -90;
    player2LivesLabel.position = ccp(self.screenSize.width * 0.97, self.screenSize.height * 0.05);
    [self addChild:player2LivesLabel];
    
    for (int i=0; i<self.player2Lives; i++) {
        CCSprite *lifeSprite = [CCSprite spriteWithFile:@"lives.png"];
        lifeSprite.color = player2Color;
        lifeSprite.anchorPoint = ccp(1, 0);
        lifeSprite.position = ccp(player2LivesLabel.position.x, player2LivesLabel.position.y + player2LivesLabel.contentSize.width + lifeSprite.contentSize.height*0.4 + i*lifeSprite.contentSize.height*1.3);
        [self.playerLivesBatchNode addChild:lifeSprite];
        [self.player2LivesSprites addObject:lifeSprite];
    }
    
    [self addChild:self.playerLivesBatchNode];
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        // check if player 1 is ready
        if (self.isPlayer1FingerOnScreen == NO) {
            if (CGRectContainsPoint(self.player1Sprite.boundingBox, location)) {
                CCLOG(@"player 1 is ready");
                self.isPlayer1FingerOnScreen = YES;
                self.player1Touch = touch;
                
                // initialize player 1 streak
                self.player1Streak = [CCBlade bladeWithMaximumPoint:50];
                self.player1Streak.autoDim = NO;
                self.player1Streak.texture = [[CCTextureCache sharedTextureCache] addImage:@"playerdash1_long.png"];
                [self addChild:self.player1Streak];
                [self.player1Streak push:location];
                
                // remove finger placeholder
                [self removeStartingPointForPlayer:1];
                
                // start game if player 2 is ready
                if (self.isPlayer2FingerOnScreen == YES && (self.currentGameState == kGameStateNone || self.currentGameState == kGameStateGameOver)) {
                    [self startCountdown];
                }
            }
        }
        
        // check if player 2 is ready
        if (self.isPlayer2FingerOnScreen == NO) {
            if (CGRectContainsPoint(self.player2Sprite.boundingBox, location)) {
                CCLOG(@"player 2 is ready");
                self.isPlayer2FingerOnScreen = YES;
                self.player2Touch = touch;
                
                // initialize player 2 streak
                self.player2Streak = [CCBlade bladeWithMaximumPoint:50];
                self.player2Streak.autoDim = NO;
                self.player2Streak.texture = [[CCTextureCache sharedTextureCache] addImage:@"playerdash2_long.png"];
                [self addChild:self.player2Streak];
                [self.player2Streak push:location];
                
                // remove finger placeholder
                [self removeStartingPointForPlayer:2];
                
                // start game if player 1 is ready
                if (self.isPlayer1FingerOnScreen == YES && (self.currentGameState == kGameStateNone || self.currentGameState == kGameStateGameOver)) {
                    [self startCountdown];
                }
            }
        }
    }
}

-(void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint newLocation = [self convertTouchToNodeSpace:touch];
        CGPoint previousLocation = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]]];
        
        if (self.player1Touch == touch) {
//            CCLOG(@"player 1 moved");
            if (self.player1Sprite != nil) {
                self.player1Sprite.position = ccpAdd(self.player1Sprite.position, ccpSub(newLocation, previousLocation));
            }
            
            // move player 1 streak
            [self.player1Streak push:newLocation];
        } else if (self.player2Touch == touch) {
//            CCLOG(@"player 2 moved");
            if (self.player2Sprite != nil) {
                self.player2Sprite.position = ccpAdd(self.player2Sprite.position, ccpSub(newLocation, previousLocation));
            }
            
            // move player 2 streak
            [self.player2Streak push:newLocation];
        } else {
            //            CCLOG(@"Unknown touch moved");
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        if (self.player1Touch == touch) {
            self.isPlayer1FingerOnScreen = NO;
            
            if (self.currentGameState != kGameStatePlay) {
                // remove player 1 streak
                [self.player1Streak dim:YES];
            
                // add finger placeholder
                if (self.player1Sprite != nil) {
                    [self.player1Sprite removeAllChildrenWithCleanup:YES];
                    [self.player1Sprite removeFromParentAndCleanup:YES];
                }
                
                [self addStartingPointForPlayer:1 withFadeIn:NO];
            }
            
        } else if (self.player2Touch == touch) {
            self.isPlayer2FingerOnScreen = NO;
            
            if (self.currentGameState != kGameStatePlay) {
                // remove player 2 streak
                [self.player2Streak dim:YES];

                // add finger placeholder
                if (self.player2Sprite != nil) {
                    [self.player2Sprite removeAllChildrenWithCleanup:YES];
                    [self.player2Sprite removeFromParentAndCleanup:YES];
                }
                
                [self addStartingPointForPlayer:2 withFadeIn:NO];
            }
        }
        
        if (self.currentGameState == kGameStateCountdown) {
            [self unscheduleAllSelectors];
            [self.timerLabel removeFromParentAndCleanup:YES];
            self.currentGameState = kGameStateNone;
        } else if (self.currentGameState == kGameStatePlay) {
            if (self.player1Touch == touch) {
                [self endRoundWithLoser:1 forReason:@"Removed Finger!"];
            } else if (self.player2Touch == touch) {
                [self endRoundWithLoser:2 forReason:@"Removed Finger!"];
            }
        }
    }
}


-(void) startCountdown {
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
    [self scheduleUpdate];
}

-(void)checkForOutOfBounds {
    // check if players have returned within boundaries
    CGPoint player1Location = [self convertTouchToNodeSpace:self.player1Touch];
    CGPoint player2Location = [self convertTouchToNodeSpace:self.player2Touch];
    
    // check if player location is outside of the battlegrounds
    if (self.isPlayer1FingerOnScreen == YES) {
        if (ccpDistance(self.battlegrounds.position, player1Location) > self.battlegrounds.boundingBox.size.height * 0.5) {
            [self endRoundWithLoser:1 forReason:@"Out of Bounds!"];
        }
    }
    
    if (self.isPlayer2FingerOnScreen == YES) {
        if (ccpDistance(self.battlegrounds.position, player2Location) > self.battlegrounds.boundingBox.size.height * 0.5) {
            [self endRoundWithLoser:2 forReason:@"Out of Bounds!"];
        }
    }
}

-(void)endRoundWithLoser:(int)playerNum forReason:(NSString*)reason {
    [self.battlegrounds stopAllActions];
    [self unscheduleUpdate];
    self.currentGameState = kGameStateNone;
    self.player1Touch = nil;
    self.player2Touch = nil;
    self.isPlayer1FingerOnScreen = NO;
    self.isPlayer2FingerOnScreen = NO;
    self.elapsedTime = 0;
    self.isBattlegroundsShrinking = NO;
    CCLOG(@"player %i wins the round", playerNum);
    
    // dim both player streaks
    [self.player1Streak dim:YES];
    [self.player2Streak dim:YES];
    
    CCLabelBMFont *reasonLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"Player %i %@", playerNum, reason] fntFile:@"nexabold_40px.fnt"];
    reasonLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    
    if (playerNum == 1) {
        if (self.player1Lives > 0) {
            self.player1Lives--;
            CCSprite *lifeSprite = [self.player1LivesSprites objectAtIndex:self.player1Lives];
            lifeSprite.visible = NO;
            reasonLabel.color = player1Color;
        }
    } else if (playerNum == 2) {
        if (self.player2Lives > 0) {
            self.player2Lives--;
            CCSprite *lifeSprite = [self.player2LivesSprites objectAtIndex:self.player2Lives];
            lifeSprite.visible = NO;
            reasonLabel.color = player2Color;
        }
    }
    
    [self addChild:reasonLabel];
    
    if (self.player1Lives <= 0) {
        [reasonLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [reasonLabel removeFromParentAndCleanup:YES];
            [self endGameWithWinner:2];
        }], nil]];
    } else if (self.player2Lives <= 0) {
        [reasonLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [reasonLabel removeFromParentAndCleanup:YES];
            [self endGameWithWinner:1];
        }], nil]];
    } else {
        [reasonLabel runAction:[CCSequence actions:[CCDelayTime actionWithDuration:2], [CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [reasonLabel removeFromParentAndCleanup:YES];
            [self startNewRound];
        }], nil]];
    }
}

-(void)startNewRound {
    self.battlegrounds.scale = 1;
    [self addStartingPointForPlayer:1 withFadeIn:YES];
    [self addStartingPointForPlayer:2 withFadeIn:YES];
    
    // use scale action to enlarge battlegrounds and fade in player positions
//    [self.battlegrounds runAction:[CCScaleTo actionWithDuration:0.25 scale:1]];
}

-(void)endGameWithWinner:(int)playerNum {
    self.currentGameState = kGameStateGameOver;
    [self removeStartingPointForPlayer:1];
    [self removeStartingPointForPlayer:2];
    [self.delegate showGameOverLayerForWinner:playerNum];
}

-(void)update:(ccTime)delta {
    self.elapsedTime = self.elapsedTime + delta;
    if (self.isBattlegroundsShrinking == NO && self.elapsedTime > 5) {
        // shrink battlegrounds
        CCLOG(@"shrinking battlegrounds");
        self.isBattlegroundsShrinking = YES;
        [self.battlegrounds runAction:[CCScaleTo actionWithDuration:30 scale:0.3]];
    }
    [self checkForOutOfBounds];
}

@end
