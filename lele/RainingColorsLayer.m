//
//  GameLayer.m
//  lele
//
//  Created by Michael Gao on 12/27/12.
//
//

#import "RainingColorsLayer.h"
#import "CCBlade.h"

@interface RainingColorsLayer ()

@property (nonatomic) CGSize screenSize;
@property (nonatomic) GameStates currentGameState;
@property (nonatomic) BOOL isPlayer1FingerOnScreen;
@property (nonatomic) BOOL isPlayer2FingerOnScreen;
@property (nonatomic, strong) UITouch *player1Touch;
@property (nonatomic, strong) UITouch *player2Touch;
@property (nonatomic, strong) CCSprite *player1Sprite;
@property (nonatomic, strong) CCSprite *player2Sprite;
@property (nonatomic) CGSize playerSpriteSize;
@property (nonatomic) int timeToPlay;
@property (nonatomic, strong) CCLabelBMFont *countdownTimerLabel;
@property (nonatomic, strong) CCLabelBMFont *gameTimerLabel;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) NSMutableArray *obstacles;
@property (nonatomic) int maxObstacles;
@property (nonatomic) int numOfObstaclesToAdd;
@property (nonatomic) int elapsedTime;
@property (nonatomic, strong) NSMutableArray *randomNumbers;
@property (nonatomic, strong) NSMutableIndexSet *indexesForObstaclesToBeRemoved;
@property (nonatomic) int player1Score;
@property (nonatomic) int player2Score;
@property (nonatomic, strong) CCLabelBMFont *player1ScoreLabel;
@property (nonatomic, strong) CCLabelBMFont *player2ScoreLabel;
@property (nonatomic, strong) CCLabelBMFont *player1DeductPointsLabel;
@property (nonatomic, strong) CCLabelBMFont *player2DeductPointsLabel;
@property (nonatomic, strong) CCLabelBMFont *player1DeductReasonPlayerLabel;
@property (nonatomic, strong) CCLabelBMFont *player2DeductReasonPlayerLabel;
@property (nonatomic, strong) CCLabelBMFont *player1DeductReasonLabel;
@property (nonatomic, strong) CCLabelBMFont *player2DeductReasonLabel;
@property (nonatomic) BOOL player1HitObstacle;
@property (nonatomic) BOOL player2HitObstacle;
@property (nonatomic) float player1TimeElapsedAfterHitObstacle;
@property (nonatomic) float player2TimeElapsedAfterHitObstacle;
@property (nonatomic) BOOL player1OutOfBoundaries;
@property (nonatomic) BOOL player2OutOfBoundaries;
@property (nonatomic) int speedFactor;
@property (nonatomic) float immunityTime;
@property (nonatomic, strong) CCBlade *player1Streak;
@property (nonatomic, strong) CCBlade *player2Streak;

@end

