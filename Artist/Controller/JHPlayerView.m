//
//  JHPlayerViewController.m
//  AFM
//
//  Created by Sean Grusd on 10/9/12.
//  Copyright (c) 2012 Sean Grusd. All rights reserved.
//

#import "JHPlayerView.h"

@interface JHPlayerView ()

@end

@implementation JHPlayerView

@synthesize videoPath;

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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", videoPath]];
    player = [[MPMoviePlayerController alloc] initWithContentURL:url];
    
    player.controlStyle = MPMovieControlStyleFullscreen;
    player.fullscreen = YES;
    [player setAllowsAirPlay:YES];
    player.shouldAutoplay = YES;
    [player prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishMoviePlayback) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishMoviePlayback) name:MPMoviePlayerDidExitFullscreenNotification object:nil];
    
    player.view.frame = self.view.bounds;
    [player.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:player.view];
    [player play];
}

- (void)didFinishMoviePlayback {
    
    if (player != nil) {
        [player.view removeFromSuperview];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dealloc
{
    [super dealloc];
    [player release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

@end
