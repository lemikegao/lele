//
//  GameLayer.m
//  lele
//
//  Created by Michael Gao on 12/27/12.
//
//

#import "GameLayer.h"
#import "CCBlade.h"

@interface GameLayer ()

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
@property (nonatomic, strong) CCLabelTTF *timerLabel;
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
@property (nonatomic) CFMutableDictionaryRef map;

@end

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"GameLayer.m->init");
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
        self.map = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
        
        self.timerLabel = [CCLabelTTF labelWithString:@"3" dimensions:CGSizeMake(self.screenSize.width/2, self.screenSize.height/2) hAlignment:kCCTextAlignmentCenter fontName:@"Helvetica" fontSize:64];
        self.timerLabel.position = ccp(self.screenSize.width/2, self.screenSize.height/2);
        self.timerLabel.opacity = 0;
        [self addChild:self.timerLabel z:1000];
        
        // init obstacles
        self.obstacles = [[NSMutableArray alloc] initWithCapacity:100];
        // set up batch node for players and obstacles
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"player_start.png" capacity:100];
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
        
        [self addPlayerStartingPoints];
        
        [self initScore];
    }
    
    return self;
}

-(void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [[CCDirector sharedDirector] convertToGL:[touch locationInView:[touch view]]];
//        CCLOG(@"player sprite size width: %f", self.playerSpriteSize.width);
//        CCLOG(@"touch location: %@, player 1 sprite location: %@", NSStringFromCGPoint(location), NSStringFromCGPoint(self.player1Sprite.position));
        
        // testing finger trail
        CCBlade *w = [CCBlade bladeWithMaximumPoint:50];
        w.autoDim = YES;
        w.texture = [[CCTextureCache sharedTextureCache] addImage:@"streak3.png"];
        CFDictionaryAddValue(self.map,(__bridge const void *)(touch),(__bridge void*)w);
        [self addChild:w];
		[w push:location];
        
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
        
        // testing finger trail
        CCBlade *w = (CCBlade *)CFDictionaryGetValue(self.map, (__bridge const void *)(touch));
		[w push:newLocation];
        
        if (self.player1Touch == touch) {
            CCLOG(@"player 1 moved");
            self.player1Sprite.position = ccpAdd(self.player1Sprite.position, ccpSub(newLocation, previousLocation));
        } else if (self.player2Touch == touch) {
            CCLOG(@"player 2 moved");
            self.player2Sprite.position = ccpAdd(self.player2Sprite.position, ccpSub(newLocation, previousLocation));
        } else {
//            CCLOG(@"Unknown touch moved");
        }
    }
}