@implementation RainingColorsLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"RainingColorsLayer.m->init");
        // enable touch
        self.isTouchEnabled = YES;
        self.isPlayer1FingerOnScreen = NO;
        self.isPlayer2FingerOnScreen = NO;
        self.player1OutOfBoundaries = NO;
        self.player2OutOfBoundaries = NO;
        self.speedFactor = 500;
        self.currentGameState = kGameStateNone;
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.numOfObstaclesToAdd = 1;
        self.indexesForObstaclesToBeRemoved = [[NSMutableIndexSet alloc] init];
        self.player1TimeElapsedAfterHitObstacle = 0;
        self.player2TimeElapsedAfterHitObstacle = 0;
        self.immunityTime = 0.5;
        
        self.countdownTimerLabel = [CCLabelBMFont labelWithString:@"3" fntFile:@"nexabold_200px.fnt"];
        self.countdownTimerLabel.position = ccp(self.screenSize.width/2, self.screenSize.height/2);
        self.countdownTimerLabel.color = timerColor;
        self.countdownTimerLabel.opacity = 0;
        [self addChild:self.countdownTimerLabel z:1000];
        
        CCLabelBMFont *timeLabel = [CCLabelBMFont labelWithString:@"TIME" fntFile:@"nexalight_20px.fnt"];
        timeLabel.color = timerColor;
        timeLabel.anchorPoint = ccp(0.5, 1);
        timeLabel.position = ccp(self.screenSize.width*0.5, self.screenSize.height*0.98);
        [self addChild:timeLabel z:1000];
        
        self.gameTimerLabel = [CCLabelBMFont labelWithString:@"30" fntFile:@"nexalight_60px.fnt"];
        self.gameTimerLabel.color = timerColor;
        self.gameTimerLabel.anchorPoint = ccp(0.5, 1);
        self.gameTimerLabel.position = ccp(self.screenSize.width*0.5, self.screenSize.height*0.95);
        [self addChild:self.gameTimerLabel z:1000];
        
        // init obstacles
        self.obstacles = [[NSMutableArray alloc] initWithCapacity:100];
        // set up batch node for players and obstacles
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"obstacle.png" capacity:100];
        [self addChild:self.batchNode z:0];
        
        // init dash boundary
        CCSprite *dashTemp = [CCSprite spriteWithFile:@"dash.png"];
        int capacity = self.screenSize.width / dashTemp.contentSize.width + 1;
        CCSpriteBatchNode *dashBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"dash.png" capacity:capacity];
        float startXPosition = 0;
        float dashYPosition = dashYBoundary;
        for (int i=0; i<capacity; i++) {
            CCSprite *dash = [CCSprite spriteWithFile:@"dash.png"];
            dash.anchorPoint = ccp(0, 0.5);
            dash.position = ccp(startXPosition, dashYPosition);
            startXPosition = startXPosition + dashTemp.contentSize.width*2;
            [dashBatchNode addChild:dash];
        }
        [self addChild:dashBatchNode z:100];
        
        CCSprite *tempObstacle = [CCSprite spriteWithFile:@"obstacle.png"];
        self.playerSpriteSize = tempObstacle.contentSize;
        self.maxObstacles = self.screenSize.width/self.playerSpriteSize.width/2;
        self.randomNumbers = [[NSMutableArray alloc] initWithCapacity:self.maxObstacles];
        
        [self addStartingPointForPlayer:1];
        [self addStartingPointForPlayer:2];
        
        [self initScore];
    }
    
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
        
        // check if player 1 is ready
        if (self.isPlayer1FingerOnScreen == NO) {
            if (CGRectContainsPoint(self.player1Sprite.boundingBox, location)) {
                CCLOG(@"player 1 is ready");
                self.isPlayer1FingerOnScreen = YES;
                if (self.player1OutOfBoundaries == YES) {
                    self.player1DeductReasonLabel.string = @"Out of Bounds!";
                } else {
                    self.player1DeductReasonPlayerLabel.visible = NO;
                    self.player1DeductReasonLabel.visible = NO;
                }
                [self unschedule:@selector(deductPointsPlayer1RemovedFinger)];
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
                if (self.player2OutOfBoundaries == YES) {
                    self.player2DeductReasonLabel.string = @"Out of Bounds!";
                } else {
                    self.player2DeductReasonPlayerLabel.visible = NO;
                    self.player2DeductReasonLabel.visible = NO;
                }
                [self unschedule:@selector(deductPointsPlayer2RemovedFinger)];
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
            if (self.currentGameState == kGameStateCountdown) {
                [self unscheduleAllSelectors];
                self.currentGameState = kGameStateNone;
            }
            self.isPlayer1FingerOnScreen = NO;
            
            // remove player 1 streak
            [self.player1Streak dim:YES];
            
            // add finger placeholder
            if (self.player1Sprite != nil) {
                [self.player1Sprite removeAllChildrenWithCleanup:YES];
                [self.player1Sprite removeFromParentAndCleanup:YES];
            }
            
            [self addStartingPointForPlayer:1];
        } else if (self.player2Touch == touch) {
            if (self.currentGameState == kGameStateCountdown) {
                [self unscheduleAllSelectors];
                self.currentGameState = kGameStateNone;
            }
            self.isPlayer2FingerOnScreen = NO;
            
            // remove player 2 streak
            [self.player2Streak dim:YES];
            
            // add finger placeholder
            if (self.player2Sprite != nil) {
                [self.player2Sprite removeAllChildrenWithCleanup:YES];
                [self.player2Sprite removeFromParentAndCleanup:YES];
            }
            
            [self addStartingPointForPlayer:2];
        }
        
         if (self.currentGameState == kGameStatePlay) {
            if (self.player1Touch == touch) {
                CCLOG(@"player 1 removed finger");
                [self.player1DeductReasonPlayerLabel stopAllActions];
                [self.player1DeductReasonLabel stopAllActions];
                self.player1DeductReasonPlayerLabel.visible = YES;
                self.player1DeductReasonPlayerLabel.opacity = 255;
                self.player1DeductReasonLabel.string = @"Finger Removed!";
                self.player1DeductReasonLabel.visible = YES;
                self.player1DeductReasonLabel.opacity = 255;
                [self deductPointsPlayer1RemovedFinger];
                [self schedule:@selector(deductPointsPlayer1RemovedFinger) interval:1];
    //            if (self.isPlayer2FingerOnScreen == NO && self.isGameActive == YES) {
    //                [self endGame];
    //            }
            } else if (self.player2Touch == touch) {
                CCLOG(@"player 2 removed finger");
                [self.player2DeductReasonPlayerLabel stopAllActions];
                [self.player2DeductReasonLabel stopAllActions];
                self.player2DeductReasonPlayerLabel.visible = YES;
                self.player2DeductReasonPlayerLabel.opacity = 255;
                self.player2DeductReasonLabel.string = @"Finger Removed!";
                self.player2DeductReasonLabel.visible = YES;
                self.player2DeductReasonLabel.opacity = 255;
                [self deductPointsPlayer2RemovedFinger];
                [self schedule:@selector(deductPointsPlayer2RemovedFinger) interval:1];
    //            if (self.isPlayer1FingerOnScreen == NO && self.isGameActive == YES) {
    //                [self endGame];
    //            }
            } else {
    //            CCLOG(@"Uknown touch ended");
            }
        }
    }
}

