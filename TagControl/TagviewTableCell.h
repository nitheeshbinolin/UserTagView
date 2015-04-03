//
//  TagviewTableCell.h
//  TagControl
//
//  Created by Nitheesh George on 03/04/15.
//  Copyright (c) 2015 Nitheesh George. All rights reserved.
//

#import <UIKit/UIKit.h>
#define IDENTIFIER_TAGS_CELL            (@"TagTextViewCell")

@interface TagviewTableCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView * imageView;
@property (nonatomic, strong) IBOutlet UILabel * titleLabel;
@property (nonatomic, assign) CGFloat profileImageHeight;

@end
