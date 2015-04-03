//
//  TagTextView.m
//  TagControl
//
//  Created by Nitheesh George on 16/12/14.
//  Copyright (c) 2014 Nitheesh George. All rights reserved.
//

#import "TagTextView.h"
#import "TagviewTableCell.h"

#define CELL_HEIGHT                             (44.0f)

static NSMutableDictionary * g_imageCache = nil;
static NSDate * g_dateInit = nil;

@interface TagTextView()

@property (nonatomic, retain) NSString * searchString;
@property (nonatomic, retain) NSArray * data;
;

- (void) initialize;
- (void) uninitialize;

- (NSInteger) cacheAgeInDays;

- (void) onTextChanged:(NSNotification *)aNotification;
- (void) onKeyboadAppear:(NSNotification *)aNotification;
- (void) onKeyboadHide:(NSNotification *)aNotification;

- (void) updateDataSource;

- (void) createTagListView;
- (void) removeTagListView;

- (void) showTagsList;

- (void) onDismissTagList:(UITapGestureRecognizer *)aGesture;

- (void) setImage:(NSString *)aUrl inView:(UIImageView *)anImageView;
- (NSArray *) getTagsFromString:(NSString *)aString;

@end

@implementation TagTextView
{
    BOOL bIsInitalized;
    
    UIView * tagListView;
    BOOL bIsTagListVisible;
    
    UITableView * tableView;
    CGRect rectKeyboard;
    
    NSRange insertRange;
    CGRect rectCaretPos;
    
    UIWindow * appWindow;
}

#pragma mark Private Methods Implementation

- (void) initialize
{
    if(bIsInitalized)
        return;
    
    bIsInitalized = TRUE;
    rectKeyboard = CGRectMake(0, 667, 375, 258);
    appWindow = [UIApplication sharedApplication].delegate.window;
    
    if(g_imageCache == nil)
    {
        g_imageCache = [[NSMutableDictionary alloc] init];
        g_dateInit = [[NSDate date] retain];
    }
    else
    {
        NSInteger old = [self cacheAgeInDays];
        if(old > 7)
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^
            {
                [g_imageCache removeAllObjects];
                [g_dateInit release];
                
                g_dateInit = [[NSDate date] retain];
            });
        }
    }
    
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(onKeyboadAppear:) name:UIKeyboardWillShowNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(onKeyboadHide:) name:UIKeyboardWillHideNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(onTextChanged:) name:UITextViewTextDidChangeNotification object:self];
}

-(void) uninitialize
{
    NSNotificationCenter * notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:UITextViewTextDidChangeNotification object:self];
    [notificationCenter removeObserver:self name:UIKeyboardWillShowNotification object:self];
    [notificationCenter removeObserver:self name:UIKeyboardWillHideNotification object:self];
}

- (NSInteger) cacheAgeInDays
{
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian] autorelease];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:g_dateInit toDate:[NSDate date] options:0];
    return [components day];
}

- (void) onTextChanged:(NSNotification *)aNotification
{
    if(aNotification.object != self || _dataSourceDelegate == nil)
        return;
    
    NSString * strText = self.text;
    
    if(strText.length == 0)
    {
        [self removeTagListView];
        return;
    }
    else if(strText.length > 1)
    {
        unichar last = [strText characterAtIndex:[strText length] - 1];
        if ([[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:last])
        {
            [self removeTagListView];
            return;
        }
    }
    
    NSRange curPos = self.selectedRange;
    NSRange tagRange = [strText rangeOfString:@"@" options:NSBackwardsSearch range:NSMakeRange(0, curPos.location)];
    
    if(tagRange.length == 0)
    {
        [self removeTagListView];
        return;
    }
    
    NSRange tagValueRange = NSMakeRange(tagRange.location, curPos.location - tagRange.location);
    NSRange spaceRange = [strText rangeOfString:@" " options:NSCaseInsensitiveSearch range:tagValueRange];
    
    if(spaceRange.length)
    {
        [self removeTagListView];
        return;
    }
    
    tagValueRange.location = tagValueRange.location + 1;
    tagValueRange.length = tagValueRange.length - 1;
    
    insertRange = tagValueRange;
    
    NSString * strNewSearchString = [strText substringWithRange:tagValueRange];
    self.searchString = strNewSearchString;

    if(_searchString.length == 0)
    {
        [self removeTagListView];
        return;
    }
    
    [self updateDataSource];
    [self showTagsList];
}

- (void) onKeyboadAppear:(NSNotification *)aNotification
{
    rectKeyboard = [[aNotification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

- (void) onKeyboadHide:(NSNotification *)aNotification
{
    CGRect rectTableView = tableView.frame;
    CGSize sizeTagListView = tagListView.bounds.size;
    
    rectTableView.size.height = sizeTagListView.height - rectTableView.origin.y;
    tableView.frame = rectTableView;
}

- (void) updateDataSource
{
    if(_dataSourceDelegate && [_dataSourceDelegate respondsToSelector:@selector(tagsForFilter:)])
    {
        self.data = [_dataSourceDelegate tagsForFilter:_searchString];
        [tableView reloadData];
    }
}

- (void) createTagListView
{
    if(tagListView)
        return;
    
    tagListView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    tagListView.backgroundColor = [UIColor clearColor];
    
    tableView = [[UITableView alloc] initWithFrame:tagListView.bounds];
    
    tableView.allowsSelection = true;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(layoutMargins)])
    {
        tableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    [tagListView addSubview:tableView];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDismissTagList:)];
    
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.cancelsTouchesInView = false;
    
    [tagListView addGestureRecognizer:tapGesture];
    [tapGesture release];
}

- (void) removeTagListView
{
    if(!bIsTagListVisible)
        return;
    
    bIsTagListVisible = FALSE;
    
    if(tagListView == nil)
        return;
    
    [tagListView removeFromSuperview];
}

- (void) showTagsList
{
    bIsTagListVisible = TRUE;
    
    if(tagListView == nil)
        [self createTagListView];
    
    if([[appWindow subviews] containsObject:tagListView] == FALSE)
        [appWindow addSubview:tagListView];
    
    CGRect rectTableView = tableView.frame;
    CGRect rectCur = [super caretRectForPosition:self.selectedTextRange.start];
    CGRect rectPos = [tagListView convertRect:rectCur fromView:self];
    
    rectTableView.origin.y = rectPos.origin.y + rectCaretPos.size.height + 5;
    rectTableView.size.height = (rectKeyboard.origin.y - (rectPos.origin.y + rectPos.size.height + 1));
    
    tableView.frame = rectTableView;
    [appWindow bringSubviewToFront:tagListView];
}

- (void) onDismissTagList:(UITapGestureRecognizer *)aGesture
{
    CGPoint ptTapLcation = [aGesture locationInView:tagListView];
    
    if(CGRectContainsPoint(tableView.frame, ptTapLcation))
        return;
    
    [self removeTagListView];
}

- (void) setImage:(NSString *)aUrl inView:(UIImageView *)anImageView
{
    if(aUrl.length == 0)
        return;
    
    UIImage * cachedImage = [g_imageCache valueForKey:aUrl];
    if(cachedImage)
    {
        anImageView.image = cachedImage;
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^
    {
        NSData * data = [[NSData alloc] initWithContentsOfURL:[NSURL  URLWithString:aUrl]];
        if(data == nil)
            return;

        UIImage * image = [[UIImage alloc] initWithData:data];
        [data release];
        
        if(image == nil)
            return;
        
        [g_imageCache setValue:image forKey:aUrl];
        
        dispatch_async(dispatch_get_main_queue(), ^
        {
            anImageView.image = image;
            [image release];
        });
    });
}

- (NSArray *) getTagsFromString:(NSString *)aString
{
    if(aString.length == 0)
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regx matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
    
    NSMutableArray * userTags = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange wordRange = [match rangeAtIndex:0];
        NSString* word = [aString substringWithRange:wordRange];
        NSLog(@"Found tag %@", word);
        
        [userTags addObject:word];
    }
    
    return [userTags autorelease];
}