-(void)resetRandomNumbers {
    if ([self.randomNumbers count] > 0) {
        [self.randomNumbers removeAllObjects];
    }
    
    for (int i=0; i<self.maxObstacles; i++) {
        [self.randomNumbers addObject:[NSNumber numberWithInt:i]];
    }
}

-(void)addStartingPointForPlayer:(int)playerNum {
    if (playerNum == 1) {
        self.player1Sprite = [CCSprite spriteWithFile:@"playercircle_white.png"];     // TODO: initialize in a separate method
        self.player1Sprite.color = player1Color;
        self.player1Sprite.anchorPoint = ccp(0, 0);
        self.player1Sprite.position = ccp(self.screenSize.width * 0.05f, self.screenSize.height * 0.05f);
        self.player1Sprite.opacity = 100;
        [self addChild:self.player1Sprite];
        
        CCSprite *innerCircle1 = [CCSprite spriteWithFile:@"playercircle_white.png"];
        innerCircle1.color = player1Color;
        innerCircle1.anchorPoint = ccp(0.5, 0.5);
        innerCircle1.position = ccp(self.player1Sprite.contentSize.width * 0.5, self.player1Sprite.contentSize.height * 0.5);
        innerCircle1.scale = 0.40;
        [self.player1Sprite addChild:innerCircle1];
        
        [innerCircle1 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.40 scale:0.80], [CCScaleTo actionWithDuration:0.40 scale:0.40], nil]]];
    } else if (playerNum == 2) {
        self.player2Sprite = [CCSprite spriteWithFile:@"playercircle_white.png"];
        self.player2Sprite.color = player2Color;
        self.player2Sprite.anchorPoint = ccp(1, 0);
        self.player2Sprite.position = ccp(self.screenSize.width * 0.95f, self.screenSize.height * 0.05f);
        self.player2Sprite.opacity = 100;
        [self addChild:self.player2Sprite];
        
        CCSprite *innerCircle2 = [CCSprite spriteWithFile:@"playercircle_white.png"];
        innerCircle2.color = player2Color;
        innerCircle2.anchorPoint = ccp(0.5, 0.5);
        innerCircle2.position = ccp(self.player2Sprite.contentSize.width * 0.5, self.player2Sprite.contentSize.height * 0.5);
        innerCircle2.scale = 0.40;
        [self.player2Sprite addChild:innerCircle2];
        
        [innerCircle2 runAction:[CCRepeatForever actionWithAction:[CCSequence actions:[CCScaleTo actionWithDuration:0.40 scale:0.80], [CCScaleTo actionWithDuration:0.40 scale:0.40], nil]]];
    } else {
        CCLOG(@"GameLayer.m->addStartingPointForPlayer: Unknown player: %i", playerNum);
    }
}

-(void)removeStartingPointForPlayer:(int)playerNum {
    if (playerNum == 1) {
        [self.player1Sprite removeAllChildrenWithCleanup:YES];    //TODO: need to stop action of inner circle before removing?
        [self.player1Sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [self.player1Sprite removeAllChildrenWithCleanup:YES];
            [self.player1Sprite removeFromParentAndCleanup:YES];
            self.player1Sprite = nil;
        }], nil]];
        
    } else if (playerNum == 2) {
        [self.player2Sprite removeAllChildrenWithCleanup:YES];    //TODO: need to stop action of inner circle before removing?
        [self.player2Sprite runAction:[CCSequence actions:[CCFadeOut actionWithDuration:1], [CCCallBlock actionWithBlock:^{
            [self.player2Sprite removeAllChildrenWithCleanup:YES];
            [self.player2Sprite removeFromParentAndCleanup:YES];
            self.player2Sprite = nil;
        }], nil]];
    } else {
        CCLOG(@"GameLayer.m->removeStartingPointForPlayer: Unknown player: %i", playerNum);
    }
}

