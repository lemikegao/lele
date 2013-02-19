//
//  Orb.m
//  lele
//
//  Created by Michael Gao on 1/27/13.
//
//

#import "Orb.h"

@implementation Orb

+(id)orbForPlayer:(int)playerNum atLocation:(CGPoint)location withTouch:(UITouch*)touch {
    return [[self alloc] initForPlayer:playerNum atLocation:location withTouch:touch];
}

-(id)initForPlayer:(int)playerNum atLocation:(CGPoint)location withTouch:(UITouch*)touch {
    self = [super initWithFile:@"playercircle_white.png"];
    
    self.position = location;
    self.opacity = 100;
    CCSprite *orbLayer2 = [CCSprite spriteWithFile:@"playercircle_white.png"];
    orbLayer2.scale = 0.75;
    orbLayer2.position = ccp(self.contentSize.width * 0.5, self.contentSize.height * 0.5);
    CCSprite *orbLayer3 = [CCSprite spriteWithFile:@"playercircle_white.png"];
    orbLayer3.color = ccc3(0,0,0);
    orbLayer3.scale = 0.67;
    orbLayer3.position = ccp(orbLayer2.contentSize.width * 0.5, orbLayer2.contentSize.height * 0.5);
    
    [orbLayer2 addChild:orbLayer3];
    
    if (playerNum == 1) {
        self.color = player1Color;
        orbLayer2.color = player1Color;
    } else if (playerNum == 2) {
        self.color = player2Color;
        orbLayer2.color = player2Color;
    }
    
    [self addChild:orbLayer2];
    
    _touch = touch;
    _xDelta = 0;
    _yDelta = 0;
    
    return self;
}

@end
