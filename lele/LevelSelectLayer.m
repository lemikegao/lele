//
//  LevelSelectLayer.m
//  lele
//
//  Created by Michael Gao on 1/29/13.
//
//

#import "LevelSelectLayer.h"
#import "CCTouchDownMenu.h"

@interface LevelSelectLayer ()

@property (nonatomic) CGSize screenSize;
@property (nonatomic) int currentPageNum;
@property (nonatomic, strong) CCLabelBMFont *currentPageLabel;
@property (nonatomic, strong) CCMenuItem *leftArrow;
@property (nonatomic, strong) CCMenuItem *rightArrow;

@end

@implementation LevelSelectLayer

int maxPages = 2;

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.currentPageNum = 1;
        
        [self initStaticLabels];
        [self initSideArrows];
        [self initLevels];
    }
    
    return self;
}

-(void)initStaticLabels {
    CCLabelBMFont *selectLevelLabel = [CCLabelBMFont labelWithString:@"Select Level" fntFile:@"nexabold_40px.fnt"];
    selectLevelLabel.color = timerColor;
    selectLevelLabel.anchorPoint = ccp(0.5, 1);
    selectLevelLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.97);
    [self addChild:selectLevelLabel];
    
    self.currentPageLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"1 / %i", maxPages] fntFile:@"nexalight_26px.fnt"];
    self.currentPageLabel.color = timerColor;
    self.currentPageLabel.anchorPoint = ccp(0.5, 0);
    self.currentPageLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.03);
    [self addChild:self.currentPageLabel];
}

-(void)initSideArrows {
    CCLayerColor *leftSidebar = [CCLayerColor layerWithColor:ccc4(0,0,0,255) width:self.screenSize.width*0.12 height:self.screenSize.height];
    CCLayerColor *rightSidebar = [CCLayerColor layerWithColor:ccc4(0,0,0,255) width:self.screenSize.width*0.12 height:self.screenSize.height];
    leftSidebar.anchorPoint = ccp(0, 0);
    rightSidebar.anchorPoint = ccp(1, 0);
    rightSidebar.ignoreAnchorPointForPosition = NO;
    leftSidebar.position = ccp(0, 0);
    rightSidebar.position = ccp(self.screenSize.width, 0);
    
    [self addChild:leftSidebar z:500];
    [self addChild:rightSidebar z:500];
    
    self.leftArrow = [CCMenuItemImage itemWithNormalImage:@"lvlselect_button_arrow.png" selectedImage:@"lvlselect_button_arrow_pressed.png" disabledImage:@"lvlselect_button_arrow_pressed.png" target:self selector:@selector(scrollLevelsMenuLeft)];
    self.leftArrow.isEnabled = NO;
    self.leftArrow.rotation = 180;
    self.leftArrow.anchorPoint = ccp(0, 0.5);
    self.leftArrow.position = ccp(leftSidebar.contentSize.width*0.99, self.screenSize.height*0.5);
    
    self.rightArrow = [CCMenuItemImage itemWithNormalImage:@"lvlselect_button_arrow.png" selectedImage:@"lvlselect_button_arrow_pressed.png" disabledImage:@"lvlselect_button_arrow_pressed.png" target:self selector:@selector(scrollLevelsMenuRight)];
    self.rightArrow.anchorPoint = ccp(0, 0.5);
   self.rightArrow.position = ccp(self.screenSize.width - rightSidebar.contentSize.width*0.99, self.screenSize.height*0.5);
    
    CCMenu *sideArrowsMenu = [CCMenu menuWithItems:self.leftArrow, self.rightArrow, nil];
    sideArrowsMenu.anchorPoint = ccp(0, 0);
    sideArrowsMenu.position = ccp(0, 0);
    [self addChild:sideArrowsMenu z:1000];
}