-(void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        //testing finger trail
        CCBlade *w = (CCBlade *)CFDictionaryGetValue(self.map, (__bridge const void *)(touch));
        [w finish];
        CFDictionaryRemoveValue(self.map,(__bridge const void *)(touch));
        
        if (self.player1Touch == touch) {
            self.isPlayer1FingerOnScreen = NO;
        } else if (self.player2Touch == touch) {
            self.isPlayer2FingerOnScreen = NO;
        }
        
        if (self.currentGameState == kGameStateCountdown) {
            [self unscheduleAllSelectors];
            self.currentGameState = kGameStateNone;
        } else if (self.currentGameState == kGameStatePlay) {
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
                [self schedule:@selector(deductPointsPlayer1RemovedFinger) interval:0.5];
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
                [self schedule:@selector(deductPointsPlayer2RemovedFinger) interval:0.5];
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

-(void)addPlayerStartingPoints {
    self.player1Sprite = [CCSprite spriteWithFile:@"player_start.png"];
    self.player1Sprite.anchorPoint = ccp(0, 0);
    self.player1Sprite.position = ccp(self.screenSize.width * 0.05f, self.screenSize.height * 0.05f);
    [self addChild:self.player1Sprite];
    
    self.player2Sprite = [CCSprite spriteWithFile:@"player_start.png"];
    self.player2Sprite.anchorPoint = ccp(1, 0);
    self.player2Sprite.position = ccp(self.screenSize.width * 0.95f, self.screenSize.height * 0.05f);
    [self addChild:self.player2Sprite];
    
    self.playerSpriteSize = self.player1Sprite.boundingBox.size;
    self.maxObstacles = self.screenSize.width/self.playerSpriteSize.width/2;
    self.randomNumbers = [[NSMutableArray alloc] initWithCapacity:self.maxObstacles];
    CCLOG(@"max obstacles: %i", self.maxObstacles);
}

-(void)initScore {
    // add Player 1 and Player 2 label
    CCLabelBMFont *player1Label = [CCLabelBMFont labelWithString:@"PLAYER 1" fntFile:@"nexalight_20px.fnt"];
    CCLabelBMFont *player2Label = [CCLabelBMFont labelWithString:@"PLAYER 2" fntFile:@"nexalight_20px.fnt"];
    player1Label.color = ccc3(221, 49, 135);
    player2Label.color = ccc3(104, 193, 104);
    player1Label.anchorPoint = ccp(0, 1);
    player2Label.anchorPoint = ccp(1, 1);
    player1Label.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.98);
    player2Label.position = ccp(self.screenSize.width * 0.95, self.screenSize.height * 0.98);
    
    // set up player scores
    self.player1Score = 0;
    self.player2Score = 0;
    self.player1ScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"nexalight_60px.fnt"];
    self.player2ScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"nexalight_60px.fnt"];
    self.player1ScoreLabel.color = ccc3(221, 49, 135);
    self.player2ScoreLabel.color = ccc3(104, 193, 104);
    self.player1ScoreLabel.anchorPoint = ccp(0, 1);
    self.player1ScoreLabel.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.95);
    self.player2ScoreLabel.anchorPoint = ccp(1, 1);
    self.player2ScoreLabel.position = ccp(self.screenSize.width * 0.95, self.screenSize.height * 0.95);
    
    // set up player deduct points labels
    self.player1DeductPointsLabel = [CCLabelBMFont labelWithString:@"-100" fntFile:@"nexabold_100px.fnt"];
    self.player2DeductPointsLabel = [CCLabelBMFont labelWithString:@"-100" fntFile:@"nexabold_100px.fnt"];
    self.player1DeductPointsLabel.color = ccc3(221, 49, 135);
    self.player2DeductPointsLabel.color = ccc3(104, 193, 104);
    self.player1DeductPointsLabel.anchorPoint = ccp(0, 1);
    self.player2DeductPointsLabel.anchorPoint = ccp(1, 1);
    self.player1DeductPointsLabel.position = ccp(self.screenSize.width * 0.07, self.screenSize.height * 0.85);
    self.player2DeductPointsLabel.position = ccp(self.screenSize.width * 0.93, self.screenSize.height * 0.85);
    self.player1DeductPointsLabel.visible = NO;
    self.player2DeductPointsLabel.visible = NO;
    
    // set up player deduct reason player labels
    self.player1DeductReasonPlayerLabel = [CCLabelBMFont labelWithString:@"Player 1" fntFile:@"nexabold_40px.fnt"];
    self.player2DeductReasonPlayerLabel = [CCLabelBMFont labelWithString:@"Player 2" fntFile:@"nexabold_40px.fnt"];
    self.player1DeductReasonPlayerLabel.color = ccc3(221, 49, 135);
    self.player2DeductReasonPlayerLabel.color = ccc3(104, 193, 104);
    self.player1DeductReasonPlayerLabel.anchorPoint = ccp(0, 1);
    self.player2DeductReasonPlayerLabel.anchorPoint = ccp(0, 1);
    self.player1DeductReasonPlayerLabel.position = ccp(self.screenSize.width * 0.27, self.screenSize.height * 0.97);
    self.player2DeductReasonPlayerLabel.position = ccp(self.screenSize.width * 0.27, self.screenSize.height * 0.91);
    self.player1DeductReasonPlayerLabel.visible = NO;
    self.player2DeductReasonPlayerLabel.visible = NO;
    
    // set up player deduct reason labels
    self.player1DeductReasonLabel = [CCLabelBMFont labelWithString:@"Finger Removed!" fntFile:@"nexalight_40px.fnt"];
    self.player2DeductReasonLabel = [CCLabelBMFont labelWithString:@"Finger Removed!" fntFile:@"nexalight_40px.fnt"];
    self.player1DeductReasonLabel.color = ccc3(221, 49, 135);
    self.player2DeductReasonLabel.color = ccc3(104, 193, 104);
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

-(void) startCountdown {
    CCLOG(@"start countdown!");
    self.currentGameState = kGameStateCountdown;
    self.timerLabel.opacity = 255;
    self.timerLabel.string = @"3";
    self.timeToPlay = 3;
    [self.timerLabel runAction:[CCFadeOut actionWithDuration:1.0f]];
    
    [self schedule:@selector(initialCountdown:) interval:1];
}

-(void) endGame {
    CCLOG(@"end game!");
    self.currentGameState = kGameStateGameOver;
    [self unscheduleAllSelectors];
    [self unscheduleUpdate];
    [self.timerLabel stopAllActions];
    self.timerLabel.string = @"GAME OVER";
    self.timerLabel.opacity = 255;
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
        
        CCSprite *obstacle = [CCSprite spriteWithFile:@"player_start.png"];
        CCSprite *obstacle2 = [CCSprite spriteWithFile:@"player_start.png"];
        obstacle.anchorPoint = ccp(0, 0);
        obstacle2.anchorPoint = ccp(0, 0);
        obstacle.position = ccp(randomNumber*2 * self.playerSpriteSize.width, self.screenSize.height);
        obstacle2.position = ccp(obstacle.position.x + self.playerSpriteSize.width, self.screenSize.height);
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
    if (self.timeToPlay == 0) {
        [self unschedule:@selector(initialCountdown:)];
        [self startGame];
    } else {
        self.timeToPlay--;
        
        self.timeToPlay = 0; // speeds up the countdown
        
        NSString *timerString;
        if (self.timeToPlay == 0) {
            timerString = @"GO";
        } else {
            timerString = [NSString stringWithFormat:@"%i", self.timeToPlay];
        }
        
        self.timerLabel.string = timerString;
        
        // run action
        [self.timerLabel runAction:[CCSequence actions:[CCShow action], [CCFadeOut actionWithDuration:1.0f], nil]];
    }
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
        self.timerLabel.string = [NSString stringWithFormat:@"%i", timerInt];
        [self.timerLabel runAction:[CCSequence actions:[CCShow action], [CCFadeOut actionWithDuration:1.0f], nil]];
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
            [self schedule:@selector(deductPointsPlayer1OutOfBoundaries) interval:0.5];
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
            [self schedule:@selector(deductPointsPlayer2OutOfBoundaries) interval:0.5];
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
