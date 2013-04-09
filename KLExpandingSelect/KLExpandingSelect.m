//
//  KLExpandingSelect.m
//  KLExpandingSelect
//
//  Created by Kieran Lafferty on 2012-11-24.
//  Copyright (c) 2012 Kieran Lafferty. All rights reserved.



//Petal settings
#define kPetalHeight 80
#define kPetalWidth 60
#define kPetalShadowColor [UIColor darkGrayColor]
#define kPetalShadowOffset CGSizeMake(0, 3)
#define kPetalShadowOpacity 0.6
#define kPetalShadowRadius 4
#define kPetalAlpha 0.96

//Animation Settings
#define KAnimationFanOutDegrees 360.0   //Amount  for the control to fan out 360 = fully fanned out, 180 = half fanned out
#define kAnimationGrowDuration 0.3
#define kAnimationRotateDuration 0.3
#define kAnimationPetalSpread 1.003     //A tuning parameter for determining how crowded petals are with respect to eachother
#define kAnimationPetalDelay 0.1        //The amount of time between animating each petal

#define kAnimationPetalMinScale 0.001   //Scale of the item at its smallest (i.e 0.01 is 1/100th its original size
#define kAnimationPetalMaxScale 1000      //Scale of the item at its largest (relative to on kAnimationPetalMinScale)

//Customize the layout of the control
#define kDefaultRotation 0.0          //Degrees to rotate the control
#define kDefaultHeight 2*kPetalHeight*kAnimationPetalSpread     //The height of the control upon full expansion
#define kDefaultWidth kDefaultHeight    //The width of the control upon full expansion
#define kDefaultTopMargin kPetalHeight*kAnimationPetalSpread  //Amount of space to reserve the top to ensure that the control doesnt get drawn off screen
#define kDefaultRightMargin kPetalHeight*kAnimationPetalSpread //Amount of space to reserve the right to ensure that the control doesnt get drawn off screen
#define kDefaultBottomMargin kPetalHeight*kAnimationPetalSpread  //Amount of space to reserve the bottom to ensure that the control doesnt get drawn off screen
#define kDefaultLeftMargin kPetalHeight*kAnimationPetalSpread  //Amount of space to reserve the left to ensure that the control doesnt get drawn off screen
#define kDefaultRasterizationScale 5.0

#define kLongPressDuration 1.0          //The length of time before a touch is registered and the control appears on the parent view

/** Degrees to Radian **/
#define degreesToRadians( degrees ) ( ( degrees ) / 180.0 * M_PI )

/** Radians to Degrees **/
#define radiansToDegrees( radians ) ( ( radians ) * ( 180.0 / M_PI ) )

#import "KLExpandingSelect.h"
#import <QuartzCore/QuartzCore.h>

@interface KLExpandingSelect ()
//Growth animation
-(void) performExpandRotateAnimationForPetal:(KLExpandingPetal*) petal;

//Shrink animation
-(void) performShrinkAnimationForPetal:(KLExpandingPetal*) petal withDelay:(CGFloat) delay;

-(void) expandItemAtIndexPath:(NSIndexPath*) indexPath atOrigin:(CGPoint) origin withDelay:(CGFloat) delay;
-(void) collapseItemAtIndexPath:(NSIndexPath*) indexPath withDelay:(CGFloat) delay;
@end

@implementation KLExpandingSelect


-(id) initWithDelegate:(id<KLExpandingSelectDelegate>) delegate dataSource: (id<KLExpandingSelectDataSource>) dataSource {
    if (self = [super initWithFrame:CGRectMake(0, 0, kDefaultWidth, kDefaultHeight)]) {
        [self setTransform:CGAffineTransformMakeRotation(degreesToRadians(kDefaultRotation))];
        //Initialize the data source and delegate variables
        self.dataSource = dataSource;
        self.delegate = delegate;
  
        //Call the reloadData to populate the items array from the data source
        [self reloadItems];
        
      
        [self setHidden:YES];
        
    }
    return self;
}

