//
//  ActionImageView.h
//  DollarTapper
//
//  Created by Chang Long Li on 7/19/12.
//  Copyright (c) 2012 NewTech Co, Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ActionImageViewDelegate

- (void) didClickImage:(id)sender;
- (void) didLongPressImage:(id)sender;

@end

@interface ActionImageView : UIImageView

@property (nonatomic, assign) id<ActionImageViewDelegate> delegate;

@end
