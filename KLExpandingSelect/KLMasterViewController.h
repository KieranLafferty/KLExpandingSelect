//
//  KLMasterViewController.h
//  KLExpandingSelect
//
//  Created by Kieran Lafferty on 2012-11-24.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLDetailViewController;

@interface KLMasterViewController : UITableViewController

@property (strong, nonatomic) KLDetailViewController *detailViewController;

@end
