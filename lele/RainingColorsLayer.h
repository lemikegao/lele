//
//  GameLayer.h
//  lele
//
//  Created by Michael Gao on 12/27/12.
//
//

#import "CCLayer.h"
#import "Constants.h"
#import "RainingColorsScene.h"

@interface RainingColorsLayer : CCLayer

@property (nonatomic, weak) RainingColorsScene *delegate;

@end