-(void)initScore {
    // add Player 1 and Player 2 label
    CCLabelBMFont *player1Label = [CCLabelBMFont labelWithString:@"PLAYER 1" fntFile:@"nexalight_20px.fnt"];
    CCLabelBMFont *player2Label = [CCLabelBMFont labelWithString:@"PLAYER 2" fntFile:@"nexalight_20px.fnt"];
    player1Label.color = player1Color;
    player2Label.color = player2Color;
    player1Label.anchorPoint = ccp(0, 1);
    player2Label.anchorPoint = ccp(1, 1);
    player1Label.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.98);
    player2Label.position = ccp(self.screenSize.width * 0.95, self.screenSize.height * 0.98);
    
    // set up player scores
    self.player1Score = 0;
    self.player2Score = 0;
    self.player1ScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"nexalight_60px.fnt"];
    self.player2ScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"nexalight_60px.fnt"];
    self.player1ScoreLabel.color = player1Color;
    self.player2ScoreLabel.color = player2Color;
    self.player1ScoreLabel.anchorPoint = ccp(0, 1);
    self.player1ScoreLabel.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.95);
    self.player2ScoreLabel.anchorPoint = ccp(1, 1);
    self.player2ScoreLabel.position = ccp(self.screenSize.width * 0.95, self.screenSize.height * 0.95);
    
    // set up player deduct points labels
    self.player1DeductPointsLabel = [CCLabelBMFont labelWithString:@"-100" fntFile:@"nexabold_100px.fnt"];
    self.player2DeductPointsLabel = [CCLabelBMFont labelWithString:@"-100" fntFile:@"nexabold_100px.fnt"];
    self.player1DeductPointsLabel.color = player1Color;
    self.player2DeductPointsLabel.color = player2Color;
    self.player1DeductPointsLabel.anchorPoint = ccp(0, 1);
    self.player2DeductPointsLabel.anchorPoint = ccp(1, 1);
    self.player1DeductPointsLabel.position = ccp(self.screenSize.width * 0.07, self.screenSize.height * 0.85);
    self.player2DeductPointsLabel.position = ccp(self.screenSize.width * 0.93, self.screenSize.height * 0.85);
    self.player1DeductPointsLabel.visible = NO;
    self.player2DeductPointsLabel.visible = NO;
    
    // set up player deduct reason player labels
    self.player1DeductReasonPlayerLabel = [CCLabelBMFont labelWithString:@"Player 1" fntFile:@"nexabold_40px.fnt"];
    self.player2DeductReasonPlayerLabel = [CCLabelBMFont labelWithString:@"Player 2" fntFile:@"nexabold_40px.fnt"];
    self.player1DeductReasonPlayerLabel.color = player1Color;
    self.player2DeductReasonPlayerLabel.color = player2Color;
    self.player1DeductReasonPlayerLabel.anchorPoint = ccp(0, 1);
    self.player2DeductReasonPlayerLabel.anchorPoint = ccp(0, 1);
    self.player1DeductReasonPlayerLabel.position = ccp(self.screenSize.width * 0.27, self.screenSize.height * 0.88);
    self.player2DeductReasonPlayerLabel.position = ccp(self.screenSize.width * 0.27, self.screenSize.height * 0.82);
    self.player1DeductReasonPlayerLabel.visible = NO;
    self.player2DeductReasonPlayerLabel.visible = NO;
    
    // set up player deduct reason labels
    self.player1DeductReasonLabel = [CCLabelBMFont labelWithString:@"Finger Removed!" fntFile:@"nexalight_40px.fnt"];
    self.player2DeductReasonLabel = [CCLabelBMFont labelWithString:@"Finger Removed!" fntFile:@"nexalight_40px.fnt"];
    self.player1DeductReasonLabel.color = player1Color;
    self.player2DeductReasonLabel.color = player2Color;
    self.player1DeductReasonLabel.anchorPoint = ccp(0, 1);
    self.player2DeductReasonLabel.anchorPoint = ccp(0, 1);
    self.player1DeductReasonLabel.position = ccp(self.player1DeductReasonPlayerLabel.position.x + self.player1DeductReasonPlayerLabel.contentSize.width * 1.07, self.player1DeductReasonPlayerLabel.position.y - self.player1DeductReasonPlayerLabel.contentSize.height*0.05);
    self.player2DeductReasonLabel.position = ccp(self.player2DeductReasonPlayerLabel.position.x + self.player2DeductReasonPlayerLabel.contentSize.width * 1.07, self.player2DeductReasonPlayerLabel.position.y - self.player1DeductReasonPlayerLabel.contentSize.height*0.05);
    self.player1DeductReasonLabel.visible = NO;
    self.player2DeductReasonLabel.visible = NO;

    
    [self addChild:player1Label z:10];
    [self addChild:player2Label z:10];
    [self addChild:self.player1ScoreLabel z:10];
    [self addChild:self.player2ScoreLabel z:10];
    [self addChild:self.player1DeductPointsLabel z:10];
    [self addChild:self.player2DeductPointsLabel z:10];
    [self addChild:self.player1DeductReasonPlayerLabel z:10];
    [self addChild:self.player2DeductReasonPlayerLabel z:10];
    [self addChild:self.player1DeductReasonLabel z:10];
    [self addChild:self.player2DeductReasonLabel z:10];
}

