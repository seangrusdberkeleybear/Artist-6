//
//  JHImageView.m
//  App4Free
//
//  Created by Sean Grusd on 11/30/12.
//  Copyright (c) 2012 Sean Grusd. All rights reserved.
//

#import "JHImageView.h"
#import "ASIHTTPRequest.h"
#import "ASIDownloadCache.h"
#import <QuartzCore/QuartzCore.h>
#import "JHAppDelegate.h"

@interface JHImageView ()

@end

@implementation JHImageView

@synthesize activityIndicator, request, mainImage;

+ ( JHImageView* ) sharedImageCell : ( NSString* ) strPath {
    
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"JHImageView" owner:nil options:nil];

    JHImageView * cell = [array objectAtIndex:0];
    
    if ( cell ) {
        ASIHTTPRequest * request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:strPath]];
        
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

- ( void ) didStartDownload : ( ASIHTTPRequest* ) _request
{
    [ activityIndicator startAnimating ] ;
    activityIndicator.hidden = NO;
}

- ( void ) didFinishDownload : ( ASIHTTPRequest* ) _request
{
    [ mainImage setImage : [ UIImage imageWithData : [ _request responseData ] ] ] ;
    [ activityIndicator stopAnimating ] ;
}

- ( void ) didFailDownload : ( ASIHTTPRequest* ) _request
{
    [ activityIndicator stopAnimating ] ;
//    UIAlertView *error=[[UIAlertView alloc] initWithTitle:@"Error" message:@"ASIHTTPRequest download failed in ImageView!" delegate:self cancelButtonTitle:@"Confirm" otherButtonTitles:nil];
//    [error show];
}

- (void)dealloc
{
    [self.request setDelegate:nil];
    [self.request cancel];
    self.request = nil;
    
    [super dealloc];
}

@end
