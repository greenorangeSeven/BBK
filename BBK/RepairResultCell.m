//
//  RepairResultCell.m
//  BBK
//
//  Created by Seven on 14-12-12.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RepairResultCell.h"
#import "AMRatingControl.h"

@implementation RepairResultCell

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
