//
//  CircleOfFriendsPublishView.h
//  BBK
//
//  Created by Seven on 14-12-19.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircleOfFriendsPublishView : UIViewController<UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *topicContentPlaceholder;
@property (weak, nonatomic) IBOutlet UITextView *topicContentTv;
@property (weak, nonatomic) IBOutlet UILabel *topicTypeNameLb;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

- (IBAction)selectTopicTypeAction:(id)sender;

@end
