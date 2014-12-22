//
//  StoreMapPointView.m
//  NewWorld
//
//  Created by Seven on 14-7-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "StoreMapPointView.h"

@interface StoreMapPointView ()

@end

@implementation StoreMapPointView

- (void)viewDidLoad
{
    [super viewDidLoad];
    //适配iOS7  scrollView计算uinavigationbar高度的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = self.storeTitle;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [Tool getColorForMain];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    _mapView.zoomLevel = 18;
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = self.storeCoor;
    item.title = self.storeTitle;
    [_mapView addAnnotation:item];
    _mapView.centerCoordinate = self.storeCoor;

}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    self.navigationController.navigationBar.hidden = NO;
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end
