//
//  ActionImageView.m
//  DollarTapper
//
//  Created by Chang Long Li on 7/19/12.
//  Copyright (c) 2012 NewTech Co, Ltd. All rights reserved.
//

#import "ActionImageView.h"

@implementation ActionImageView

@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {

        UITapGestureRecognizer *tapRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)] autorelease];
        UILongPressGestureRecognizer *longpressRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)] autorelease];
        [self addGestureRecognizer:tapRecognizer];
        [self addGestureRecognizer:longpressRecognizer];
    }

    return self;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)tapRecognizer
{
    [delegate didClickImage:self];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)longpressRecognizer
{
    [delegate didLongPressImage:self];
}

@end
