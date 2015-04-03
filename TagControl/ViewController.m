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
    self.tagView.defaultIProfileImage = [UIImage imageNamed:@"default.jpg"];
    
    self.tags = @[ @{KEY_TAGDATA_TITLE : @"John Smith", KEY_TAGDATA_TAG : @"johnsmith", KEY_TAGDATA_ICON:@"John Smith.jpg"},
                   @{KEY_TAGDATA_TITLE :  @"Steve Jobs", KEY_TAGDATA_TAG : @"stevejobs", KEY_TAGDATA_ICON:@"Steve Jobs.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Harry Potter", KEY_TAGDATA_TAG : @"potter", KEY_TAGDATA_ICON:@"Harry Potter.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Bill Gates", KEY_TAGDATA_TAG : @"billgates", KEY_TAGDATA_ICON:@"Bill Gates.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Mark Zuckerberg", KEY_TAGDATA_TAG :  @"zuckerberg", KEY_TAGDATA_ICON:@"Mark Zuckerberg.jpg"},
                   @{KEY_TAGDATA_TITLE :  @"Steve wozniak", KEY_TAGDATA_TAG : @"wozniak", KEY_TAGDATA_ICON:@"Steve wozniak.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Tim Cook", KEY_TAGDATA_TAG : @"cook", KEY_TAGDATA_ICON:@"Steve wozniak.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Daniel Martin", KEY_TAGDATA_TAG : @"dmartin", KEY_TAGDATA_ICON:@"Daniel Martin.jpg"},
                   @{KEY_TAGDATA_TITLE : @"David Crook", KEY_TAGDATA_TAG :  @"crook"},
                   @{KEY_TAGDATA_TITLE :  @"Samuel Nitheesh", KEY_TAGDATA_TAG : @"samuel", KEY_TAGDATA_ICON:@"Samuel Nitheesh.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Suzanne Nitheesh", KEY_TAGDATA_TAG : @"suzanne", KEY_TAGDATA_ICON:@"Suzanne Nitheesh.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Stephan Hawking", KEY_TAGDATA_TAG : @"hawking", KEY_TAGDATA_ICON:@"Stephan Hawking.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Sara Tom", KEY_TAGDATA_TAG :  @"saratom", KEY_TAGDATA_ICON:@"Sara Tom.jpg"},
                   @{KEY_TAGDATA_TITLE :  @"Sonal Nigam", KEY_TAGDATA_TAG : @"sonal", KEY_TAGDATA_ICON:@"Sonal Nigam.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Stephan Dias", KEY_TAGDATA_TAG : @"dias", KEY_TAGDATA_ICON:@"Stephan Dias.jpg"},
                   @{KEY_TAGDATA_TITLE : @"Stella Moris", KEY_TAGDATA_TAG : @"setallamoris"},
                   @{KEY_TAGDATA_TITLE : @"Saniya Mirza", KEY_TAGDATA_TAG :  @"saniamirza", KEY_TAGDATA_ICON:@"Saniya Mirza.jpg"},
                   @{KEY_TAGDATA_TITLE :  @"Sunny Deol", KEY_TAGDATA_TAG : @"sunnydeol"},
                   @{KEY_TAGDATA_TITLE : @"Steven Sunny", KEY_TAGDATA_TAG : @"ssunny"},
                   @{KEY_TAGDATA_TITLE : @"Samson Vincent", KEY_TAGDATA_TAG : @"svincent"},
                   @{KEY_TAGDATA_TITLE : @"Sagar Alias Jacky", KEY_TAGDATA_TAG :  @"@jacky"}];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *) tagsForFilter:(NSString *)aFilter
{
    NSPredicate *bPredicate = [NSPredicate predicateWithFormat:@"(title beginswith[cd] %@) OR (tag beginswith[cd] %@)", aFilter, aFilter];
    NSArray *array = [self.tags filteredArrayUsingPredicate:bPredicate];
    return array;
}

@end
