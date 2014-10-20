//
//  drop.m
//  gametest2
//
//  Created by lihk11 on 14/10/13.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import "FlyDrop.h"
#include "drop.h"
#import "dropSplit.h"
#import "fourSplit.h"
#import "GameScene.h"
#import "MyPoint.h"
#define kWindowWidth 420
#define kWindowHeight 394
#define kSpeed 140.0
//#define kSpeed 10.0
@implementation FlyDrop

static const uint32_t waterDropCategory     =  0x1 << 0;
static const uint32_t flyDropCategory        =  0x1 << 1;

+(instancetype)spritewithDirectionAndLocation:(NSInteger)direction location:(CGPoint)location{
    FlyDrop *drop  = [FlyDrop spriteNodeWithImageNamed:@"drop_1"];
    drop.direction = direction;
    drop.position = location;
    [drop setupAction];
    drop.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:drop.size.width/2];
    drop.physicsBody.dynamic = YES;
    drop.physicsBody.categoryBitMask = flyDropCategory;
    drop.physicsBody.contactTestBitMask = waterDropCategory;
    drop.physicsBody.collisionBitMask = 0;
    //drop.physicsBody.usesPreciseCollisionDetection = YES;
    return drop;
}
-(void)setDirection:(NSInteger)direction{
    if (direction<1||direction>4) {
        self.direction = 1;
        return;
    }
    _direction = direction;
}
-(void)setupAction{
    SKAction *action;
    SKAction *moveAction;
    CGFloat angle;
    CGFloat actualDuration;
    switch (self.direction) {
        case DIRECTION_UP:
            actualDuration = (kWindowHeight - self.position.y)/kSpeed;
            angle = M_PI/2;
            moveAction = [SKAction moveToY:kWindowHeight  duration:actualDuration];
            break;
        case DIRECTION_DOWN:
            actualDuration = self.position.y / kSpeed;
            angle = -M_PI/2;
            moveAction = [SKAction moveToY:0  duration:actualDuration];
            break;
        case DIRECTION_LEFT:
            actualDuration = self.position.x / kSpeed;
            angle =  M_PI;
            moveAction = [SKAction moveToX:0 duration:actualDuration];
            break;
        case DIRECTION_RIGHT:
            actualDuration = (kWindowWidth- self.position.x) / kSpeed;
            angle = 0;
            moveAction = [SKAction moveToX:kWindowWidth duration:actualDuration];
            break;
        default:
            break;
    }
    action = [SKAction rotateByAngle:angle duration:0];
    [self runAction:action];
    action = [SKAction sequence:@[
                                  moveAction,
                                 [SKAction runBlock:^{
        GameScene *parent =  (GameScene*)self.parent;
        parent.flyDropsNum = parent.flyDropsNum - 1;
//        if (parent.isAI && parent.flyDropsNum == 0 && parent.AIStep<parent.AISolution.count) {
//            MyPoint *point = [parent.AISolution objectAtIndex:parent.AIStep];
//            MySprite *sprite = [parent childNodeWithName:[NSString stringWithFormat:@"%d%d",point.x,point.y]];
//            [sprite addDrop];
//            parent.AIStep ++;
//            CGFloat duration = 3;
//            SKAction *flashAction = [SKAction sequence:@[
//                                                         [SKAction fadeInWithDuration:duration/3.0],
//                                                         [SKAction waitForDuration:duration],
//                                                         [SKAction fadeOutWithDuration:duration/7.0]
//                                                         ]];
//            [parent.locationLabel runAction:flashAction completion:^{
//                [parent.locationLabel removeFromParent];
//                [sprite addDrop];
//            }];
//
//        }
    }],
                                  [SKAction runBlock:^{
        [self removeFromParent];}],
                                  ]];
    [self runAction:action];
    action = [SKAction animateWithTextures:DROP_ANIM_DROP timePerFrame:0.033];
    SKAction *actions = [SKAction repeatActionForever:action];
    [self runAction:actions];
}
@end
