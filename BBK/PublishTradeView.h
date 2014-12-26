//
//  PublishTradeView.h
//  BBK
//
//  Created by Seven on 14-12-21.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PublishTradeView : UIViewController<UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) UIView *parentView;
@property (weak, nonatomic) UIImage *cameraImage;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTf;
@property (weak, nonatomic) IBOutlet UITextField *priceTf;
@property (weak, nonatomic) IBOutlet UITextView *contentTv;
@property (weak, nonatomic) IBOutlet UITextField *phoneTf;
@property (weak, nonatomic) IBOutlet UIImageView *cameraIv;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholder;

- (IBAction)cameraAction:(id)sender;

@end
