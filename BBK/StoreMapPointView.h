//
//  StoreMapPointView.h
//  NewWorld
//
//  Created by Seven on 14-7-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface StoreMapPointView : UIViewController<BMKMapViewDelegate>
{
    IBOutlet BMKMapView* _mapView;
}

@property CLLocationCoordinate2D storeCoor;
@property (strong, nonatomic) NSString *storeTitle;

@end
