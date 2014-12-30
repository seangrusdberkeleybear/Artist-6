//
//  JHCustomView.m
//  ABC
//
//  Created by Sean Grusd on 1/16/13.
//  Copyright (c) 2013 Sean Grusd. All rights reserved.
//

#import "JHCustomView.h"
#import "JHAppDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import <QuartzCore/QuartzCore.h>

@interface JHCustomView ()

@end

@implementation JHCustomView

@synthesize mainImage;
@synthesize pDelegate;
@synthesize videoPath;

+ (JHCustomView *)sharedImageView:(NSString *)imageName {
    
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"JHCustomView" owner:nil options:nil];
    
    JHCustomView * cell = [array objectAtIndex:0];
    
    if ( cell ) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imageName]];
        
        [request setDownloadCache:[ASIDownloadCache sharedCache]];
        [request setCachePolicy:ASIUseDefaultCachePolicy];
        [request setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];
        [request setDelegate:cell];
        [request setDidStartSelector:@selector(didStartDownload:)];
        [request setDidFinishSelector:@selector(didFinishDownload:)];
        [request setDidFailSelector:@selector(didFailDownload:)];
        [request startAsynchronous];
        [cell.activityIndicator startAnimating];
        
        cell.request = request;
        [cell.mainImage.layer setCornerRadius:0];
        [cell.mainImage.layer setBorderWidth:0];
    }
    
    return cell;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    mainImage.delegate = self;
}

- (void) didClickImage:(id)sender {
    
    if ( sender == mainImage ) {
        [pDelegate selectImage:sender andVideoPath:videoPath];
    }
}

- (void) didLongPressImage:(id)sender {
    
}

@end