-(void)deductPointsPlayer1OutOfBoundaries {
    // show deduct points label
    self.player1DeductPointsLabel.string = @"-100";
    self.player1DeductPointsLabel.visible = YES;
    [self.player1DeductPointsLabel runAction:[CCFadeOut actionWithDuration:0.30]];
    self.player1Score = self.player1Score - 100;
    self.player1ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player1Score];
}

-(void)deductPointsPlayer2OutOfBoundaries {
    // show deduct points label
    self.player2DeductPointsLabel.string = @"-100";
    self.player2DeductPointsLabel.visible = YES;
    [self.player2DeductPointsLabel runAction:[CCFadeOut actionWithDuration:0.30]];
    self.player2Score = self.player2Score - 100;
    self.player2ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player2Score];
}

-(void)deductPointsPlayer1RemovedFinger {
    // show deduct points label
    self.player1DeductPointsLabel.string = @"-100";
    self.player1DeductPointsLabel.visible = YES;
    [self.player1DeductPointsLabel runAction:[CCFadeOut actionWithDuration:0.30]];
    self.player1Score = self.player1Score - 100;
    self.player1ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player1Score];
}

-(void)deductPointsPlayer2RemovedFinger {
    // show deduct points label
    self.player2DeductPointsLabel.string = @"-100";
    self.player2DeductPointsLabel.visible = YES;
    [self.player2DeductPointsLabel runAction:[CCFadeOut actionWithDuration:0.30]];
    self.player2Score = self.player2Score - 100;
    self.player2ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player2Score];
}

-(void)deductPointsPlayer1HitObstacle {
    // show deduct points label
    self.player1DeductPointsLabel.string = @"-100";
    self.player1Score = self.player1Score - 100;
    self.player1ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player1Score];
    self.player1DeductReasonLabel.string = @"Hit Obstacle!";
    self.player1DeductReasonPlayerLabel.visible = YES;
    self.player1DeductReasonLabel.visible = YES;
    self.player1DeductPointsLabel.visible = YES;
    
    [self.player1DeductPointsLabel runAction:[CCFadeOut actionWithDuration:0.50]];
    if (self.player1OutOfBoundaries == YES) {
        [self.player1DeductReasonPlayerLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.50], [CCCallBlock actionWithBlock:^{
            self.player1DeductReasonPlayerLabel.visible = YES;
            self.player1DeductReasonPlayerLabel.opacity = 255;
        }], nil]];
        [self.player1DeductReasonLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.50], [CCCallBlock actionWithBlock:^{
            self.player1DeductReasonLabel.string = @"Out of Bounds!";
            self.player1DeductReasonLabel.visible = YES;
            self.player1DeductReasonLabel.opacity = 255;
        }], nil]];
    } else {
        [self.player1DeductReasonPlayerLabel runAction:[CCFadeOut actionWithDuration:0.50]];
        [self.player1DeductReasonLabel runAction:[CCFadeOut actionWithDuration:0.50]];
    }
}

