//
//  GameScene.h
//  gametest2
//

//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene<SKPhysicsContactDelegate>
@property (nonatomic) SKAction *action;
@property (nonatomic) NSInteger temp;
@property (nonatomic) SKLabelNode *remainingDropsLabel;
@property (nonatomic) SKLabelNode *reTryLabel;
@property (nonatomic) SKLabelNode *nextLevelLabel;
@property (nonatomic) SKLabelNode *bonusLabel;
@property (nonatomic) SKLabelNode *levelLabel;
@property (nonatomic) SKLabelNode *locationLabel;
@property (nonatomic) SKLabelNode *AILabel;
@property (nonatomic) NSInteger remainingDrops;
@property (nonatomic) NSInteger mySpriteNum;
@property (nonatomic) NSInteger flyDropsNum;
@property (nonatomic) NSInteger level;
@property (atomic) NSInteger ComboNum;
@property (nonatomic) BOOL isLosed;
@property (nonatomic) BOOL isClear;
@property (nonatomic) BOOL isAI;
@property (nonatomic) NSArray *AISolution;
@property (nonatomic) NSInteger AIStep;
-(void)onGameOver;
@end
