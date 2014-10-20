//
//  mySpriteOneDrop.m
//  gametest2
//
//  Created by lihk11 on 14/10/13.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import "MySprite.h"
#import "oneDrop.h"
#import "twoDrops.h"
#import "threeDrops.h"
#import "fourDrops.h"
#import "oneToTwo.h"
#import "fourSplit.h"
#import "FlyDrop.h"
#import "GameScene.h"
@implementation MySprite

static const uint32_t waterDropCategory     =  0x1 << 0;
static const uint32_t flyDropCategory        =  0x1 << 1;

+(instancetype)spritewithStatusAndLocation:(NSInteger)status location:(CGPoint)location{
    NSString *name;
    switch (status) {
        case 1:
            name = @"1.png";
            break;
        case 2:
            name = @"2.png";
            break;
        case 3:
            name = @"3.png";
            break;
        case 4:
            name = @"4.png";
            break;
        default:
            break;
    }
    MySprite *mySprite  = [MySprite spriteNodeWithImageNamed:name];
    mySprite.status = status;
    mySprite.position = location;
    mySprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(60, 60)];// 1
    //mySprite.physicsBody.dynamic = YES; // 2
    mySprite.physicsBody.categoryBitMask = waterDropCategory; // 3
    //mySprite.physicsBody.contactTestBitMask = flyDropCategory; // 4
    mySprite.physicsBody.collisionBitMask = 0; // 5
    [mySprite setupAction];
    return mySprite;
}

-(id)init{
    self = [super init];
    self.status = 4;
    return self;
}

-(void)setStatus:(NSInteger )status{
    NSInteger statusOld = _status;
    _status = status;
}

-(void)mouseEntered:(NSEvent *)theEvent {
    //NSLog(@"%d",self.hasActions);
    NSArray *animationArray ;//= [NSArray arrayWithObject:nil];
    CGFloat timePerFrame = 0.033;
    switch (self.status) {
        case 1:
            animationArray = ONEDROP_ANIM_ONEDROP;
            break;
        case 2:
            animationArray = TWODROPS_ANIM_TWODROPS;
            break;
        case 3:
            animationArray = THREEDROPS_ANIM_THREEDROPS;
            break;
        case 4:
            animationArray = FOURDROPS_ANIM_FOURDROPS;
            break;
        case 5:
            animationArray = FOURSPLIT_ANIM_FOURSPLIT;
            // timePerFrame = 0.1;
            break;
        default:
            break;
    }
    SKAction *action = [SKAction animateWithTextures:animationArray timePerFrame:timePerFrame];
    [self runAction:action];
}
-(void)setupAction {
    NSArray *animationArray ;//= [NSArray arrayWithObject:nil];
    CGFloat timePerFrame = 0.033;
    switch (self.status) {
        case 1:
            animationArray = ONEDROP_ANIM_ONEDROP;
            break;
        case 2:
            animationArray = TWODROPS_ANIM_TWODROPS;
            break;
        case 3:
            animationArray = THREEDROPS_ANIM_THREEDROPS;
            break;
        case 4:
            animationArray = FOURDROPS_ANIM_FOURDROPS;
            break;
        case 5:
            animationArray = FOURSPLIT_ANIM_FOURSPLIT;
           // timePerFrame = 0.1;
            break;
        default:
            break;
    }
    SKAction *action = [SKAction animateWithTextures:animationArray timePerFrame:timePerFrame];
    
    
    if (self.status == 5) {
        action = [SKAction sequence:@[action,
                                      [SKAction runBlock:
                                       ^{
                                           [self split];
                                       }],
                                      [SKAction runBlock:
                                       ^{
                                           GameScene *parent = (GameScene *)self.parent;
                                           parent.mySpriteNum = parent.mySpriteNum - 1;
                                           parent.ComboNum = parent.ComboNum + 1;
                                           [self removeFromParent];
                                       }]
                                      ]
                  ];
    }
    [self runAction:action];
}
-(void)split{
    FlyDrop *dropUp = [FlyDrop spritewithDirectionAndLocation:DIRECTION_UP location:self.position];
    //NSLog([NSString stringWithFormat:@"positionUP:%f,%f",self.position.x,self.position.y]);
    dropUp.scale = 0.8;
    dropUp.splitedFromWaterDrop = self;
    FlyDrop *dropDown = [FlyDrop spritewithDirectionAndLocation:DIRECTION_DOWN location:self.position];
     //NSLog([NSString stringWithFormat:@"positionDown:%f,%f",self.position.x,self.position.y]);
    dropDown.scale = 0.8;
    dropDown.splitedFromWaterDrop = self;
    FlyDrop *dropLeft = [FlyDrop spritewithDirectionAndLocation:DIRECTION_LEFT location:self.position];
     //NSLog([NSString stringWithFormat:@"positionLeft:%f,%f",self.position.x,self.position.y]);
    dropLeft.scale = 0.8;
    dropLeft.splitedFromWaterDrop = self;
    FlyDrop *dropRight = [FlyDrop spritewithDirectionAndLocation:DIRECTION_RIGHT location:self.position];
     //NSLog([NSString stringWithFormat:@"positionRight:%f,%f",self.position.x,self.position.y]);
    dropRight.scale = 0.8;
    dropRight.splitedFromWaterDrop = self;
    GameScene *parent = (GameScene*)self.parent;
    [self.parent addChild:dropUp];
    parent.flyDropsNum = parent.flyDropsNum + 1;
    [self.parent addChild:dropDown];
    parent.flyDropsNum = parent.flyDropsNum + 1;
    [self.parent addChild:dropLeft];
    parent.flyDropsNum = parent.flyDropsNum + 1;
    [self.parent addChild:dropRight];
    parent.flyDropsNum = parent.flyDropsNum + 1;

}
-(void)mouseDown:(NSEvent *)theEvent{
    [self addDrop];
    GameScene *parent = self.parent;
    parent.remainingDrops = parent.remainingDrops - 1;
    parent.ComboNum = 0;
}
-(void)addDrop{
    if (self.status == 4) {
        self.status = 5;
//        SKAction *action = [SKAction animateWithTextures:FOURSPLIT_ANIM_FOURSPLIT timePerFrame:0.033];
//        [self runAction:action];
    } else if(self.status < 4){
        self.status = self.status + 1;
    }
    [self setupAction];
}
@end
