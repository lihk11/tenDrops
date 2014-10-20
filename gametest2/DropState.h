//
//  DropState.h
//  gametest2
//
//  Created by lihk11 on 14/10/19.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DropState : NSObject
@property (nonatomic) float x;
@property (nonatomic) float y;
@property (nonatomic) NSInteger direction;
@property (nonatomic) BOOL isCollised;
-(id)initWithX:(float)x y:(float)y direction:(NSInteger)direction;
@end
