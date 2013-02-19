//
//  OrbDodgeLayer.m
//  lele
//
//  Created by Michael Gao on 1/26/13.
//
//

#import "OrbDodgeLayer.h"
#import "CCBlade.h"
#import "Orb.h"

@interface OrbDodgeLayer ()

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
@property (nonatomic, strong) CCSprite *player1Bounds;
@property (nonatomic, strong) CCSprite *player2Bounds;
@property (nonatomic) int timeToPlay;
@property (nonatomic, strong) CCLabelTTF *timerLabel;
//@property (nonatomic) float elapsedTime;
//@property (nonatomic) BOOL isPlayer1BoundsShrinking;
//@property (nonatomic) BOOL isPlayer2BoundsShrinking;
@property (nonatomic, strong) CCSpriteBatchNode *playerLivesBatchNode;
@property (nonatomic, strong) NSMutableArray *player1LivesSprites;
@property (nonatomic, strong) NSMutableArray *player2LivesSprites;
@property (nonatomic, strong) CCSpriteBatchNode *orbsBatchNode;
@property (nonatomic, strong) NSMutableArray *player1Orbs;
@property (nonatomic, strong) NSMutableArray *player2Orbs;
@property (nonatomic) int nextInactivePlayer1Orb;
@property (nonatomic) int nextInactivePlayer2Orb;
@property (nonatomic) CGSize orbSize;


@end

@implementation OrbDodgeLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"OrbDodgeLayer.m->init");
        self.isTouchEnabled = YES;
        self.isPlayer1FingerOnScreen = NO;
        self.isPlayer2FingerOnScreen = NO;
        self.currentGameState = kGameStateNone;
        self.screenSize = [CCDirector sharedDirector].winSize;
        
        [self addPlayerBounds];
        [self addStartingPointForPlayer:1 withFadeIn:NO];
        [self addStartingPointForPlayer:2 withFadeIn:NO];
        [self addLivesForBothPlayers];
        [self initializeOrbs];
    }
    
    return self;
}

-(void)addPlayerBounds {
    self.player1Bounds = [CCSprite spriteWithFile:@"bounds.png"];
    self.player2Bounds = [CCSprite spriteWithFile:@"bounds.png"];
    self.player1Bounds.opacity = 150;
    self.player2Bounds.opacity = 150;
    self.player1Bounds.position = ccp(-1 * self.screenSize.width*0.1, self.screenSize.height*0.5);
    self.player2Bounds.position = ccp(self.screenSize.width + self.screenSize.width*0.1, self.screenSize.height*0.5);
    [self addChild:self.player1Bounds];
    [self addChild:self.player2Bounds];
    
    // add dashed line in middle
    CCSprite *dashTemp = [CCSprite spriteWithFile:@"dash.png"];
    int capacity = self.screenSize.height / dashTemp.contentSize.width + 1;
    CCSpriteBatchNode *dashBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"dash.png" capacity:capacity];
    float startYPosition = 0;
    float dashXPosition = self.screenSize.width * 0.5;
    for (int i=0; i<capacity; i++) {
        CCSprite *dash = [CCSprite spriteWithFile:@"dash.png"];
        dash.rotation = 90;
        dash.anchorPoint = ccp(0.5, 0.5);
        dash.position = ccp(dashXPosition, startYPosition);
        startYPosition = startYPosition + dashTemp.contentSize.width*2;
        [dashBatchNode addChild:dash];
    }
    [self addChild:dashBatchNode z:500];
}