-(void)initLevels {
    CCMenuItem *lvl1 = [CCMenuItemImage itemWithNormalImage:@"lvlselect1.png" selectedImage:nil block:^(id sender) {
        [self.delegate showDescriptionForLevel:1];
    }];
    lvl1.position = ccp(-self.screenSize.width * 0.16, self.screenSize.height * 0.20);
    CCLabelBMFont *lvl1Label = [CCLabelBMFont labelWithString:@"Raining Colors" fntFile:@"nexalight_26px.fnt"];
    lvl1Label.color = timerColor;
    lvl1Label.anchorPoint = ccp(0.5, 1);
    lvl1Label.position = ccp(lvl1.contentSize.width * 0.5, -10);
    [lvl1 addChild:lvl1Label];
    
    CCMenuItem *lvl2 = [CCMenuItemImage itemWithNormalImage:@"lvlselect2.png" selectedImage:nil block:^(id sender) {
        [self.delegate showDescriptionForLevel:2];
    }];
    lvl2.position = ccp(self.screenSize.width * 0.16, self.screenSize.height * 0.20);
    CCLabelBMFont *lvl2Label = [CCLabelBMFont labelWithString:@"Finger Sumo" fntFile:@"nexalight_26px.fnt"];
    lvl2Label.color = timerColor;
    lvl2Label.anchorPoint = ccp(0.5, 1);
    lvl2Label.position = ccp(lvl2.contentSize.width * 0.5, -10);
    [lvl2 addChild:lvl2Label];
    
    CCMenuItem *lvl3 = [CCMenuItemImage itemWithNormalImage:@"lvlselect3.png" selectedImage:nil block:^(id sender) {
        [self.delegate showDescriptionForLevel:3];
    }];
    lvl3.position = ccp(-self.screenSize.width * 0.16, -self.screenSize.height * 0.20);
    CCLabelBMFont *lvl3Label = [CCLabelBMFont labelWithString:@"Orb Dodge" fntFile:@"nexalight_26px.fnt"];
    lvl3Label.color = timerColor;
    lvl3Label.anchorPoint = ccp(0.5, 1);
    lvl3Label.position = ccp(lvl3.contentSize.width * 0.5, -10);
    [lvl3 addChild:lvl3Label];
    
    CCMenuItem *lvl4 = [CCMenuItemImage itemWithNormalImage:@"lvlselect4.png" selectedImage:nil block:^(id sender) {
        [self.delegate showDescriptionForLevel:4];
    }];
    lvl4.position = ccp(self.screenSize.width * 0.16, -self.screenSize.height * 0.20);
    CCLabelBMFont *lvl4Label = [CCLabelBMFont labelWithString:@"Tap and Switch" fntFile:@"nexalight_26px.fnt"];
    lvl4Label.color = timerColor;
    lvl4Label.anchorPoint = ccp(0.5, 1);
    lvl4Label.position = ccp(lvl3.contentSize.width * 0.5, -10);
    [lvl4 addChild:lvl4Label];
    
    // temp add page 2
    CCMenuItem *lvl5 = [CCMenuItemImage itemWithNormalImage:@"lvlselect_soon.png" selectedImage:nil block:^(id sender) {
        CCLOG(@"lvl5 selected");
    }];
    lvl5.position = ccp(-self.screenSize.width * 0.16 + self.screenSize.width, self.screenSize.height * 0.20);
    CCLabelBMFont *lvl5Label = [CCLabelBMFont labelWithString:@"Coming Soon" fntFile:@"nexalight_26px.fnt"];
    lvl5Label.color = timerColor;
    lvl5Label.anchorPoint = ccp(0.5, 1);
    lvl5Label.position = ccp(lvl3.contentSize.width * 0.5, -10);
    [lvl5 addChild:lvl5Label];
    
    self.levelsMenu = [CCTouchDownMenu menuWithItems:lvl1, lvl2, lvl3, lvl4, lvl5, nil];
    self.levelsMenu.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);

    [self addChild:self.levelsMenu];
}

-(void)updateCurrentPageLabel {
    self.currentPageLabel.string = [NSString stringWithFormat:@"%i / %i", self.currentPageNum, maxPages];
}

-(void)scrollLevelsMenuRight {
    if ([self.levelsMenu numberOfRunningActions] == 0) {
        [self.levelsMenu runAction:[CCMoveBy actionWithDuration:0.15 position:ccp(-self.screenSize.width, 0)]];
        self.currentPageNum++;
        [self updateCurrentPageLabel];
        
        if (self.currentPageNum == 1) {
            self.leftArrow.isEnabled = NO;
        } else {
            self.leftArrow.isEnabled = YES;
        }
        
        if (self.currentPageNum == maxPages) {
            self.rightArrow.isEnabled = NO;
        } else {
            self.rightArrow.isEnabled = YES;
        }
    }
}

-(void)scrollLevelsMenuLeft {
    if ([self.levelsMenu numberOfRunningActions] == 0) {
        [self.levelsMenu runAction:[CCMoveBy actionWithDuration:0.15 position:ccp(self.screenSize.width, 0)]];
        self.currentPageNum--;
        [self updateCurrentPageLabel];
        
        if (self.currentPageNum == 1) {
            self.leftArrow.isEnabled = NO;
        } else {
            self.leftArrow.isEnabled = YES;
        }
        
        if (self.currentPageNum == maxPages) {
            self.rightArrow.isEnabled = NO;
        } else {
            self.rightArrow.isEnabled = YES;
        }
    }
}

@end
