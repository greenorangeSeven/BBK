//
//  SuitResutCell.m
//  BBK
//
//  Created by Seven on 14-12-14.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "SuitResutCell.h"

@implementation SuitResutCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)bindResultContentTvDelegate
{
    self.resultContentTv.delegate = self;
}

- (void)textViewDidChange:(UITextView *)textView
{
    int textLength = [textView.text length];
    if (textLength == 0) {
        [self.resultContentPlaceholder setHidden:NO];
    }else{
        [self.resultContentPlaceholder setHidden:YES];
    }
}

@end
