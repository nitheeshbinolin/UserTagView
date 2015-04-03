//
//  TagviewTableCell.m
//  TagControl
//
//  Created by Nitheesh George on 03/04/15.
//  Copyright (c) 2015 Nitheesh George. All rights reserved.
//

#import "TagviewTableCell.h"
#define PROFILE_IMAGE_HEIGHT                             (40.0f)

@implementation TagviewTableCell

@synthesize imageView = _imageView;
@synthesize titleLabel = _titleLabel;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=  [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _profileImageHeight = PROFILE_IMAGE_HEIGHT;
    }
    
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    _profileImageHeight = PROFILE_IMAGE_HEIGHT;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, _profileImageHeight, _profileImageHeight);
    
    CALayer * layer = self.imageView.layer;
    layer.cornerRadius = _profileImageHeight / 2.0f;
    layer.borderWidth = 2.0f;
    layer.borderColor = [UIColor whiteColor].CGColor;
    layer.masksToBounds = TRUE;
}

- (void) dealloc
{
    [_imageView release];
    [_titleLabel release];
    
    [super dealloc];
}

@end
