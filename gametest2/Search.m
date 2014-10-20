//
//  Search.m
//  gametest2
//
//  Created by lihk11 on 14/10/19.
//  Copyright (c) 2014年 lihk11. All rights reserved.
//

#import "Search.h"
#import "DropState.h"
#import "myPoint.h"
#define kMaxDepth 3
@implementation Search
@synthesize stateSpace;
@synthesize formerMethod;
@synthesize formerRemainDrop;
@synthesize currentMethod;
@synthesize currentRemainDrop;
@synthesize flyingDropStateArray;
@synthesize originalDropNum;
@synthesize originalMapArray;
-(id)initWithRemainingDrop:(NSInteger)remainingDrop map:(NSArray*)map{
    self = [super init];
    originalMapArray = map;
    formerRemainDrop = 0;
    originalDropNum = remainingDrop;
    currentRemainDrop = remainingDrop;
    stateSpace = [NSMutableArray arrayWithCapacity:kMaxDepth];
    formerMethod = [NSMutableArray arrayWithCapacity:1];
    currentMethod = [NSMutableArray arrayWithCapacity:1];
    flyingDropStateArray = [NSMutableArray arrayWithCapacity:1];
    return self;
}
-(NSMutableArray*)solve{
    NSMutableArray *currentState = [NSMutableArray arrayWithCapacity:originalMapArray.count];
    int i;
    for ( i = 0; i<originalMapArray.count; i++) {
        NSString *number_string = [originalMapArray objectAtIndex:i];
        NSNumber *number = [NSNumber numberWithInt:[number_string intValue]];
        [currentState addObject:number];
    }
//    currentState = (NSMutableArray*)[self addDropOnPosition:CGPointMake(4, 4) onArray:currentState];
    [self caculateForState:currentState depth:1];
    if (formerMethod.count > 0) {
        return formerMethod;
    } else {
        return nil;
    }
}
-(NSMutableArray*)solveWithEstimation{
    //先计算当前所有加一滴水，选出其中个最好的，（如果没有clear）分别再加一滴水
    //找出当中最好的，作为下次的结果
    NSMutableArray *currentState = [NSMutableArray arrayWithCapacity:originalMapArray.count];
    int i;
    for ( i = 0; i<originalMapArray.count; i++) {
        NSString *number_string = [originalMapArray objectAtIndex:i];
        NSNumber *number = [NSNumber numberWithInt:[number_string intValue]];
        [currentState addObject:number];
    }
    for (i=0; i<20; i++) {
        NSDictionary *resultDictionary = [self solveWithEstimationWithArray:currentState];
        NSNumber *position_x = [resultDictionary objectForKey:@"x"];
        NSNumber *position_y = [resultDictionary objectForKey:@"y"];
        NSNumber *maxValue = [resultDictionary objectForKey:@"maxValue"];
        currentState = [resultDictionary objectForKey:@"map"];
        MyPoint *position = [[MyPoint alloc] initWithX:[position_x intValue] y:[position_y intValue]];
        [currentMethod addObject:position];
        if ([maxValue floatValue] == 0) {
            return currentMethod;
        }
    }
    return currentMethod;
}
-(NSDictionary*)solveWithEstimationWithArray:(NSMutableArray*)currentMap{
    int i = 0,j = 0,k=0;
    NSMutableArray *mapArray = [NSMutableArray arrayWithCapacity:36];
    //NSMutableArray *mapEstimation = [NSMutableArray arrayWithCapacity:5];
    float maxValue = 0;
    float  currentValue = 0;
    float sum = 0;
    float arraySpriteCount = 0;
    int position_x = 1;
    int position_y = 1;
    
  //  [mapEstimation addObject:[NSNumber numberWithInt:5]];
    for(i=1;i<=6;i++)
    {
        for (j=1; j<=6;j++) {
            // arrayCount = mapEstimation.count;
            CGPoint position = CGPointMake(i,j);
            NSMutableArray *arrayAddedDrop =(NSMutableArray*) [self addDropOnPosition:position onArray:currentMap];
            sum = 0;
            arraySpriteCount = 0;
            for (k=0; k<arrayAddedDrop.count; k++) {
                NSNumber *number = [arrayAddedDrop objectAtIndex:k];
                if(number.intValue > 0){
                    arraySpriteCount = arraySpriteCount + 1.0;
                    sum = sum + number.intValue;
                }
            }
            if(sum == 0)
            {
                position_x = i ;
                position_y = j ;
                maxValue = 0;
                NSDictionary *resultDictionary = [NSDictionary dictionaryWithObjectsAndKeys:arrayAddedDrop,@"map",[NSNumber numberWithInt:position_x],@"x",[NSNumber numberWithInt:position_y],@"y",[NSNumber numberWithFloat:maxValue],@"maxValue", nil];
                return resultDictionary;
            }
            currentValue = sum / arraySpriteCount;
            if(currentValue > maxValue)
            {
                position_x = i;
                position_y = j;
                mapArray = arrayAddedDrop;
                maxValue = currentValue;
            }
        }
    }
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithObjectsAndKeys:mapArray,@"map",[NSNumber numberWithInt:position_x],@"x",[NSNumber numberWithInt:position_y],@"y",[NSNumber numberWithFloat:maxValue],@"maxValue", nil];
    return  resultDictionary;
}
-(NSMutableArray *)addDropOnPosition:(CGPoint)position onArray:(NSMutableArray*)array{
    NSMutableArray *mapArray = [NSMutableArray arrayWithArray:array];
    int index = (int)((position.x-1)*6 + (position.y -1));
    NSNumber *spriteDrop = [mapArray objectAtIndex:index];
    spriteDrop = [NSNumber numberWithInt:[spriteDrop intValue]+1];
    if ([spriteDrop intValue] <= 4) {//水滴不分裂，直接返回
        [mapArray replaceObjectAtIndex:index withObject:spriteDrop];
        return mapArray;
    } else {//水滴分裂
        spriteDrop = [NSNumber numberWithInt:0];
        [mapArray replaceObjectAtIndex:index withObject:spriteDrop];
        DropState *dropUp = [[DropState alloc] initWithX:position.x y:position.y+0.5 direction:DIRECTION_UP];
        [flyingDropStateArray addObject:dropUp];
        DropState *dropDown = [[DropState alloc] initWithX:position.x y:position.y-0.5 direction:DIRECTION_DOWN];
        [flyingDropStateArray addObject:dropDown];
        DropState *dropLeft = [[DropState alloc] initWithX:position.x-0.5 y:position.y direction:DIRECTION_LEFT];
        [flyingDropStateArray addObject:dropLeft];
        DropState *dropRight = [[DropState alloc] initWithX:position.x+0.5 y:position.y direction:DIRECTION_RIGHT];
        [flyingDropStateArray addObject:dropRight];
        //模拟飞行的水滴
        while (flyingDropStateArray.count > 0) {
        //NSLog(@"%lu",(unsigned long)flyingDropStateArray.count);
            NSMutableArray *flyingDropStateArray_temp = [NSMutableArray arrayWithCapacity:flyingDropStateArray.count];
            int count = flyingDropStateArray.count;
            int i =0;
            for(i = 0; i<count; i++) {
                DropState *drop_temp= [flyingDropStateArray objectAtIndex:i];
                if(!(drop_temp.x > 6 || drop_temp.x < 1 || drop_temp.y > 6 || drop_temp.y < 1|| drop_temp.isCollised)){
                    [flyingDropStateArray_temp addObject:drop_temp];
                    continue;
                }
            }
            flyingDropStateArray = [NSMutableArray arrayWithArray:flyingDropStateArray_temp];
            count = flyingDropStateArray.count;
            for( i = 0; i<count; i++) {
                DropState *drop = [flyingDropStateArray objectAtIndex:i];
                //检测水滴是否出界,
                if (drop.x > 6 || drop.x < 1 || drop.y > 6 || drop.y < 1 || drop.isCollised) {
                    continue;
                }
                //移动水滴
                BOOL split = NO;
                switch (drop.direction) {
                    case DIRECTION_UP:
                        drop.y = drop.y + 0.5;
                        if(drop.y - (int)drop.y == 0){
                            index = (drop.x - 1)*6 + drop.y - 1;
                            NSNumber *spriteDrop = [mapArray objectAtIndex:index];
                            if(spriteDrop.intValue > 0 && spriteDrop.intValue < 4)
                            {
                                spriteDrop = [NSNumber numberWithInt:[spriteDrop intValue]+1];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];
                                drop.isCollised = YES;
                            } else if(spriteDrop.intValue == 4){
                                spriteDrop = [NSNumber numberWithInt:0];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];//水滴再次分裂
                                split = YES;
                                drop.isCollised = YES;
                            }//等于0的话直接略过
                        }
                        break;
                    case DIRECTION_DOWN:
                        drop.y = drop.y - 0.5;
                        if(drop.y - (int)drop.y == 0){
                            index = (drop.x - 1)*6 + drop.y - 1;
                            NSNumber *spriteDrop = [mapArray objectAtIndex:index];
                            if(spriteDrop.intValue > 0 && spriteDrop.intValue < 4)
                            {
                                spriteDrop = [NSNumber numberWithInt:[spriteDrop intValue]+1];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];
                                drop.isCollised = YES;
                            } else if(spriteDrop.intValue == 4){
                                spriteDrop = [NSNumber numberWithInt:0];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];//水滴再次分裂
                                split = YES;
                                drop.isCollised = YES;
                            }//等于0的话直接略过
                        }
                        break;
                    case DIRECTION_LEFT:
                        drop.x = drop.x - 0.5;
                        if(drop.x - (int)drop.x == 0){
                            index = (drop.x - 1)*6 + drop.y - 1;
                            NSNumber *spriteDrop = [mapArray objectAtIndex:index];
                            if(spriteDrop.intValue > 0 && spriteDrop.intValue < 4)
                            {
                                spriteDrop = [NSNumber numberWithInt:[spriteDrop intValue]+1];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];
                                drop.isCollised = YES;
                            } else if(spriteDrop.intValue == 4){
                                spriteDrop = [NSNumber numberWithInt:0];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];//水滴再次分裂
                                split = YES;
                                drop.isCollised = YES;
                            }//等于0的话直接略过
                        }
                        break;
                    case DIRECTION_RIGHT:
                        drop.x = drop.x + 0.5;
                        if(drop.x - (int)drop.x == 0){
                            index = (drop.x - 1)*6 + drop.y - 1;
                            NSNumber *spriteDrop = [mapArray objectAtIndex:index];
                            if(spriteDrop.intValue > 0 && spriteDrop.intValue < 4)
                            {
                                spriteDrop = [NSNumber numberWithInt:[spriteDrop intValue]+1];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];
                                drop.isCollised = YES;
                            } else if(spriteDrop.intValue == 4){
                                spriteDrop = [NSNumber numberWithInt:0];
                                [mapArray replaceObjectAtIndex:index withObject:spriteDrop];//水滴再次分裂
                                split = YES;
                                drop.isCollised = YES;
                            }//等于0的话直接略过
                        }
                        break;
                    default:
                        break;
                }
                if (split == YES) {//如果分裂的话，则要加入分裂水滴
                    DropState *dropUp = [[DropState alloc] initWithX:drop.x y:drop.y+0.5 direction:DIRECTION_UP];
                    [flyingDropStateArray addObject:dropUp];
                    DropState *dropDown = [[DropState alloc] initWithX:drop.x y:drop.y-0.5 direction:DIRECTION_DOWN];
                    [flyingDropStateArray addObject:dropDown];
                    DropState *dropLeft = [[DropState alloc] initWithX:drop.x-0.5 y:drop.y direction:DIRECTION_LEFT];
                    [flyingDropStateArray addObject:dropLeft];
                    DropState *dropRight = [[DropState alloc] initWithX:drop.x+0.5 y:drop.y direction:DIRECTION_RIGHT];
                    [flyingDropStateArray addObject:dropRight];
                }
            }
        }
    }
    return mapArray;
}
-(void)caculateForState:(NSMutableArray*)currentstate depth:(NSInteger)depth{
    if (originalDropNum - formerRemainDrop <3) {
        return;
    }
    if (depth > kMaxDepth || currentRemainDrop < 0) {
        return;
    }
    int i,j,k;
    BOOL isClear;
    for (i = 1; i <= 6; i++) {
        for (j = 1; j <= 6; j++) {
            CGPoint position = CGPointMake(i, j);
            MyPoint *point = [[MyPoint alloc] initWithX:position.x y:position.y];
            if (position.x == 4 && position.y== 4) {
                point = [[MyPoint alloc] initWithX:4 y:4];

            }
            [currentMethod addObject:point];
            NSTimeInterval st = [NSDate timeIntervalSinceReferenceDate] * 1000;
            NSMutableArray *newState = (NSMutableArray *)[self addDropOnPosition:position onArray:currentstate];
            currentRemainDrop = currentRemainDrop - 1;
            NSLog(@"addDropOnPosition:%f", [NSDate timeIntervalSinceReferenceDate] * 1000 - st);
            isClear = YES;
            for (k = 0; k < 36; k++) {
                NSNumber *number = [newState objectAtIndex:k];
                if ([number intValue] != 0) {
                    isClear = NO;
                    break;
                }
            }
            if (isClear) {
                //在这里比较方法
                if (currentRemainDrop > formerRemainDrop) {
                    formerMethod = [NSMutableArray arrayWithArray:currentMethod];
                    formerRemainDrop = currentRemainDrop;
                    currentRemainDrop = currentRemainDrop + 1;
                    [currentMethod removeLastObject];
                    return;
                } else {
                    currentRemainDrop = currentRemainDrop + 1;
                    [currentMethod removeLastObject];
                    return;
                }
            } else {
                int newdepth = depth + 1;
                [self caculateForState:newState depth:newdepth];
                currentRemainDrop = currentRemainDrop + 1;
                [currentMethod removeLastObject];
            }
        }
    }
}
@end