-(void)addStartingPointForPlayer:(int)playerNum withFadeIn:(BOOL)fadeIn {
    if (playerNum == 1) {
        self.player1Sprite = [CCSprite spriteWithFile:@"playercircle_white.png"];     // TODO: initialize in a separate method
        self.player1Sprite.color = player1Color;
        self.player1Sprite.anchorPoint = ccp(0, 0.5);
        self.player1Sprite.position = ccp(self.screenSize.width * 0.07, self.screenSize.height * 0.5);
        self.player1Sprite.opacity = 0;
        
        CCSprite *innerCircle1 = [CCSprite spriteWithFile:@"playercircle_white.png"];
        innerCircle1.color = player1Color;
        innerCircle1.anchorPoint = ccp(0.5, 0.5);
        innerCircle1.position = ccp(self.player1Sprite.contentSize.width * 0.5, self.player1Sprite.contentSize.height * 0.5);
        innerCircle1.scale = 0.40;
        innerCircle1.opacity = 0;
        
        [self addChild:self.player1Sprite z:1000];
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
        self.player2Sprite.position = ccp(self.screenSize.width * 0.93, self.screenSize.height * 0.5);
        self.player2Sprite.opacity = 0;
        
        CCSprite *innerCircle2 = [CCSprite spriteWithFile:@"playercircle_white.png"];
        innerCircle2.color = player2Color;
        innerCircle2.anchorPoint = ccp(0.5, 0.5);
        innerCircle2.position = ccp(self.player2Sprite.contentSize.width * 0.5, self.player2Sprite.contentSize.height * 0.5);
        innerCircle2.scale = 0.40;
        innerCircle2.opacity = 0;
        
        [self addChild:self.player2Sprite z:1000];
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
    player1LivesLabel.position = ccp(self.screenSize.width * 0.03, self.screenSize.height * 0.90);
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
    player2LivesLabel.position = ccp(self.screenSize.width * 0.97, self.screenSize.height * 0.1);
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

-(void)initializeOrbs {
    self.orbsBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"playercircle_white.png"];
    [self addChild:self.orbsBatchNode z:250];
    
    self.player1Orbs = [[NSMutableArray alloc] initWithCapacity:20];
    self.player2Orbs = [[NSMutableArray alloc] initWithCapacity:20];
    self.nextInactivePlayer1Orb = 0;
    self.nextInactivePlayer2Orb = 0;
    
    for (int i=0; i<20; i++) {
        Orb *player1Orb = [Orb orbForPlayer:1 atLocation:CGPointZero withTouch:nil];
        Orb *player2Orb = [Orb orbForPlayer:2 atLocation:CGPointZero withTouch:nil];
        player1Orb.visible = NO;
        player2Orb.visible = NO;
        [self.orbsBatchNode addChild:player1Orb];
        [self.orbsBatchNode addChild:player2Orb];
        [self.player1Orbs addObject:player1Orb];
        [self.player2Orbs addObject:player2Orb];
    }
    
    CCSprite *tempOrb = [CCSprite spriteWithFile:@"playercircle_white.png"];
    self.orbSize = tempOrb.contentSize;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        if (self.currentGameState == kGameStatePlay) {
            if (location.x < self.screenSize.width*0.5) {
                [self addOrbForPlayer:1 atLocation:location withTouch:touch];
            } else {
                [self addOrbForPlayer:2 atLocation:location withTouch:touch];
            }
        }
        
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
            
            // test move orbs
            for (Orb *orb in self.player1Orbs) {
                if (orb.touch == touch) {
                    orb.position = newLocation;
                }
            }
            
            for (Orb *orb in self.player2Orbs) {
                if (orb.touch == touch) {
                    orb.position = newLocation;
                }
            }
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
        
            if (self.currentGameState == kGameStateCountdown) {
                [self unscheduleAllSelectors];
                [self.timerLabel removeFromParentAndCleanup:YES];
                self.currentGameState = kGameStateNone;
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
            
            if (self.currentGameState == kGameStateCountdown) {
                [self unscheduleAllSelectors];
                [self.timerLabel removeFromParentAndCleanup:YES];
                self.currentGameState = kGameStateNone;
            }
        } else {
            // test move orbs
            for (Orb *orb in self.player1Orbs) {
                if (orb.touch == touch) {
                    CGPoint newLocation = [self convertTouchToNodeSpace:touch];
                    CGPoint previousLocation = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]]];
                    orb.xDelta = newLocation.x - previousLocation.x;
                    orb.yDelta = newLocation.y - previousLocation.y;
                    if (orb.xDelta == 0 && orb.yDelta == 0) {
                        orb.slope = 0;
                    } else if (orb.xDelta == 0) {
                        orb.slope = orb.yDelta;
                    } else {
                        orb.slope = orb.yDelta / orb.xDelta;
                    }
                    orb.b = newLocation.y - newLocation.x*orb.slope;
                    orb.touch = nil;
                }
            }
            
            for (Orb *orb in self.player2Orbs) {
                if (orb.touch == touch) {
                    CGPoint newLocation = [self convertTouchToNodeSpace:touch];
                    CGPoint previousLocation = [self convertToNodeSpace:[[CCDirector sharedDirector] convertToGL:[touch previousLocationInView:touch.view]]];
                    orb.xDelta = newLocation.x - previousLocation.x;
                    orb.yDelta = newLocation.y - previousLocation.y;
                    if (orb.xDelta == 0 && orb.yDelta == 0) {
                        orb.slope = 0;
                    } else if (orb.xDelta == 0) {
                        orb.slope = orb.yDelta;
                    } else {
                        orb.slope = orb.yDelta / orb.xDelta;
                    }
                    orb.b = newLocation.y - newLocation.x*orb.slope;
                    orb.touch = nil;
                }
            }
        }
        
        if (self.currentGameState == kGameStatePlay) {
            if (self.player1Touch == touch) {
                [self endRoundWithLoser:1 forReason:@"Removed Finger!"];
            } else if (self.player2Touch == touch) {
                [self endRoundWithLoser:2 forReason:@"Removed Finger!"];
            }
        }
    }
}

-(void)addOrbForPlayer:(int)playerNum atLocation:(CGPoint)location withTouch:(UITouch*)touch {
    Orb *newOrb;
    if (playerNum == 1) {
        newOrb = [self.player1Orbs objectAtIndex:self.nextInactivePlayer1Orb];
        self.nextInactivePlayer1Orb++;
        if (self.nextInactivePlayer1Orb >= [self.player1Orbs count]) {
            self.nextInactivePlayer1Orb = 0;
        }
    } else if (playerNum == 2) {
        newOrb = [self.player2Orbs objectAtIndex:self.nextInactivePlayer2Orb];
        self.nextInactivePlayer2Orb++;
        if (self.nextInactivePlayer2Orb >= [self.player2Orbs count]) {
            self.nextInactivePlayer2Orb = 0;
        }
    }
    
    newOrb.position = location;
    newOrb.touch = touch;
    newOrb.visible = YES;
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
    [self scheduleUpdate];
}

