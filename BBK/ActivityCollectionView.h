//
//  ActivityCollectionView.h
//  NewWorld
//
//  Created by Seven on 14-7-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ActivityCollectionView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *activities;
}

@property (strong, nonatomic) IBOutlet UICollectionView *activityCollection;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
