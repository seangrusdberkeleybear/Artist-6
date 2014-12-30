//
//  JHDetailView.h
//  Artist
//
//  Created by Sean Grusd on 1/20/13.
//  Copyright (c) 2013 Sean Grusd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JHCustomView.h"

@interface JHDetailView : UIViewController <UIScrollViewDelegate, JHCustomViewDelegate> {
    
    IBOutlet UILabel * familiarityLabel;
    IBOutlet UILabel * hotnessLabel;
    IBOutlet UIScrollView * scrollView;
    IBOutlet UIScrollView * imageScrollView;
    IBOutlet UITextView * biographiesTextView;
    IBOutlet UIPageControl * pageControll;
}

@property (nonatomic, retain) NSDictionary * artistDict;
@property (nonatomic, retain) NSString * artistName;

@end
