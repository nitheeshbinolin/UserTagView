//
//  ViewController.h
//  TagControl
//
//  Created by Nitheesh George on 16/12/14.
//  Copyright (c) 2014 Nitheesh George. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagTextView.h"

@interface ViewController : UIViewController<TagTextViewDataSourceDelegate>

@property (nonatomic, retain) IBOutlet TagTextView * tagView;


@end