-(void)endRoundWithLoser:(int)playerNum forReason:(NSString*)reason {
    [self unscheduleUpdate];
    self.currentGameState = kGameStateNone;
    self.player1Touch = nil;
    self.player2Touch = nil;
    self.isPlayer1FingerOnScreen = NO;
    self.isPlayer2FingerOnScreen = NO;
    
    for (Orb *orb in self.player1Orbs) {
        orb.visible = NO;
        self.nextInactivePlayer1Orb = 0;
    }
    
    for (Orb *orb in self.player2Orbs) {
        orb.visible = NO;
        self.nextInactivePlayer2Orb = 0;
    }
    
    CCLOG(@"player %i loses the round with reason: %@", playerNum, reason);
    
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
    
    [self addChild:reasonLabel z:2000];
    
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

-(void)checkIfPlayersAreOutOfBounds {
    if (self.isPlayer1FingerOnScreen == YES && ccpDistance([self convertTouchToNodeSpace:self.player1Touch], self.player1Bounds.position) > self.player1Bounds.contentSize.width * 0.5) {
        [self endRoundWithLoser:1 forReason:@"Out of Bounds!"];
    } else if (self.isPlayer2FingerOnScreen == YES && ccpDistance([self convertTouchToNodeSpace:self.player2Touch], self.player2Bounds.position) > self.player2Bounds.contentSize.width * 0.5) {
        [self endRoundWithLoser:2 forReason:@"Out of Bounds!"];
    }
}

-(void)update:(ccTime)delta {
    for (Orb *orb in self.player1Orbs) {
        // test move orbs
        if (orb.visible == YES && orb.touch == nil) {
            CGPoint currentOrbPosition = orb.position;
            // move orb in direction of finger swipe
//            orb.position = ccp(currentOrbPosition.x+orb.xDelta, currentOrbPosition.y+orb.yDelta);
            if (orb.xDelta < 0) {
                orb.position = ccp(currentOrbPosition.x - 2*3, orb.slope*(currentOrbPosition.x-2*3)+orb.b);
            } else if (orb.xDelta > 0) {
                orb.position = ccp(currentOrbPosition.x + 2*3, orb.slope*(currentOrbPosition.x-2*3)+orb.b);
            } else {
                if (orb.yDelta > 0) {
                    orb.position = ccp(currentOrbPosition.x, currentOrbPosition.y + 2*3);
                } else {
                    orb.position = ccp(currentOrbPosition.x, currentOrbPosition.y - 2*3);
                }
            }
            
            // check for collision with player 2
            if (ccpDistance(orb.position, [self convertTouchToNodeSpace:self.player2Touch]) < self.orbSize.width * 0.5) {
                [self endRoundWithLoser:2 forReason:@"Hit!"];
            }
            
            // remove orb if out of screen bounds
            if (orb.position.x < -self.orbSize.width || orb.position.x > self.screenSize.width+self.orbSize.width ||
                orb.position.y < -self.orbSize.height || orb.position.y > self.screenSize.height+self.orbSize.height) {
                orb.visible = NO;
            }
        }
    }
    
    for (Orb *orb in self.player2Orbs) {
        // test move orbs
        if (orb.visible == YES && orb.touch == nil) {
            CGPoint currentOrbPosition = orb.position;
            // move orb in direction of finger swipe
            //            orb.position = ccp(currentOrbPosition.x+orb.xDelta, currentOrbPosition.y+orb.yDelta);
            if (orb.xDelta < 0) {
                orb.position = ccp(currentOrbPosition.x - 2*3, orb.slope*(currentOrbPosition.x-2*3)+orb.b);
            } else if (orb.xDelta > 0) {
                orb.position = ccp(currentOrbPosition.x + 2*3, orb.slope*(currentOrbPosition.x-2*3)+orb.b);
            } else {
                if (orb.yDelta > 0) {
                    orb.position = ccp(currentOrbPosition.x, currentOrbPosition.y + 2*3);
                } else {
                    orb.position = ccp(currentOrbPosition.x, currentOrbPosition.y - 2*3);
                }
            }
            
            // check for collision with player 1
            if (ccpDistance(orb.position, [self convertTouchToNodeSpace:self.player1Touch]) < self.orbSize.width * 0.5) {
                [self endRoundWithLoser:1 forReason:@"Hit!"];
            }
            
            // remove orb if out of screen bounds
            if (orb.position.x < -self.orbSize.width || orb.position.x > self.screenSize.width+self.orbSize.width ||
                orb.position.y < -self.orbSize.height || orb.position.y > self.screenSize.height+self.orbSize.height) {
                orb.visible = NO;
            }
        }
    }
    
    [self checkIfPlayersAreOutOfBounds];
}

@end
