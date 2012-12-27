//
//  GameLayer.m
//  lele
//
//  Created by Michael Gao on 12/27/12.
//
//

#import "GameLayer.h"

@interface GameLayer ()

@property (nonatomic) CGSize screenSize;

@end

@implementation GameLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        CCLOG(@"GameLayer.m->init");
        self.screenSize = [CCDirector sharedDirector].winSize;
        [self addPlayerStartingPoints];
    }
    
    return self;
}

-(void) addPlayerStartingPoints {
    CCSprite *player1Start = [CCSprite spriteWithFile:@"player_start.png"];
    player1Start.anchorPoint = ccp(0, 0);
    player1Start.position = ccp(self.screenSize.width * 0.05f, self.screenSize.height * 0.05f);
    [self addChild:player1Start];
    
    CCSprite *player2Start = [CCSprite spriteWithFile:@"player_start.png"];
    player2Start.anchorPoint = ccp(1, 0);
    player2Start.position = ccp(self.screenSize.width * 0.95f, self.screenSize.height * 0.05f);
    [self addChild:player2Start];
}

@end
