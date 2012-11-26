//
//  KLRootViewController.m
//  KLExpandingSelect
//
//  Created by Kieran Lafferty on 2012-11-24.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import "KLRootViewController.h"
#import <Social/Social.h>

#define kIndexTwitter 0
#define kIndexFavorite 1
#define kIndexEmail 2
#define kIndexFaceBook 3

@interface KLRootViewController ()

@end

@implementation KLRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Initialize the table data
    NSString* plistPath = [[NSBundle mainBundle] pathForResource: @"Petal Data"
                                                          ofType: @"plist"];
    // Build the array from the plist
    self.selectorData = [[NSArray alloc] initWithContentsOfFile:plistPath];
	// Configure the Expander Select and add to view controllers view.
    self.expandingSelect = [[KLExpandingSelect alloc] initWithDelegate: self
                                                            dataSource: self];
    [self.view setExpandingSelect:self.expandingSelect];
    [self.view addSubview: self.expandingSelect];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - KLExpandingSelect data source methods

- (NSInteger)expandingSelector:(id) expandingSelect numberOfRowsInSection:(NSInteger)section{
    return [self.selectorData count];
}
- (KLExpandingPetal *)expandingSelector:(id) expandingSelect itemForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* dictForPetal = [self.selectorData objectAtIndex:indexPath.row];
    NSString* imageName = [dictForPetal objectForKey:@"image"];
    KLExpandingPetal* petal = [[KLExpandingPetal alloc] initWithImage:[UIImage imageNamed:imageName]];
    return petal;
}

#pragma mark - KLExpandingSelect Delegate Methods
// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)expandingSelector:(id)expandingSelect willSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Will Select Index Path Fired!");
    return  indexPath;
}


// Called after the user changes the selection.
- (void)expandingSelector:(id)expandingSelect didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIImage* sharedImage = [UIImage imageNamed:@"controlShare.png"];
    
    if (indexPath.row == kIndexEmail) {
        MFMailComposeViewController* mailViewController = [[MFMailComposeViewController alloc] init];
        [mailViewController setMailComposeDelegate: self];
        [mailViewController setSubject:@"Check out KLExpandingSelect on Github"];
        [mailViewController setMessageBody:@"I'm planning on using this UI control in my next iOS app!\nhttps://github.com/KieranLafferty/KLExpandingSelect.git"
                                    isHTML:NO];
        NSData *imageAttachment = UIImageJPEGRepresentation(sharedImage,1);
        [mailViewController addAttachmentData: imageAttachment
                                     mimeType:@"image/png"
                                     fileName:@"screenshot.png"];
        [self presentViewController: mailViewController
                           animated: YES
                         completion: nil];
        return;
    }
    else {
        SLComposeViewController* shareViewController;

        switch (indexPath.row) {
            case kIndexEmail:
                break;
            case kIndexFaceBook:
                shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                break;
            case kIndexTwitter:
                shareViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                break;
            case kIndexFavorite:
                //Handle favorites
                
                return;
            default:
                break;
        }
        [shareViewController addURL:[NSURL URLWithString:@"https://github.com/KieranLafferty/KLExpandingSelect.git"]];
        [shareViewController setInitialText:@"I'm planning on using this UI control in my next iOS app!"];
        [shareViewController addImage: sharedImage];
        
        if ([SLComposeViewController isAvailableForServiceType:shareViewController.serviceType]) {
            [self presentViewController:shareViewController
                               animated:YES
                             completion: nil];
        }
        else {
            UIAlertView* errorAlert = [[UIAlertView alloc] initWithTitle: @"Service Not Supported"
                                                                 message: @"You must go to device settings and configure the service"
                                                                delegate: nil
                                                       cancelButtonTitle: nil
                                                       otherButtonTitles: nil];
            [errorAlert show];
        }
    }
    NSLog(@"Did Select Index Path Fired!");

}

//Called after the animations have completed
- (void)expandingSelector:(id)expandingSelect didFinishExpandingAtPoint:(CGPoint) point {
    NSLog(@"Finished expanding at point (%f, %f)", point.x, point.y);
}
- (void)expandingSelector:(id)expandingSelect didFinishCollapsingAtPoint:(CGPoint) point {
    NSLog(@"Finished Collapsing at point (%f, %f)", point.x, point.y);
}

#pragma mark - MFMailComposerDelegate callback - Not required by KLExpandingSelect
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
