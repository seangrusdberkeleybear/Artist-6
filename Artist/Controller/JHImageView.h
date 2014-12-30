//
//  JHImageView.h
//  App4Free
//
//  Created by Sean Grusd on 11/30/12.
//  Copyright (c) 2012 Sean Grusd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"

@interface JHImageView : UIView

@property (nonatomic, retain) IBOutlet UIImageView * mainImage;
@property ( strong, nonatomic ) IBOutlet UIActivityIndicatorView* activityIndicator ;
@property (nonatomic, retain) ASIHTTPRequest *request;

+ ( JHImageView* ) sharedImageCell : ( NSString* ) strPath;

@end

