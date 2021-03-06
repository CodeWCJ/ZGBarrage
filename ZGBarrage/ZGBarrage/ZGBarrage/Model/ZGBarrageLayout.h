//
//  ZGBarrageLayout.h
//  ZGBarrage
//
//  Created by Zong on 16/8/8.
//  Copyright © 2016年 Zong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZGBarrageItemModel;

@class ZGBarrageView;


/**
 * 该类(抽象类)一般不直接使用，一般都继承它
 */
@interface ZGBarrageLayout : NSObject

@property (nonatomic, weak) ZGBarrageView *barrageView;
@property (nonatomic) NSInteger maxRows;

- (void)prepareLayout;
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath;
- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath itemModel:(nullable ZGBarrageItemModel *)itemModel;

@end
