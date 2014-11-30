//
//  UIImage+resize.h
//  iVoice
//
//  Created by ZhangChuntao on 7/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (UIImageExt)

- (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;
- (UIImage*)imageByScalingToDefaultSize;
- (UIImage*)imageByScalingToDefaultSizeAccordingToHeight:(float)height;

@end
