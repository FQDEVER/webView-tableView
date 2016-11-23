//
//  FQcollectionLayout.m

//
//  Created by 范奇 on 16/6/14.
//  Copyright © 2016年 范奇. All rights reserved.
//

#import "FQcollectionLayout.h"

@implementation FQcollectionLayout


-(void)prepareLayout{

    [super prepareLayout];
    if (CGSizeEqualToSize(self.collectionView.bounds.size, CGSizeZero))return;
    self.itemSize = self.collectionView.bounds.size;
    self.minimumLineSpacing = 0;
    self.minimumInteritemSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator= NO;

}

@end
