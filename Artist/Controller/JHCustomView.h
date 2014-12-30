//
//  JHCustomView.h
//  ABC
//
//  Created by Sean Grusd on 1/16/13.
//  Copyright (c) 2013 Sean Grusd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ActionImageView.h"
#import "ASIHTTPRequest.h"

@protocol JHCustomViewDelegate

@optional

- (void)selectImage:(id)sender andVideoPath:(NSString *) videoPath;

@end

@interface JHCustomView : UIView <ActionImageViewDelegate> {
    
    ActionImageView * mainImage;
}

@property (nonatomic, retain) IBOutlet ActionImageView * mainImage;
@property (nonatomic, assign) id<JHCustomViewDelegate> pDelegate;
@property (nonatomic, retain) NSString * videoPath;

@property ( strong, nonatomic ) IBOutlet UIActivityIndicatorView* activityIndicator ;
@property (nonatomic, retain) ASIHTTPRequest *request;

+ (JHCustomView *)sharedImageView:(NSString *)imageName;

@end
