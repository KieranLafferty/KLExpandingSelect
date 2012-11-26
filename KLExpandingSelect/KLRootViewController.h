//
//  KLRootViewController.h
//  KLExpandingSelect
//
//  Created by Kieran Lafferty on 2012-11-24.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KLExpandingSelect.h"
#import <MessageUI/MessageUI.h>

@interface KLRootViewController : UIViewController <KLExpandingSelectDataSource, KLExpandingSelectDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) KLExpandingSelect* expandingSelect;
@property (nonatomic, strong) NSArray* selectorData;
@end
