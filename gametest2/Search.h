//
//  Search.h
//  gametest2
//
//  Created by lihk11 on 14/10/19.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSObject
@property (nonatomic) NSMutableArray *stateSpace;//存储状态空间，元素也是NSArray
@property (nonatomic) NSMutableArray *formerMethod;//存储上一次方法的坐标信息
@property (nonatomic) NSInteger formerRemainDrop;//存储上次最优方法所剩余水滴数
@property (nonatomic) NSMutableArray *currentMethod;//存储本次的坐标信息
@property (nonatomic) NSInteger currentRemainDrop;//存储当前剩余的水滴数
@property (nonatomic) NSMutableArray *flyingDropStateArray;//当Array大小为0时,表示该次刷新已经完成
@property (nonatomic) NSInteger originalDropNum;
@property (nonatomic) NSArray *originalMapArray;
-(id)initWithRemainingDrop:(NSInteger)remainingDrop map:(NSArray*)map;
-(NSMutableArray*)solve;
-(NSArray *)addDropOnPosition:(CGPoint)position onArray:(NSArray*)array;
-(NSMutableArray*)solveWithEstimation;
@end
