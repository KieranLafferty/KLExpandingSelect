KLExpandingSelect
=======

<img src="https://raw.github.com/KieranLafferty/KLExpandingSelect/master/KLExpandingSelect/iPhoneScreenshot.png" width="50%"/>

Have a  menu appear exposing beautiful and easy to access buttons to the user without removing them from where they want to be. 

Note: KLExpandingSelect is intended for use with portrait orientation on iPhone/iPad/iPod Touch.

[Check out the Demo](http://www.youtube.com/watch?v=PQZiZt5d5bY&feature=youtube_gdata_player) *Excuse the graphics glitches and lag due to my slow computer.*

<!-- MacBuildServer Install Button -->
<div class="macbuildserver-block">
    <a class="macbuildserver-button" href="http://macbuildserver.com/project/github/build/?xcode_project=KLExpandingSelect.xcodeproj&amp;target=KLExpandingSelect&amp;repo_url=git%3A%2F%2Fgithub.com%2FKieranLafferty%2FKLExpandingSelect.git&amp;build_conf=Release" target="_blank"><img src="http://com.macbuildserver.github.s3-website-us-east-1.amazonaws.com/button_up.png"/></a><br/><sup><a href="http://macbuildserver.com/github/opensource/" target="_blank">by MacBuildServer</a></sup>
</div>
<!-- MacBuildServer Install Button -->


## Installation ##

Drag the included <code>KLExpandingSelect.h, KLExpandingSelect.m</code> files into your project. Then, include the following frameworks under *Link Binary With Libraries*:

* QuartzCore.framework


Install via Cocoapods by adding the following line to your podfile

	pod 'KLExpandingSelect'
	
## Usage ##

Import the required file and declare your controller to conform to the KLExpandingSelect datasource and delegate

	#import "KLExpandingSelect.h"

	@interface KLRootViewController : UIViewController <KLExpandingSelectDataSource, KLExpandingSelectDelegate>


Initialize the control

	// Configure the Expander Select and add to view controllers view.
    self.expandingSelect = [[KLExpandingSelect alloc] initWithDelegate: self
                                                            dataSource: self];
    [self.view setExpandingSelect:self.expandingSelect];
    [self.view addSubview: self.expandingSelect];

Implement the required methods of the data source 

	- (NSInteger)expandingSelector:(id) expandingSelect numberOfRowsInSection:(NSInteger)section{
	    return [self.selectorData count];
	}
	- (KLExpandingPetal *)expandingSelector:(id) expandingSelect itemForRowAtIndexPath:(NSIndexPath *)indexPath {
    	NSDictionary* dictForPetal = [self.selectorData objectAtIndex:indexPath.row];
    	NSString* imageName = [dictForPetal objectForKey:@"image"];
    	KLExpandingPetal* petal = [[KLExpandingPetal alloc] initWithImage:[UIImage imageNamed:imageName]];
    	return petal;
	}

Implement the optional delegate method to be notified when a new item is selected

	// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
	- (NSIndexPath *)expandingSelector:(id)expandingSelect willSelectItemAtIndexPath:(NSIndexPath *)indexPath;
	
	// Called after the user changes the selection.
	- (void)expandingSelector:(id)expandingSelect didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
	
	//Called after the animations have completed
	- (void)expandingSelector:(id)expandingSelect didFinishExpandingAtPoint:(CGPoint) point;
	- (void)expandingSelector:(id)expandingSelect didFinishCollapsingAtPoint:(CGPoint) point;
	
	- (void)expandingSelector:(id)expandingSelect didFinishExpandingPetal: (KLExpandingPetal*) petal;
	- (void)expandingSelector:(id)expandingSelect didFinishCollapsingPetal: (KLExpandingPetal*) petal;


## Config ##
The visual appearance can be tweaked by changing the constants in <code>KLExpandingSelect.m</code>:

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

## Contact ##

* [@kieran_lafferty](https://twitter.com/kieran_lafferty) on Twitter
* [@kieranlafferty](https://github.com/kieranlafferty) on Github
* <a href="mailTo:kieran.lafferty@gmail.com">kieran.lafferty [at] gmail [dot] com</a>

## License ##

Copyright (c) 2012 Kieran Lafferty

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.