-(void) reloadItems {
    
    //TODO: Implement sections by replacing 0's with a section variable. Would operate as a recursive tree allowing the user to traverse as deep as desired
    
    NSInteger totalItems = [self.dataSource expandingSelector:self
                                        numberOfRowsInSection:0];
    
    //Create a temporary mutable storage array to hold the items
    NSMutableArray* mutableItems = [[NSMutableArray alloc] initWithCapacity:totalItems];
    
    //Iterate over each item and add it to the items array
    for (NSInteger count = 0; count < totalItems; count++) {
        NSIndexPath* currentIndexPath = [NSIndexPath indexPathForRow:count inSection:0];
        KLExpandingPetal *item = [self.dataSource expandingSelector:self
                                              itemForRowAtIndexPath:currentIndexPath];
        //Assign the selector to the control
        [item addTarget: self
                 action: @selector(didSelectPetal:)
       forControlEvents: UIControlEventTouchUpInside
         ];
        
        [mutableItems addObject: item];
    }
    
    //Copy the items into the local storage array 
    self.petals = (NSArray*) mutableItems;
    
}
-(void) didSelectPetal:(KLExpandingPetal*) petal {
    NSIndexPath* indexPath = [self indexPathForItem:petal];
    
    //Check if the user wants to specify a different index path for selection
    if ([self.delegate respondsToSelector:@selector(expandingSelector:willSelectItemAtIndexPath:)]) {
        indexPath = [self.delegate expandingSelector:self
                           willSelectItemAtIndexPath:indexPath];
    }
    
    [self collapseItems];
    
    //Fire delegate callback informing of selection
    if ([self.delegate respondsToSelector:@selector(expandingSelector:didSelectItemAtIndexPath:)]) {
        [self.delegate expandingSelector:self
                didSelectItemAtIndexPath:indexPath];
    }
        
}

-(void) expandItemsAtPoint:(CGPoint) point {
    CGFloat delay = 0.0;
    for (KLExpandingPetal* petal in self.petals) {
        NSIndexPath* indexPath = [self indexPathForItem:petal];
        
        [self expandItemAtIndexPath: indexPath
                           atOrigin: point
                          withDelay: delay];
        delay += kAnimationPetalDelay;
        [self addSubview:petal];
    }

}
-(void) collapseItems {
    for (KLExpandingPetal* petal in self.petals) {
        NSIndexPath* indexPath = [self indexPathForItem:petal];
        [self collapseItemAtIndexPath: indexPath
                            withDelay: 0];
    }
}

-(void) performExpandRotateAnimationForPetal:(KLExpandingPetal*) petal {
    NSIndexPath* indexPath = [self indexPathForItem:petal];
    //  3. Rotate clockwise to the position allowing for variable numbers of items nad equal spacing between each item
    NSInteger totalItemCount = [self.petals count];
    
    CGFloat rotationFactor = (CGFloat)((totalItemCount - indexPath.row))/((CGFloat)totalItemCount);
    
    CGFloat rotationAngle = 2*M_PI*rotationFactor*(degreesToRadians(KAnimationFanOutDegrees)/degreesToRadians(360.0));
    
    
    //To force the animation to happen in clockwise, we must do two animations back to back since it will go counter clock wise if the value is greater than M_PI
    
    [petal rotationWithDuration: kAnimationRotateDuration
                         angle: rotationAngle
                    completion:^(BOOL finished) {
                        if ([self.delegate respondsToSelector:@selector(expandingSelector:didFinishExpandingPetal:)]) {
                            [self.delegate expandingSelector: self
                                     didFinishExpandingPetal: petal];
                        }
                        
                        if ([self.delegate respondsToSelector:@selector(expandingSelector:didFinishExpandingAtPoint:)] && indexPath.row == totalItemCount - 1) {
                            [self.delegate expandingSelector: self
                                   didFinishExpandingAtPoint: self.center];
                        }
                    }];

}
-(void) performShrinkAnimationForPetal:(KLExpandingPetal*) petal withDelay:(CGFloat) delay {
    NSIndexPath* indexPath = [self indexPathForItem:petal];
    NSInteger totalItemCount = [self.petals count];
    
    [UIView animateWithDuration: kAnimationGrowDuration
                          delay: delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [petal.layer setTransform:CATransform3DScale(petal.layer.transform, kAnimationPetalMinScale, kAnimationPetalMinScale, 1)];
                     } completion:^(BOOL finished) {
                         if ([self.delegate respondsToSelector:@selector(expandingSelector:didFinishCollapsingPetal:)]) {
                             [self.delegate expandingSelector: self
                                     didFinishCollapsingPetal: petal];
                         }
                         if ([self.delegate respondsToSelector:@selector(expandingSelector:didFinishCollapsingAtPoint:)] && indexPath.row == totalItemCount - 1) {
                             [self.delegate expandingSelector:self didFinishCollapsingAtPoint:self.center];
                         }
                         if ([[self indexPathForItem: petal] row] == 0) {
                             [self setHidden:YES];
                         }
                     }];
}

