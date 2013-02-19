//
//  LevelInfoLayer.m
//  lele
//
//  Created by Michael Gao on 1/30/13.
//
//

#import "LevelInfoLayer.h"
#import "CCTouchDownMenu.h"
#import "GameManager.h"

@interface LevelInfoLayer ()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSprite *bigLevelPreview;
@property (nonatomic, strong) CCLabelBMFont *levelNameLabel;
@property (nonatomic, strong) CCLabelBMFont *levelDescriptionLabel;
@property (nonatomic) int selectedLevelNum;

@end

@implementation LevelInfoLayer

NSString *lvl1Title = @"Raining Colors";
NSString *lvl2Title = @"Finger Sumo";
NSString *lvl3Title = @"Orb Dodge";
NSString *lvl4Title = @"Tap and Switch";

NSString *lvl1Description = @"It's raining colors! But don't let the colors fool you - avoid being hit by them or you'll lose precious points. Also, keep your finger on the screen and stay below the dashed lines at all times.\n\nWinner is the player with most points at the end..";
NSString *lvl2Description = @"Knock the opponent's finger out of the circle or off the screen to be the winner. But beware...the circle will shrink if you take too long.";
NSString *lvl3Description = @"Use your other fingers to throw orbs at your opponent. You will lose a life if you get hit or move outside the dashed lines.\n\nWinner is the player who gets their opponent to 0 lives first..";
NSString *lvl4Description = @"Classic Tug of War with a twist. Fill the entire screen with your player color by tapping your color circle to win! But wait...catch your opponent off guard by switching tap spaces with the switch button.";

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;

        [self initLayerStructure];
    }
    
    return self;
}

-(void)initLayerStructure {
    self.bigLevelPreview = [CCSprite spriteWithFile:@"lvlselect1_big.png"];
    self.bigLevelPreview.anchorPoint = ccp(0, 0.5);
    self.bigLevelPreview.position = ccp(self.screenSize.width * 0.05, self.screenSize.height * 0.5);
    [self addChild:self.bigLevelPreview];
    
    self.levelNameLabel = [CCLabelBMFont labelWithString:lvl1Title fntFile:@"nexabold_40px.fnt"];
    self.levelNameLabel.color = timerColor;
    self.levelNameLabel.anchorPoint = ccp(0, 1);
    self.levelNameLabel.position = ccp(self.bigLevelPreview.position.x + self.bigLevelPreview.contentSize.width + 35, self.bigLevelPreview.position.y + self.bigLevelPreview.contentSize.height*0.5);
    
    self.levelDescriptionLabel = [CCLabelBMFont labelWithString:lvl1Description fntFile:@"nexalight_36px.fnt" width:self.screenSize.width*0.45 alignment:kCCTextAlignmentLeft];
    self.levelDescriptionLabel.color = lvlDescriptionColor;
    self.levelDescriptionLabel.anchorPoint = ccp(0, 1);
    self.levelDescriptionLabel.position = ccp(self.levelNameLabel.position.x, self.levelNameLabel.position.y - 55);
    
    [self addChild:self.levelNameLabel];
    [self addChild:self.levelDescriptionLabel];
    
    // add back and play buttons
    CCMenuItem *backButton = [CCMenuItemImage itemWithNormalImage:@"lvlselect_button_back.png" selectedImage:nil block:^(id sender) {
        [self.delegate hideDescription];
    }];
    backButton.anchorPoint = ccp(0, 0);
    backButton.position = ccp(self.levelNameLabel.position.x - 10, self.bigLevelPreview.position.y - self.bigLevelPreview.contentSize.height * 0.5 - 10);
    
    CCMenuItem *playButton = [CCMenuItemImage itemWithNormalImage:@"lvlselect_button_play.png" selectedImage:nil block:^(id sender) {
        switch (self.selectedLevelNum) {
            case 1:
                [[GameManager sharedGameManager] runSceneWithID:kSceneTypeRainingColors];
                break;
            case 2:
                [[GameManager sharedGameManager] runSceneWithID:kSceneTypeSumoFinger];
                break;
            case 3:
                [[GameManager sharedGameManager] runSceneWithID:kSceneTypeOrbDodge];
                break;
            case 4:
                [[GameManager sharedGameManager] runSceneWithID:kSceneTypeTapAndSwitch];
                break;
            default:
                break;
        }
    }];
    playButton.anchorPoint = ccp(1, 0);
    playButton.position = ccp(self.levelDescriptionLabel.position.x + self.screenSize.width*0.45, backButton.position.y);
    
    CCMenu *menu = [CCTouchDownMenu menuWithItems:backButton, playButton, nil];
    menu.anchorPoint = ccp(0, 0);
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)showDescriptionForLevel:(int)levelNum {
    self.selectedLevelNum = levelNum;
    self.bigLevelPreview.texture = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"lvlselect%i_big.png", levelNum]];
    
    switch (levelNum) {
        case 1:
            self.levelNameLabel.string = lvl1Title;
            self.levelDescriptionLabel.string = lvl1Description;
            break;
        case 2:
            self.levelNameLabel.string = lvl2Title;
            self.levelDescriptionLabel.string = lvl2Description;
            break;
        case 3:
            self.levelNameLabel.string = lvl3Title;
            self.levelDescriptionLabel.string = lvl3Description;
            break;
        case 4:
            self.levelNameLabel.string = lvl4Title;
            self.levelDescriptionLabel.string = lvl4Description;
            break;
        default:
            break;
    }
}

@end
