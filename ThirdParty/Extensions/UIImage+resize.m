//
//  UIImage+resize.m
//  iVoice
//
//  Created by ZhangChuntao on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UIImage+resize.h"
#import <CoreGraphics/CoreGraphics.h>

#define DEFAULT_IMAGE_WIDTH         170
#define DEFAULT_IMAGE_HEIGHT        180

@implementation UIImage (UIImageExt)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize
{
    UIImage *sourceImage = self;
    UIImage *newImage = nil;      
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = 0;
    CGFloat scaledHeight = 0;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);

    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    else {
        return self;
    }

    UIGraphicsBeginImageContext(targetSize); // this will crop

    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;

    [sourceImage drawInRect:thumbnailRect];

    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
    {
        newImage = sourceImage;
    }
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)imageByScalingToDefaultSize
{
    return [self imageByScalingToDefaultSizeAccordingToHeight:DEFAULT_IMAGE_HEIGHT];
}

- (UIImage*)imageByScalingToDefaultSizeAccordingToHeight:(float)height
{
    if (height <= 0) {
        height = DEFAULT_IMAGE_HEIGHT;
    }
    CGSize originSize = self.size;
    if (originSize.height > height) {
        originSize = CGSizeMake(height/self.size.height*self.size.width, height);
        originSize.height = height;
    }
    if (originSize.width > DEFAULT_IMAGE_WIDTH) {
        originSize.width = DEFAULT_IMAGE_WIDTH;
    }
    return [self imageByScalingAndCroppingForSize:originSize];
}

@end