-(NSIndexPath*) indexPathForItem:(KLExpandingPetal*) petal {
    NSInteger rowNumber = [self.petals indexOfObject:petal];
    return [NSIndexPath indexPathForRow:rowNumber inSection:0];
}
-(void) expandItemAtIndexPath:(NSIndexPath*) indexPath atOrigin:(CGPoint) origin withDelay:(CGFloat) delay{
    //First, set the view to be not hidden so that the animation will appear on screen
    [self setCenter: origin];
    [self setHidden: NO];

    KLExpandingPetal* item = [self.petals objectAtIndex: indexPath.row];


    //Get the center point of the control to determine where the animation should originate from
    
    //  1. Grow from size (0,0) and move upwards as specified by the constants above
    [item.layer setTransform:CATransform3DMakeScale(kAnimationPetalMinScale, kAnimationPetalMinScale, 1)];
    [item setCenter:CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0)];
    
    //  2. Set the anchor point to X = width/2 and Y = height + y animated offset from 1.
    CGPoint anchorPoint = CGPointMake(0.5, kAnimationPetalSpread);
    [item.layer setAnchorPoint: anchorPoint];

    [UIView animateWithDuration: kAnimationGrowDuration
                          delay: delay
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [item.layer setTransform:CATransform3DScale(item.layer.transform, kAnimationPetalMaxScale, kAnimationPetalMaxScale, 1)];

                     } completion:^(BOOL finished) {
                         NSInteger totalItemCount = [self.petals count];
                         if ([[self indexPathForItem:item] row] == totalItemCount - 1) {
                             for (KLExpandingPetal* petal in self.petals) {
                                 [self performExpandRotateAnimationForPetal:petal];
                             }
                         }
                     }];
}

-(void) collapseItemAtIndexPath:(NSIndexPath*) indexPath withDelay:(CGFloat) delay {
    //Reverse what was done in expand    
    KLExpandingPetal* item = [self.petals objectAtIndex: indexPath.row];
    
    NSInteger totalItemCount = [self.petals count];
    
    CGFloat rotationFactor = (CGFloat)((totalItemCount - indexPath.row))/((CGFloat)totalItemCount);
    
    CGFloat rotationAngle = 2*M_PI*rotationFactor*(degreesToRadians(KAnimationFanOutDegrees)/degreesToRadians(360.0));
    
    [UIView animateWithDuration: kAnimationRotateDuration
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [item.layer setTransform: CATransform3DRotate(item.layer.transform, 2*M_PI - rotationAngle, 0.0, 0.0, 1.0)];
                     } completion:^(BOOL finished) {
                         if ([[self indexPathForItem:item] row] == totalItemCount -1) {
                             CGFloat delay = 0;
                             delay += kAnimationPetalDelay;

                             for (KLExpandingPetal* petal in [[self.petals reverseObjectEnumerator] allObjects]) {
                                 [self performShrinkAnimationForPetal:petal withDelay:delay];
                                 delay += kAnimationPetalDelay;
                             }
                         }
                     }];
}
-(void) longPressDidFire: (UILongPressGestureRecognizer*) recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded && self.hidden) {
        //Get the coordinates of the press
        CGPoint touchCenter = [recognizer locationInView: self.receivingView];
        
        //Determine where the point should be by factoring in the margins defined above
        CGFloat touchX = touchCenter.x;
        CGFloat touchY = touchCenter.y;
        
        //Handle the left and right margins
        if (touchX < kDefaultLeftMargin) {
            touchX = kDefaultLeftMargin;
        }
        else if (touchX > self.receivingView.frame.size.width - kDefaultRightMargin) {
            touchX = self.receivingView.frame.size.width - kDefaultRightMargin;
        }
        
        //Handle the top and bottom margins
        if (touchY < kDefaultTopMargin) {
            touchY = kDefaultTopMargin;
        }
        else if (touchY > self.receivingView.frame.size.height - kDefaultBottomMargin) {
            touchY = self.receivingView.frame.size.height - kDefaultBottomMargin;
        }
        
        [self expandItemsAtPoint:CGPointMake(touchX, touchY)];
    }
}

