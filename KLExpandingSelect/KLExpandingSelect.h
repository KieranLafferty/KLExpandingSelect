//
//  KLExpandingSelect.h
//  KLExpandingSelect
//
//  Created by Kieran Lafferty on 2012-11-24.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.
//

#import <UIKit/UIKit.h>


//KLExpandingPetal is the equivelant of a UITableviewCell for this control. It follows the same configuration as a tableview delegate
@interface KLExpandingPetal : UIButton
@property (nonatomic, strong) UIImageView* backgroundImage;
- (void)rotationWithDuration:(NSTimeInterval)duration
                       angle:(CGFloat)angle
                  completion:(void (^)(BOOL finished))completion;
- (id) initWithImage:(UIImage*) image;
@end




@protocol KLExpandingSelectDelegate <NSObject>
@optional
// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath *)expandingSelector:(id)expandingSelect willSelectItemAtIndexPath:(NSIndexPath *)indexPath;

// Called after the user changes the selection.
- (void)expandingSelector:(id)expandingSelect didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

//Called after the animations have completed
- (void)expandingSelector:(id)expandingSelect didFinishExpandingAtPoint:(CGPoint) point;
- (void)expandingSelector:(id)expandingSelect didFinishCollapsingAtPoint:(CGPoint) point;

- (void)expandingSelector:(id)expandingSelect didFinishExpandingPetal: (KLExpandingPetal*) petal;
- (void)expandingSelector:(id)expandingSelect didFinishCollapsingPetal: (KLExpandingPetal*) petal;
@end

@protocol KLExpandingSelectDataSource <NSObject>
@required
- (NSInteger)expandingSelector:(id) expandingSelect numberOfRowsInSection:(NSInteger)section;
- (KLExpandingPetal *)expandingSelector:(id) expandingSelect itemForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@interface KLExpandingSelect : UIView
@property (nonatomic, strong) NSArray* petals;    //Must be set to with objects of type KLExpandingPetal. Operates as a stack.
@property (nonatomic, strong) id<KLExpandingSelectDataSource> dataSource;
@property (nonatomic, strong) id<KLExpandingSelectDelegate> delegate;
@property (nonatomic, strong) UIView* receivingView;    //View to monitor touch events on to initiate the action
-(void) reloadItems;
-(id) initWithDelegate:(id<KLExpandingSelectDelegate>) delegate dataSource: (id<KLExpandingSelectDataSource>) dataSource;
-(NSIndexPath*) indexPathForItem:(KLExpandingPetal*) item;
-(void) expandItemsAtPoint:(CGPoint) point;
-(void) collapseItems;
@end



//Added to allow the user to to set the 
@interface UIView (KLExpandingSelect)
-(void) setExpandingSelect:(KLExpandingSelect*) expandingSelect;
@end