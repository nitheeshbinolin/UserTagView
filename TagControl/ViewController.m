//
//  ViewController.m
//  TagControl
//
//  Created by Nitheesh George on 16/12/14.
//  Copyright (c) 2014 Nitheesh George. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, retain) NSArray * tags;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tagView.dataSourceDelegate = self;
    self.tags = @[ @{KEY_TAGDATA_TITLE : @"Sanal K", KEY_TAGDATA_TAG : @"sanal"},
                   @{KEY_TAGDATA_TITLE :  @"Nitheesh George", KEY_TAGDATA_TAG : @"nitheesh"},
                   @{KEY_TAGDATA_TITLE : @"Harish K", KEY_TAGDATA_TAG : @"harish"},
                   @{KEY_TAGDATA_TITLE : @"Sreeram K", KEY_TAGDATA_TAG : @"sreeram"},
                   @{KEY_TAGDATA_TITLE : @"Shanu K", KEY_TAGDATA_TAG :  @"shanu"}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *) tagsForFilter:(NSString *)aFilter
{
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"(title beginswith[cd] %@) OR (tag beginswith[cd] %@)", aFilter, aFilter];
    
 NSDictionary * dic =  @{@"sanal": @{KEY_TAGDATA_TITLE : @"Sanal K", KEY_TAGDATA_TAG : @"sanal"},
      @"Nitheesh" : @{KEY_TAGDATA_TITLE :  @"Nitheesh George", KEY_TAGDATA_TAG : @"nitheesh"},
      @"Hasih": @{KEY_TAGDATA_TITLE : @"Harish K", KEY_TAGDATA_TAG : @"harish"},
      @"Sreeram": @{KEY_TAGDATA_TITLE : @"Sreeram K", KEY_TAGDATA_TAG : @"sreeram"},
      @"Shanu": @{KEY_TAGDATA_TITLE : @"Shanu K", KEY_TAGDATA_TAG :  @"shanu"}};
    
 NSArray * arrays =  [[dic allValues] filteredArrayUsingPredicate:bPredicate];
    
    NSArray *array = [self.tags filteredArrayUsingPredicate:bPredicate];
    return array;
}

@end