#pragma mark Public Methods Implementation

- (id) init
{
    self = [super init];
    
    if(self)
    {
        [self initialize];
    }
    
    return self;
    
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        [self initialize];
    }
    
    return self;
}

- (void) dealloc
{
    [self uninitialize];
    
    [tagListView release];
    [_searchString release];
    [_defaultIProfileImage release];
    
    [super dealloc];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    [self initialize];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void) insertText:(NSString *)text
{
    [super insertText:text];
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    rectCaretPos = [super caretRectForPosition:position];
    return rectCaretPos;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagviewTableCell * cell = (TagviewTableCell *)[tableView1 dequeueReusableCellWithIdentifier:IDENTIFIER_TAGS_CELL];
    
    if(cell == nil)
    {
        cell =  (TagviewTableCell *)[[[NSBundle mainBundle] loadNibNamed:@"TagviewTableCell" owner:self options:nil] objectAtIndex:0];
        //cell = [[[TagviewTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDENTIFIER_TAGS_CELL] autorelease];
        
        if ([cell respondsToSelector:@selector(layoutMargins)])
            cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    cell.titleLabel.text = [_data[indexPath.row] valueForKey:KEY_TAGDATA_TITLE];
    NSString * strImageUrl = [_data[indexPath.row] valueForKey:KEY_TAGDATA_ICON];
    
    if(strImageUrl == nil && _defaultIProfileImage)
        cell.imageView.image = _defaultIProfileImage;
    else
    {
        if([strImageUrl hasPrefix:@"http"] == FALSE)
            cell.imageView.image = [UIImage imageNamed:strImageUrl];
        else if(strImageUrl)
            [self setImage:strImageUrl inView:cell.imageView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * strTag = [NSString stringWithFormat:@"%@ ", [_data[indexPath.row] valueForKey:KEY_TAGDATA_TAG]];
    NSString * strText = self.text;
    
    strText = [strText stringByReplacingCharactersInRange:insertRange withString:strTag];
    
    if(strText.length == 0)
        return;
    
    self.text = strText;
    self.selectedRange = NSMakeRange(insertRange.location + strTag.length, 0);
    
    [self removeTagListView];
}

- (NSArray *) getUserTags
{
    return [self getTagsFromString:self.text];
}

- (NSArray *) getHashTags
{
    NSError *error = nil;
    NSString * string = self.text;
    
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:@"\\b[@#\\w]+\\b" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regx matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    
    NSMutableArray * userTags = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange wordRange = [match rangeAtIndex:0];
        NSString* word = [string substringWithRange:wordRange];
        [userTags addObject:word];
    }
    
    return [userTags autorelease];
}

+ (NSArray *) getUserTagsMetadataFromString:(NSString *)aString
{
    if(aString.length == 0)
        return nil;
    
    NSError *error = nil;
    NSRegularExpression *regx = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regx matchesInString:aString options:0 range:NSMakeRange(0, aString.length)];
    
    NSMutableArray * userTagsMetaData = [[NSMutableArray alloc] init];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange wordRange = [match rangeAtIndex:0];
        NSString* word = [aString substringWithRange:wordRange];
        
        NSDictionary * dic = @{@"userTag": word, @"position" : [NSValue valueWithRange:wordRange]};
        [userTagsMetaData addObject:dic];
    }
    
    return [userTagsMetaData autorelease];
}

@end