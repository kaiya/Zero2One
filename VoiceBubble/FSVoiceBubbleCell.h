//
//  FSVoiceBubbleCell.h
//  Zero2One
//
//  Created by K.Yawn Xoan on 5/14/15.
//  Copyright (c) 2015 KevinHsiun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSVoiceBubble.h"

@interface FSVoiceBubbleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet FSVoiceBubble *voiceBubble;
@end
