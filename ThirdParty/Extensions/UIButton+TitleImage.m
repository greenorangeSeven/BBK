//
//  UIButton+TitleImage.m
//  Common
//
//  Created by Ma Jianglin on 9/15/13.
//  Copyright (c) 2013年 totemtec.com. All rights reserved.
//

#import "UIButton+TitleImage.h"

@implementation UIButton(TitleImage)

- (CGSize)titleSize
{
    NSString *title = [self titleForState:UIControlStateNormal];
    UIFont *font = self.titleLabel.font;
    CGSize size;
    
    //iOS 7.0
    if ([[NSString alloc] respondsToSelector:@selector(sizeWithAttributes:)])
    {
        size = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    }
    else
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        size = [title sizeWithFont:self.titleLabel.font];
#pragma clang diagnostic pop
    }
    
    return size;
}

- (CGSize)imageSize
{
    UIImage *image = [self imageForState:UIControlStateNormal];
    return image.size;
}


- (void)titleImageAlignLeftWithSpacing:(float)spacing
{
    CGSize titleSize = [self titleSize];
    CGSize imageSize = [self imageSize];
    CGRect rect = self.frame;
    rect.size.width = titleSize.width + imageSize.width + 20 + spacing;
    self.frame = rect;
//    imageSize = CGSizeMake(ceil(imageSize.width/2.0), ceil(imageSize.height/2.0));
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, titleSize.width + spacing, 0.0, -(titleSize.width + spacing));
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, -imageSize.width, 0.0, imageSize.width);
}

- (void)titleImageAlignCenterWithSpacing:(float)spacing
{
    CGSize titleSize = [self titleSize];
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, titleSize.width + spacing, 0.0, -(titleSize.width + spacing));
    
//    [button setImage: [UIImage imageNamed:@"Image name.png"] forState:UIControlStateNormal];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(70.0, -150.0, 5.0, 5.0)];
//    [button setTitle:@"Your text" forState:UIControlStateNormal];

}

- (void)titleImageAlignRightWithSpacing:(float)spacing
{
    float rightMargin = 13;

    CGSize titleSize = [self titleSize];
    CGSize imageSize = [self imageForState:UIControlStateNormal].size;
    self.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -titleSize.width+rightMargin);
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, spacing+imageSize.width+rightMargin);
    
//    [button setImage: [UIImage imageNamed:@"Image name.png"] forState:UIControlStateNormal];
//    [button setTitleEdgeInsets:UIEdgeInsetsMake(70.0, -150.0, 5.0, 5.0)];
//    [button setTitle:@"Your text" forState:UIControlStateNormal];

}


@end