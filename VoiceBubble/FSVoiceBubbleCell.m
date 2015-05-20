//
//  FSVoiceBubbleCell.m
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/14/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import "FSVoiceBubbleCell.h"

@implementation FSVoiceBubbleCell

- (void)layoutSubviews
{
    [super layoutSubviews];
    CAShapeLayer *circleMask = [CAShapeLayer layer];
    circleMask.path = [UIBezierPath bezierPathWithOvalInRect:_portraitImageView.bounds].CGPath;
    _portraitImageView.layer.mask = circleMask;
}
@end
