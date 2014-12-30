//
//  JHDetailView.m
//  Artist
//
//  Created by Sean Grusd on 1/20/13.
//  Copyright (c) 2013 Sean Grusd. All rights reserved.
//

#import "JHDetailView.h"
#import "JHImageView.h"
#import "JHPlayerView.h"

@interface JHDetailView ()

@end

@implementation JHDetailView

@synthesize artistDict;
@synthesize artistName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = artistName;
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, 700)];
    
    NSArray * biographyArray = [artistDict objectForKey:@"biographies"];
    for ( int i = 0; i < [biographyArray count]; i ++ ) {
        
        NSDictionary * dict = [biographyArray objectAtIndex:i];
        NSString * site = [dict objectForKey:@"site"];
        if ( [site isEqualToString:@"last.fm"] ) {
            biographiesTextView.text = [dict objectForKey:@"text"];
            break;
        }
        if ( i == [biographyArray count] - 1 ) {
            biographiesTextView.text = [dict objectForKey:@"text"];
        }
    }
    float familiarity = ((NSString *)[artistDict objectForKey:@"familiarity"]).floatValue;
    float hotness = ((NSString *)[artistDict objectForKey:@"hotttnesss"]).floatValue;
    
    familiarityLabel.text = [NSString stringWithFormat:@"Familiarity: %.2f", familiarity];
    hotnessLabel.text = [NSString stringWithFormat:@"Hotness: %.2f", hotness];
    
    NSArray * screenshots = [artistDict objectForKey:@"images"];
    CGFloat width, height;
    for ( int i = 0; i < [screenshots count]; i ++ ) {
        
        NSDictionary * dict = [screenshots objectAtIndex:i];
        NSString * imagePath = [dict objectForKey:@"url"];
        
        JHImageView * imageView = [JHImageView sharedImageCell:imagePath];
        width = imageView.frame.size.width;
        height = imageView.frame.size.height;
        imageView.frame = CGRectMake(i * imageView.frame.size.width, 0, imageView.frame.size.width, imageView.frame.size.height);
        [imageScrollView addSubview:imageView];
    }
    [imageScrollView setContentSize:CGSizeMake(width * [screenshots count] , height)];
    pageControll.numberOfPages = [screenshots count];
    
    CGFloat imageWidth = 0;
    CGFloat imageHeight = 0;
    CGFloat imageTop = 680;
    CGFloat imageLeft = 15;
    CGFloat divisionWidth = 10;
    CGFloat divisionHeight = 10;
        
    int nColumns = 2;
    
    NSArray * videoArray = [artistDict objectForKey:@"video"];
    
    for ( int i = 0; i < [videoArray count]; i ++ ) {
        
        NSDictionary * dict = [videoArray objectAtIndex:i];
        
        JHCustomView * tempView = [JHCustomView sharedImageView:[dict objectForKey:@"image_url"]];
        
        imageWidth = tempView.frame.size.width;
        imageHeight = tempView.frame.size.height;
        
        tempView.pDelegate = self;
        tempView.videoPath = [dict objectForKey:@"url"];
        
        CGFloat left = imageLeft + (imageWidth + divisionWidth) * (i % nColumns);
        CGFloat top = imageTop + (imageHeight + divisionHeight) * (i / nColumns);
        
        tempView.frame = CGRectMake(left, top, imageWidth, imageHeight);
        
        [scrollView addSubview:tempView];
    }
    [scrollView setContentSize:CGSizeMake(self.view.frame.size.width, (ceil((CGFloat)[videoArray count] / nColumns)) * (imageHeight + divisionHeight) + imageTop)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- UIScrollView Delegate.

- (void)scrollViewDidScroll:(UIScrollView *)_scrollView {
    
    if ( _scrollView == imageScrollView ) {
        CGPoint point = [imageScrollView contentOffset];
        
        int nOffsetWidth = 290;
        int nOffset = point.x / nOffsetWidth;
        int nRemain = (int)point.x % nOffsetWidth;
        if ( nRemain == 0 ) {
            pageControll.currentPage = nOffset;
        }
    }
}

#pragma mark- JHCustomView Delegate.

- (void)selectImage:(id)sender andVideoPath:(NSString *) videoPath {
    
    JHPlayerView * playerView = [[[JHPlayerView alloc] initWithNibName:@"JHPlayerView" bundle:nil] autorelease];
    playerView.videoPath = videoPath;
    
    [self presentViewController:playerView animated:YES completion:nil];
}

@end
