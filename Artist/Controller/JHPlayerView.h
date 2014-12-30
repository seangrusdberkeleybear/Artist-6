//
//  JHPlayerViewController.h
//  AFM
//
//  Created by Sean Grusd on 10/9/12.
//  Copyright (c) 2012 Sean Grusd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JHPlayerView : UIViewController {
    
    MPMoviePlayerController *player;
}

@property (nonatomic, retain) NSString * videoPath;

@end
