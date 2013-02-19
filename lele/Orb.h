//
//  Orb.h
//  lele
//
//  Created by Michael Gao on 1/27/13.
//
//

#import "CCSprite.h"

@interface Orb : CCSprite

@property (nonatomic, strong) UITouch *touch;
@property (nonatomic) float xDelta;
@property (nonatomic) float yDelta;
@property (nonatomic) float slope;
@property (nonatomic) float b;
@property (nonatomic) float speed;

+(id)orbForPlayer:(int)playerNum atLocation:(CGPoint)location withTouch:(UITouch*)touch;

@end
