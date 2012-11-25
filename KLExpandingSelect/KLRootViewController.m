//
//  KLRootViewController.m
//  KLExpandingSelect
//
//  Created by Kieran Lafferty on 2012-11-24.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import "KLRootViewController.h"

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
    NSLog(@"Did Select Index Path Fired!");

}

//Called after the animations have completed
- (void)expandingSelector:(id)expandingSelect didFinishExpandingAtPoint:(CGPoint) point {
    NSLog(@"Finished expanding at point (%f, %f)", point.x, point.y);
}
- (void)expandingSelector:(id)expandingSelect didFinishCollapsingAtPoint:(CGPoint) point {
    NSLog(@"Finished Collapsing at point (%f, %f)", point.x, point.y);
}
@end
