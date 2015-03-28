//
//  TagTextView.h
//  TagControl
//
//  Created by Nitheesh George on 16/12/14.
//  Copyright (c) 2014 Nitheesh George. All rights reserved.
//

#import <UIKit/UIKit.h>

#define KEY_TAGDATA_TITLE       (@"title")
#define KEY_TAGDATA_ICON       (@"image")
#define KEY_TAGDATA_TAG         (@"tag")

/*typedef enum _TagListDisplayMode
{
    TagListDisplayModeTop =  0,
    TagListDisplayModeBottom = 1,
} TagListDisplayMode;*/

@protocol TagTextViewDataSourceDelegate <NSObject>

- (NSArray *) tagsForFilter:(NSString *)aFilter;

@end

@interface TagTextView : UITextView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) id<TagTextViewDataSourceDelegate> dataSourceDelegate;

- (NSArray *) getUserTags;
- (NSArray *) getHashTags;

+ (NSArray *) getUserTagsMetadataFromString:(NSString *)aString;

@end
