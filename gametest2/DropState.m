//
//  DropState.m
//  gametest2
//
//  Created by lihk11 on 14/10/19.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import "DropState.h"

@implementation DropState
-(id)initWithX:(float)x y:(float)y direction:(NSInteger)direction{
    self = [super init];
    self.x = x;
    self.y = y;
    self.direction = direction;
    self.isCollised = NO;
    return self;
}
@end
