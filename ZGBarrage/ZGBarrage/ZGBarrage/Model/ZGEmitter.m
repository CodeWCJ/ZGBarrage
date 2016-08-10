//
//  ZGEmitter.m
//  ZGBarrage
//
//  Created by Zong on 16/8/9.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import "ZGEmitter.h"
#import "ZGBarrageItemModel.h"
#import "ZGBarrageCell.h"
#import "ZGMagazine.h"
#import "ZGBarrageViewDataSourceImplement.h"

@interface ZGEmitter ()

@property (nonatomic, strong) ZGMagazine *magazine;

@property (nonatomic, strong) NSMutableDictionary *flagDic;


@property (nonatomic, assign) NSInteger maxRows;


@end

@implementation ZGEmitter

- (void)prepare
{
    // 发射前，要知道最大行数
    self.maxRows = [self.dataSource getMaxRows];
    
    // 初始化每行是否可以发射的标志
    self.flagDic = [NSMutableDictionary dictionary];
    for (int i=0; i<self.maxRows; i++) {
        [self.flagDic setObject:@(YES) forKey:[NSString stringWithFormat:@"%zd",i]];
    }

}


- (void)start
{
    // 判断是不是第一次发射
    if (!self.magazine) {
        
        self.magazine = [self.dataSource getMagazineWithIndex:0];
        
        if (self.magazine == nil) { // 排除异常--获取新的magazine是Nil
            return;
        }

        // 开始发射
        [self emitStart];
    }
    
}

- (void)emitStart
{
    NSInteger Count = self.maxRows < self.magazine.dataArray.count ? self.maxRows : self.magazine.dataArray.count;
    for (int i=0; i<Count; i++) {
        NSInteger item = 0;
        NSInteger section = i;
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
        ZGBarrageItemModel *itemModel = self.magazine.dataArray[section];
        itemModel.indexPath = indexPath;
//        NSLog(@"item %zd - section %zd",itemModel.indexPath.item,itemModel.indexPath.section);
        // 其实可以不用赋值的，因为永远都是第一个magazine
        itemModel.magazineIndexInContainer = self.magazine.indexInContainer;
        ZGBarrageCell *cell = [self.dataSource emitter:self cellForItemAtIndexPath:indexPath itemModel:itemModel];
        // 判断该section是否可以发射
        if ([[self.flagDic valueForKey:[NSString stringWithFormat:@"%zd",section]] boolValue] == YES) {
            [cell startAnimation];
            [self.flagDic setValue:@(NO) forKey:[NSString stringWithFormat:@"%zd",section]];
        }
    }
}

- (void)emitWithBarrageCell:(ZGBarrageCell *)cell
{
    
//    NSInteger section = 0;
//    NSInteger item = 0;
//    for (int i=0; i<self.magazine.count; i++) {
//        item = i / self.maxRows;
//        section = i % self.maxRows;
//    }
    
    // 判断，同行（section）的下一个，有没有超出magazine
    NSInteger item = cell.itemModel.indexPath.item;
    NSInteger section = cell.itemModel.indexPath.section;
    if ( ( (item + 1) * self.maxRows + section) < self.magazine.dataArray.count ) {
        // 没有超出magazine
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:(item+1) inSection:section];
        ZGBarrageItemModel *itemModel = self.magazine.dataArray[( (item + 1) * self.maxRows + section)];
        itemModel.indexPath = indexPath;
//         NSLog(@"item %zd - section %zd",itemModel.indexPath.item,itemModel.indexPath.section);
        // 其实可以不用赋值的，因为永远都是第一个magazine
        itemModel.magazineIndexInContainer = self.magazine.indexInContainer;
        ZGBarrageCell *cell = [self.dataSource emitter:self cellForItemAtIndexPath:indexPath itemModel:itemModel];
        [cell startAnimation];
        [self.flagDic setValue:@(NO) forKey:[NSString stringWithFormat:@"%zd",section]];
    }else {
        // 判断是否magazine全部发射完成
        if (self.magazine.firstStageOfLeaveCount <=0 )
        {
            // 通知dataSource，本次magazine已经发射完成，要更换magazine了
            [self.barrageViewDataSource emitCompleteWithMagazine:self.magazine];
            
            // emitter 立马要获取一个新的magazine来发射
            self.magazine = [self.dataSource getMagazineWithIndex:(self.magazine.indexInContainer + 1)];
            
            if (self.magazine == nil) { // 获取新的magazine是Nil说明magazinesArray全部发射完
                return;
            }
            // 对新的magazine，重新一轮发射
            [self emitStart];
        }
    }
}

#pragma mark - ZGBarrageCellAnimateDelegate2
- (void)animation2DidStopWithCell:(ZGBarrageCell *)cell
{
    [self.flagDic setValue:@(YES) forKey:[NSString stringWithFormat:@"%zd",cell.itemModel.indexPath.section]];
    
    // 此时，第一阶段发射完一个cell了
    // 发射一个，magezine.firstStageOfLeaveCount 要减一
    self.magazine.firstStageOfLeaveCount--;
    
    [self emitWithBarrageCell:cell];
}

@end