-(void)deductPointsPlayer2HitObstacle {
    // show deduct points label
    self.player2DeductPointsLabel.string = @"-100";
    self.player2Score = self.player2Score - 100;
    self.player2ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player2Score];
    self.player2DeductReasonLabel.string = @"Hit Obstacle!";
    self.player2DeductReasonPlayerLabel.visible = YES;
    self.player2DeductReasonLabel.visible = YES;
    self.player2DeductPointsLabel.visible = YES;
    
    [self.player2DeductPointsLabel runAction:[CCFadeOut actionWithDuration:0.50]];
    if (self.player2OutOfBoundaries == YES) {
        [self.player2DeductReasonPlayerLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.50], [CCCallBlock actionWithBlock:^{
            self.player2DeductReasonPlayerLabel.visible = YES;
            self.player2DeductReasonPlayerLabel.opacity = 255;
        }], nil]];
        [self.player2DeductReasonLabel runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.50], [CCCallBlock actionWithBlock:^{
            self.player2DeductReasonLabel.string = @"Out of Bounds!";
            self.player2DeductReasonLabel.visible = YES;
            self.player2DeductReasonLabel.opacity = 255;
        }], nil]];
    } else {
        [self.player2DeductReasonPlayerLabel runAction:[CCFadeOut actionWithDuration:0.50]];
        [self.player2DeductReasonLabel runAction:[CCFadeOut actionWithDuration:0.50]];
    }
}