@end

@implementation UIView (KLExpandingSelect)

-(void) setExpandingSelect:(KLExpandingSelect*) expandingSelect {
    expandingSelect.receivingView = self;
    
    //Register for touch events on long press
    UILongPressGestureRecognizer* gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget: expandingSelect    
                                                                                                    action:@selector(longPressDidFire:)];
    
    //Set the default time length for the touch to fire
    [gestureRecognizer setMinimumPressDuration: kLongPressDuration];
    
    //Add recognizer to the view
    [self addGestureRecognizer:gestureRecognizer];
}
@end 
@implementation KLExpandingPetal

-(id) initWithImage:(UIImage*) image {
    if (self = [super initWithFrame:CGRectMake(0, 0, kPetalWidth, kPetalHeight)]) {
        [self setAlpha: kPetalAlpha];
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.backgroundImage = [[UIImageView alloc] initWithImage:image];
        [self.backgroundImage setFrame: self.bounds];
        [self addSubview:self.backgroundImage];
        
        //Set up the shadows
        [self.layer setShadowColor:[kPetalShadowColor CGColor]];
        [self.layer setShadowOffset: kPetalShadowOffset];
        [self.layer setShadowOpacity: kPetalShadowOpacity];
        [self.layer setShadowRadius: kPetalShadowRadius];
        
        [self.layer setShouldRasterize: YES];
        [self.layer setRasterizationScale: kDefaultRasterizationScale];
    }
    return self;
}

- (void)rotationWithDuration:(NSTimeInterval)duration
                       angle:(CGFloat)angle
                  completion:(void (^)(BOOL finished))completion
{
    // Repeat a quarter rotation as many times as needed to complete the full rotation
    CGFloat sign = angle > 0 ? 1 : -1;
    NSUInteger numberRepeats = floorf(fabsf(angle) / M_PI_2);
    CGFloat quarterDuration = duration * M_PI_2 / fabs(angle);
    
    CGFloat lastRotation = angle - sign * numberRepeats * M_PI_2;
    CGFloat lastDuration = duration - quarterDuration * numberRepeats;
        
    [self lastRotationBlockWithDuration:lastDuration
                            andRotation:lastRotation];
    
    [self quarterSpinningBlock:quarterDuration
                      duration:lastDuration
                      rotation:lastRotation
                 numberRepeats:numberRepeats];
    
    return completion(YES);
}

-(void) quarterSpinningBlock: (CGFloat) quarterDuration
                duration: (NSInteger) duration
                rotation: (NSInteger) rotation
               numberRepeats: (NSInteger) numberRepeats
{
    if (numberRepeats) {
    [UIView animateWithDuration:quarterDuration
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, M_PI_2);
                     }
                     completion:^(BOOL finished) {
                         if (numberRepeats > 0) {
                             [self quarterSpinningBlock: quarterDuration
                                               duration: duration
                                               rotation: rotation
                                          numberRepeats: numberRepeats - 1];
                         } else {
                             [self lastRotationBlockWithDuration:duration
                                                     andRotation:rotation];
                             return;
                             
                         }
                     }
     ];
    }
    else {
        [self lastRotationBlockWithDuration: duration
                                andRotation: rotation];
    }
}

-(void) lastRotationBlockWithDuration: (CGFloat) duration
                          andRotation: (CGFloat) rotation {
    [UIView animateWithDuration: duration
                          delay: 0
                        options: UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.transform = CGAffineTransformRotate(self.transform, rotation);
                     }
                     completion:^(BOOL finished) {
                     }
     ];
}

@end