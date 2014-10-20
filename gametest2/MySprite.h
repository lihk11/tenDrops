//
//  mySpriteOneDrop.h
//  gametest2
//
//  Created by lihk11 on 14/10/13.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MySprite : SKSpriteNode
@property (nonatomic) NSInteger status;

-(void)mouseEntered:(NSEvent *)theEvent;
-(void)split;
-(void)setupAction;
-(void)addDrop;
+(instancetype)spritewithStatusAndLocation:(NSInteger)status location:(CGPoint)location;
@end