-(void)startCountdown {
    CCLOG(@"start countdown!");
    self.currentGameState = kGameStateCountdown;
    self.countdownTimerLabel.opacity = 255;
    self.countdownTimerLabel.string = @"3";
    self.timeToPlay = 3;
    [self.countdownTimerLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    
    [self schedule:@selector(initialCountdown:) interval:1];
}

-(void)endGame {
    CCLOG(@"end game!");
    self.currentGameState = kGameStateGameOver;
    [self unscheduleAllSelectors];
    [self unscheduleUpdate];
    self.gameTimerLabel.string = @"0";
    [self removeStartingPointForPlayer:1];
    [self removeStartingPointForPlayer:2];
    int winner = 1;
    if (self.player2Score > self.player1Score) {
        winner = 2;
    }
    [self.delegate showGameOverLayerForWinner:winner];
}

-(void)startGame {
    CCLOG(@"START GAME!");
    self.currentGameState = kGameStatePlay;
    [self scheduleUpdate];
    
    // add obstacles
    [self addObstacles];
    self.elapsedTime = 0;
    [self schedule:@selector(addObstaclesTick) interval:1];
    [self schedule:@selector(oneSecondTick:) interval:1];
}

-(void)addObstacles {
    CCLOG(@"add obstacles");
    [self resetRandomNumbers];
    for (int i=0; i<self.numOfObstaclesToAdd; i++) {
        int randomIndex = random() % [self.randomNumbers count];
        int randomNumber = [[self.randomNumbers objectAtIndex:randomIndex] intValue];
        [self.randomNumbers removeObjectAtIndex:randomIndex];
        
        CCSprite *obstacle = [CCSprite spriteWithFile:@"obstacle.png"];
        CCSprite *obstacle2 = [CCSprite spriteWithFile:@"obstacle.png"];
        obstacle.anchorPoint = ccp(0, 0);
        obstacle2.anchorPoint = ccp(0, 0);
        obstacle.position = ccp(randomNumber*2 * self.playerSpriteSize.width, self.screenSize.height);
        obstacle2.position = ccp(obstacle.position.x + self.playerSpriteSize.width, self.screenSize.height);
        
        obstacle.opacity = 127;
        obstacle2.opacity = 127;
        switch (randomNumber) {
            case 0:
                obstacle.color = ccc3(202, 38, 125);
                obstacle2.color = ccc3(166, 1, 35);
                break;
            case 1:
                obstacle.color = ccc3(195, 0, 0);
                obstacle2.color = ccc3(200, 0, 0);
                break;
            case 2:
                obstacle.color = ccc3(255, 45, 0);
                obstacle2.color = ccc3(220, 92, 1);
                break;
            case 3:
                obstacle.color = ccc3(237, 111, 0);
                obstacle2.color = ccc3(240, 157, 1);
                break;
            case 4:
                obstacle.color = ccc3(237, 245, 1);
                obstacle2.color = ccc3(153, 229, 0);
                break;
            case 5:
                obstacle.color = ccc3(0, 217, 78);
                obstacle2.color = ccc3(0, 198, 175);
                break;
            case 6:
                obstacle.color = ccc3(0, 228, 211);
                obstacle2.color = ccc3(0, 191, 233);
                break;
            case 7:
                obstacle.color = ccc3(1, 141, 252);
                obstacle2.color = ccc3(0, 109, 226);
                break;
            case 8:
                obstacle.color = ccc3(93, 7, 254);
                obstacle2.color = ccc3(88, 0, 146);
                break;
            case 9:
                obstacle.color = ccc3(98, 46, 131);
                obstacle2.color = ccc3(93, 93, 93);
                break;
            default:
                obstacle.color = ccc3(255, 255, 255);
                obstacle2.color = ccc3(255, 255, 255);
                break;
        }
        
        CCSprite *insideSquare = [CCSprite spriteWithFile:@"obstacle.png"];
        CCSprite *insideSquare2 = [CCSprite spriteWithFile:@"obstacle.png"];
        insideSquare.color = obstacle.color;
        insideSquare2.color = obstacle2.color;
        insideSquare.scale = 0.6;
        insideSquare2.scale = 0.6;
        insideSquare.position = ccp(obstacle.contentSize.width/2, obstacle.contentSize.height/2);
        insideSquare2.position = ccp(obstacle2.contentSize.width/2, obstacle.contentSize.height/2);
        [obstacle addChild:insideSquare];
        [obstacle2 addChild:insideSquare2];

        [self.obstacles addObject:obstacle];
        [self.obstacles addObject:obstacle2];
        [self.batchNode addChild:obstacle];
        [self.batchNode addChild:obstacle2];
    }
    
    if (self.elapsedTime < 5 || self.elapsedTime == 10 || self.elapsedTime == 15) {
        self.numOfObstaclesToAdd++;
    }
    
    if (self.numOfObstaclesToAdd >= self.maxObstacles-1) {
        self.numOfObstaclesToAdd = self.maxObstacles-1;
    } else if (self.elapsedTime > 20) {
        self.numOfObstaclesToAdd++;
    }
}

-(void)initialCountdown:(ccTime)dt {
    self.timeToPlay--;
    
    NSString *timerString;
    if (self.timeToPlay == 0) {
        timerString = @"GO!";
        [self unschedule:@selector(initialCountdown:)];
        [self startGame];
    } else {
        timerString = [NSString stringWithFormat:@"%i", self.timeToPlay];
    }
    
    self.countdownTimerLabel.string = timerString;
    
    // run action
    [self.countdownTimerLabel runAction:[CCSequence actions:[CCShow action], [CCFadeOut actionWithDuration:1.0f], nil]];
}

-(void)oneSecondTick:(ccTime)dt {
    self.elapsedTime++;
    // increase speed every 5 seconds
    if (self.elapsedTime == 5) {
        [self unschedule:@selector(addObstaclesTick)];
        [self schedule:@selector(addObstaclesTick) interval:0.75];
    }
    else if (self.elapsedTime == 10) {
        self.speedFactor = self.speedFactor * 1.25;
        self.immunityTime = 0.30;
    }
    else if (self.elapsedTime == 15) {
        [self unschedule:@selector(addObstaclesTick)];
        [self schedule:@selector(addObstaclesTick) interval:0.5];
    }
    else if (self.elapsedTime == 20) {
        self.speedFactor = self.speedFactor * 1.25;
        self.immunityTime = 0.15;
    }
    
    if (self.elapsedTime == 30) {
        [self endGame];
    } else {
        int timerInt = 30 - self.elapsedTime;
        self.gameTimerLabel.string = [NSString stringWithFormat:@"%i", timerInt];
//        [self.gameTimerLabel runAction:[CCSequence actions:[CCShow action], [CCFadeOut actionWithDuration:1.0f], nil]];
    }
}

-(void)addObstaclesTick {
    [self addObstacles];
    CCLOG(@"num of obstacles: %i", [self.obstacles count]);
    CCLOG(@"num of batchnode children: %i", [self.batchNode.children count]);
}

-(void)checkForCollision:(ccTime)delta {
    // update player hit obstacle time
    if (self.player1HitObstacle == YES) {
        self.player1TimeElapsedAfterHitObstacle = self.player1TimeElapsedAfterHitObstacle + delta;
        if (self.player1TimeElapsedAfterHitObstacle > self.immunityTime) {
            // player 1 is no longer immune to obstacles
            self.player1TimeElapsedAfterHitObstacle = 0;
            self.player1HitObstacle = NO;
        }
    }
    
    if (self.player2HitObstacle == YES) {
        self.player2TimeElapsedAfterHitObstacle = self.player2TimeElapsedAfterHitObstacle + delta;
        if (self.player2TimeElapsedAfterHitObstacle > self.immunityTime) {
            // player 2 is no longer immune to obstacles
            self.player2TimeElapsedAfterHitObstacle = 0;
            self.player2HitObstacle = NO;
        }
    }

    for (CCSprite* obstacle in self.obstacles) {
        // check if player fingers are touching an obstacle
        if (self.isPlayer1FingerOnScreen == YES) {
            if (self.player1HitObstacle == NO) {
                if (CGRectContainsPoint(obstacle.boundingBox, [self convertTouchToNodeSpace:self.player1Touch])) {
                    CCLOG(@"PLAYER 1 COLLISION!!!!");
                    [self deductPointsPlayer1HitObstacle];
                    self.player1HitObstacle = YES;
                }
            }
        }
        
        if (self.isPlayer2FingerOnScreen == YES) {
            if (self.player2HitObstacle == NO) {
                if (CGRectContainsPoint(obstacle.boundingBox, [self convertTouchToNodeSpace:self.player2Touch])) {
                    CCLOG(@"PLAYER 2 COLLISION!!!!");
                    [self deductPointsPlayer2HitObstacle];
                    self.player2HitObstacle = YES;
                }
            }
            
        }
    }
}

-(void)checkForOutOfBoundaries {
    // check if players have returned within boundaries
    CGPoint player1Location = [self convertTouchToNodeSpace:self.player1Touch];
    if (self.player1OutOfBoundaries == YES) {
        if (player1Location.y <= dashYBoundary || self.isPlayer1FingerOnScreen == NO) {
            self.player1OutOfBoundaries = NO;
            [self unschedule:@selector(deductPointsPlayer1OutOfBoundaries)];
            if (self.isPlayer1FingerOnScreen == NO) {
                self.player1DeductReasonLabel.string = @"Finger Removed!";
            } else {
                self.player1DeductReasonPlayerLabel.visible = NO;
                self.player1DeductReasonLabel.visible = NO;
            }
        }
    } else {
        if (player1Location.y > dashYBoundary && self.isPlayer1FingerOnScreen == YES) {
            self.player1OutOfBoundaries = YES;
            self.player1DeductReasonLabel.string = @"Out of Bounds!";
            self.player1DeductReasonPlayerLabel.visible = YES;
            self.player1DeductReasonPlayerLabel.opacity = 255;
            self.player1DeductReasonLabel.visible = YES;
            self.player1DeductReasonLabel.opacity = 255;
            [self deductPointsPlayer1OutOfBoundaries];
            [self schedule:@selector(deductPointsPlayer1OutOfBoundaries) interval:1];
        }
    }
    
    CGPoint player2Location = [self convertTouchToNodeSpace:self.player2Touch];
    if (self.player2OutOfBoundaries == YES) {
        if (player2Location.y <= dashYBoundary || self.isPlayer2FingerOnScreen == NO) {
            self.player2OutOfBoundaries = NO;
            [self unschedule:@selector(deductPointsPlayer2OutOfBoundaries)];
            if (self.isPlayer2FingerOnScreen == NO) {
                self.player2DeductReasonLabel.string = @"Finger Removed!";
            } else {
                self.player2DeductReasonPlayerLabel.visible = NO;
                self.player2DeductReasonLabel.visible = NO;
            }
        }
    } else {
        if (player2Location.y > dashYBoundary && self.isPlayer2FingerOnScreen == YES) {
            self.player2OutOfBoundaries = YES;
            self.player2DeductReasonLabel.string = @"Out of Bounds!";
            self.player2DeductReasonLabel.visible = YES;
            self.player2DeductReasonLabel.opacity = 255;
            self.player2DeductReasonPlayerLabel.visible = YES;
            self.player2DeductReasonPlayerLabel.opacity = 255;
            [self deductPointsPlayer2OutOfBoundaries];
            [self schedule:@selector(deductPointsPlayer2OutOfBoundaries) interval:1];
        }
    }
}

-(void)removeObstacles {
    CCLOG(@"remove obstacles!");
    [self.obstacles removeObjectsAtIndexes:self.indexesForObstaclesToBeRemoved];
    [self.indexesForObstaclesToBeRemoved removeAllIndexes];
}

-(void)update:(ccTime)delta {
    for (int i=0; i<[self.obstacles count]; i++) {
//    for (CCSprite *obstacle in self.batchNode.children) {
        CCSprite *obstacle = [self.obstacles objectAtIndex:i];
        if (obstacle != nil) {
            obstacle.position = ccp(obstacle.position.x, obstacle.position.y - delta * self.speedFactor);
            // remove obstacle if off screen
            if (obstacle.position.y < -obstacle.contentSize.height) {
                [self.indexesForObstaclesToBeRemoved addIndex:i];
                [obstacle removeAllChildrenWithCleanup:YES];
                [obstacle removeFromParentAndCleanup:YES];
            }
        }
    }
    
    if ([self.indexesForObstaclesToBeRemoved count] > 0) {
        [self removeObstacles];
    }
    [self checkForCollision:delta];
    [self checkForOutOfBoundaries];
    
    // update score
    self.player1Score++;
    self.player2Score++;
    
    self.player1ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player1Score];
    self.player2ScoreLabel.string = [NSString stringWithFormat:@"%i", self.player2Score];
}

@end
