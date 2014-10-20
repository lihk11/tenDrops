#define UP 1
#define DOWN 2
#define LEFT 3
#define RIGHT 4
//
//  GameScene.m
//  gametest2
//
//  Created by lihk11 on 14/10/9.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import "GameScene.h"
#import "MySprite.h"
#import "oneDrop.h"
#import "twoDrops.h"
#import "threeDrops.h"
#import "fourDrops.h"
#import "FlyDrop.h"
#import "Search.h"
#import "MyPoint.h"
#define kCellWidth 60
#define kCellHeight 60


@implementation GameScene
static const uint32_t waterDropCategory     =  0x1 << 0;
static const uint32_t flyDropCategory        =  0x1 << 1;

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    _mySpriteNum = 0;
    _flyDropsNum = 0;
    self.isLosed = NO;
    self.isClear = NO;
    self.level = 1;
    self.isAI = YES;
    self.remainingDropsLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    //self.action = [SKAction animateWithTextures:FOURDROPS_ANIM_FOURDROPS timePerFrame:0.033];
    self.remainingDrops = 10;
    self.remainingDropsLabel.fontSize = 50;
    self.remainingDropsLabel.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMidY(self.frame)+60));
    [self addChild:self.remainingDropsLabel];
    
    self.reTryLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.reTryLabel.fontSize = 50;
    self.reTryLabel.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMidY(self.frame)-30));
    self.reTryLabel.text = @"ReTry";
    
    self.nextLevelLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.nextLevelLabel.fontSize = 50;
    self.nextLevelLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                           (CGRectGetMidY(self.frame)-30));
    self.nextLevelLabel.text = @"Next Level!";
    
    self.locationLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.locationLabel.fontSize = 50;
    self.locationLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                               (CGRectGetMidY(self.frame)-90));
    self.locationLabel.text = @"";

    self.AILabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.AILabel.fontSize = 16;
    self.AILabel.position = CGPointMake(CGRectGetMidX(self.frame),0);
    if (self.isAI) {
        self.AILabel.text = @"AI Mode";
    } else {
        self.AILabel.text = @"Manual Mode";
    }
    [self addChild:self.AILabel];
    

    self.bonusLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.bonusLabel.fontSize = 25;
    self.bonusLabel.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMidY(self.frame)-90));
    self.bonusLabel.text = @"+ 1 bonus drop!";
    
    self.levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.levelLabel.fontSize = 20;
    self.levelLabel.position = CGPointMake(CGRectGetMidX(self.frame),(CGRectGetMidY(self.frame)+120));
    self.levelLabel.text = [NSString stringWithFormat:@"Level %ld",(long)self.level];
    [self addChild:self.levelLabel];
    SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    backgroundImage.size = self.frame.size;
    backgroundImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:backgroundImage];
//    CGPoint location =CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
//    SKTexture *texture = FOURDROPS_TEX_FOURDROPS_9;
    self.temp = 1;
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0,0);//重力设为0
    [self initMapWithLevel:self.level];
}
-(void)initMapWithLevel:(NSInteger)level{
    NSDictionary *maps = MAP_DICTIONARY;
    NSString *key = [NSString stringWithFormat:@"Level %ld",(long)level];
    NSArray *mapArray = [maps objectForKey:key];
    Search *search = [[Search alloc] initWithRemainingDrop:self.remainingDrops map:mapArray];
    NSArray *solution = [search solveWithEstimation];
    self.AISolution = solution;
    self.AIStep = 0;
    for (int i = 0; i<solution.count; i++) {
        MyPoint * point = [solution objectAtIndex:i];
        NSLog(@"%d : %d,%d",i,point.x,point.y);
    }
    for (int i = 1; i <= 6; i++) {
        for (int j = 1 ; j <= 6 ; j++) {
            NSString *indexString = [mapArray objectAtIndex:(i-1)*6+j-1];
            NSInteger index = [indexString integerValue];
            if (index != 0) {
                CGPoint location = CGPointMake(i * kCellWidth, j*kCellHeight - kCellHeight/7.0);
                MySprite *sprite = [MySprite spritewithStatusAndLocation:index location:location];
                sprite.userInteractionEnabled = YES;
                sprite.name = [NSString stringWithFormat:@"%d%d",i,j];
               // NSLog(sprite.name);
                //sprite.scale = 0.8;
                
                self.temp = self.temp+1;
                if(self.temp > 4 || self.temp <1){
                    self.temp = 1;
                }
                [self addChild:sprite];
                self.mySpriteNum = self.mySpriteNum + 1;
            }
        }
    }
    [self autoRun];
}

