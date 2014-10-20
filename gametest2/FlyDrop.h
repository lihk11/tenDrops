//
//  drop.h
//  gametest2
//
//  Created by lihk11 on 14/10/13.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "MySprite.h"

@interface FlyDrop : SKSpriteNode
@property (nonatomic) NSInteger direction;//1上2下3左4右
@property (nonatomic) MySprite *splitedFromWaterDrop;
@property (nonatomic) MySprite *collidedWaterDrop;
-(void)setupAction;
+(instancetype)spritewithDirectionAndLocation:(NSInteger)direction location:(CGPoint)location;
@end