-(void)initMap{
    for (int i = 1; i <= 6; i++) {
        for (int j = 1 ; j <= 6 ; j++) {
            CGPoint location = CGPointMake(i * kCellWidth, j*kCellHeight - kCellHeight/7.0);
            MySprite *sprite = [MySprite spritewithStatusAndLocation:self.temp location:location];
            //sprite.position = location;
            sprite.status = self.temp;
            sprite.userInteractionEnabled = YES;
            //sprite.scale = 0.8;
            sprite.name = [NSString stringWithFormat:@"%d%d",(int)location.x,(int)location.y];
            NSLog(sprite.name);

            self.temp = self.temp+1;
            if(self.temp > 4 || self.temp <1){
                self.temp = 1;
            }
            
            [self addChild:sprite];
        }
    }
}
-(void)setRemainingDrops:(NSInteger)remainingDrops{
    _remainingDrops = remainingDrops;
    self.remainingDropsLabel.text = [NSString stringWithFormat:@"Drops: %ld",(long)remainingDrops];
    //输了
    if (remainingDrops == -1) {
        [self onGameOver];
    }
}
-(void)setFlyDropsNum:(NSInteger)flyDropsNum{
    _flyDropsNum = flyDropsNum;
   // NSLog(@"flyDropsNum:%ld  remainingDrops:%ld   mySpriteNum:%ld",(long)self.flyDropsNum,(long)self.remainingDrops,(long)self.mySpriteNum);
    if (self.flyDropsNum == 0 && self.remainingDrops == 0 && self.mySpriteNum > 0) {
        [self onGameOver];
    }
    if(self.flyDropsNum == 0){
    [self autoRun];
    }
}
-(void)autoRun{
    if (self.isAI && self.flyDropsNum == 0 && self.AIStep < self.AISolution.count) {
        MyPoint *point = [self.AISolution objectAtIndex:self.AIStep];
        NSString *name =[NSString stringWithFormat:@"%d%d",point.x,point.y];
        NSLog(name);
        MySprite *sprite = [self childNodeWithName:name];
        
        [self.locationLabel removeAllActions];
        [self.locationLabel removeFromParent];
        [self addChild:self.locationLabel];
        self.locationLabel.text = [NSString stringWithFormat:@"(%d,%d)",point.x,point.y];
        CGFloat duration = 3;
        SKAction *flashAction = [SKAction sequence:@[
                                                     [SKAction fadeInWithDuration:duration/3.0],
                                                     [SKAction waitForDuration:duration],
                                                     [SKAction fadeOutWithDuration:duration/7.0]
                                                     ]];
        [self.locationLabel runAction:flashAction completion:^{
            if(self.flyDropsNum == 0){
            //[self.locationLabel removeFromParent];
            self.AIStep ++;
            [sprite addDrop];
            self.ComboNum =0;
            self.remainingDrops --;
            }
        }];
        
        duration = 4;
        flashAction = [SKAction sequence:@[
                                                     [SKAction fadeInWithDuration:duration/3.0],
                                                     [SKAction waitForDuration:duration],
                                                     [SKAction fadeOutWithDuration:duration/7.0]
                                                     ]];
        [self.locationLabel runAction:flashAction completion:^{
            if(self.flyDropsNum == 0){
                //[self.locationLabel removeFromParent];
                [self autoRun];
        }
        }];

    }
}
-(void)setMySpriteNum:(NSInteger)mySpriteNum{
    _mySpriteNum = mySpriteNum;
    if (mySpriteNum == 0) {
        [self onClear];
    }
}
-(void)setComboNum:(NSInteger)ComboNum{
    _ComboNum = ComboNum;
    if (ComboNum == 3) {
        _ComboNum = 0;
        self.remainingDrops = self.remainingDrops + 1;
        [self showBonus];
    }
}
-(void)setLevel:(NSInteger)level
{
    _level = level;
    if (self.levelLabel) {
        self.levelLabel.text = [NSString stringWithFormat:@"Level %ld",(long)self.level];
    }
}
-(void)showBonus{
//    SKAction *action = [SKAction runBlock:^{
//        [self addChild:self.bonusLabel];
//    }];
//    action.duration = 1;
//    action = [SKAction sequence:@[action,//[SKAction waitForDuration:1],
//                                  [SKAction runBlock:^{
//        [self.bonusLabel removeFromParent];
//    }],
//
//                                  ]];
//    [self runAction:action];
    [self.bonusLabel removeAllActions];
    [self.bonusLabel removeFromParent];
    [self addChild:self.bonusLabel];
    CGFloat duration = 0.5;
    SKAction *flashAction = [SKAction sequence:@[
                                                 [SKAction fadeInWithDuration:duration/3.0],
                                                 [SKAction waitForDuration:duration],
                                                 [SKAction fadeOutWithDuration:duration/7.0]
                                                 ]];
    [self.bonusLabel runAction:flashAction completion:^{
                                        [self.bonusLabel removeFromParent];
                                        }];
}
-(void)onGameOver{
    [self removeAllChildren];
    self.remainingDropsLabel.text = @"Game Over!";
    [self addChild:self.remainingDropsLabel];
    [self addChild:self.reTryLabel];
    self.isLosed = YES;
}
-(void)onClear{
    self.isClear = YES;
    [self.bonusLabel removeAllActions];
    [self.bonusLabel removeFromParent];
    [self removeAllChildren];
    self.remainingDropsLabel.text = @"U Win!";
    [self addChild:self.remainingDropsLabel];
    if(self.level < 10){
        [self addChild:self.nextLevelLabel];
    }
    [self addChild:self.bonusLabel];
    [self addChild:self.levelLabel];
}
-(void)reTryLabelClicked{
    [self removeAllChildren];
    [self didMoveToView:nil];
}
-(void)AILabelClicked{
    self.isAI = !self.isAI;
    if (self.isAI) {
        self.AILabel.text = @"AI Mode";
    } else {
        self.AILabel.text = @"Manual Mode";
    }
    [self autoRun];
}
-(void)nextLevelLabelClicked{
    [self.nextLevelLabel removeFromParent];
    [self.bonusLabel removeFromParent];
    _mySpriteNum = 0;
    _flyDropsNum = 0;
    self.isLosed = NO;
    self.isClear = NO;
    self.remainingDrops = self.remainingDrops + 1;
    self.remainingDropsLabel.text = [NSString stringWithFormat:@"Drops: %ld",self.remainingDrops];
    SKSpriteNode *backgroundImage = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
    backgroundImage.size = self.frame.size;
    backgroundImage.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    [self addChild:backgroundImage];
    [self addChild:self.AILabel];
    self.level = self.level + 1;
    [self initMapWithLevel:self.level];
    
}
-(void)mouseDown:(NSEvent *)theEvent {
    CGPoint location = [theEvent locationInNode:self];
    /* Called when a mouse click occurs */
    if ([self.AILabel containsPoint:location]) {
        [self AILabelClicked];
        return;
    }

    if (self.isClear) {

        if ([self.nextLevelLabel containsPoint:location])
        {
            [self nextLevelLabelClicked];
        }
                return;
    }
    if (self.isLosed) {
        CGPoint location = [theEvent locationInNode:self];
        if ([self.reTryLabel containsPoint:location])
        {
            [self reTryLabelClicked];
        }
        return;
    }
    self.ComboNum = 0;
  //  NSLog(@"%f,%f",self.frame.size.width,self.frame.size.height);
     location = [theEvent locationInNode:self];
    MySprite *sprite = [MySprite spritewithStatusAndLocation:1 location:location];
    //sprite.position = location;
    sprite.userInteractionEnabled = YES;
    //sprite.scale = 0.8;
    self.temp = self.temp+1;
    if(self.temp > 4 || self.temp <1){
        self.temp = 1;
    }
    [self addChild:sprite];
    self.mySpriteNum = self.mySpriteNum + 1;
    self.remainingDrops = self.remainingDrops - 1;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    // 2
    if ((firstBody.categoryBitMask & waterDropCategory) != 0 &&
        (secondBody.categoryBitMask & flyDropCategory) != 0)
    {
        [self flyDrop:(FlyDrop *) secondBody.node didCollideWithSprite:(MySprite *) firstBody.node];
    }
}
//表示flyDrop碰撞了SpriteDrop
-(void)flyDrop:(FlyDrop *) flyDrop didCollideWithSprite:(MySprite *)mySprite{
    if(flyDrop.splitedFromWaterDrop != mySprite && flyDrop.collidedWaterDrop != mySprite){
       // NSLog(@"Collision");
        flyDrop.collidedWaterDrop = mySprite;
        [flyDrop removeAllActions];
        self.flyDropsNum = self.flyDropsNum - 1;
        [flyDrop removeFromParent];
        [mySprite addDrop];
    }
}

@end
