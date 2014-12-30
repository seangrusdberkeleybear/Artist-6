//
//  RGService.m
//  RevolutionGolf
//
//  Created by Zhuk Evgen on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PFService.h"
#import "JSONKit.h"

#define API_KEY                 @"4AZBQ5PXGFH5IOAVT"

@implementation PFService

@synthesize timeOffset = _timeOffset;
@synthesize urlStr;

+ (PFService*)sharedManeger
{
	__strong static PFService*	_sharedManager = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[PFService alloc]init];
        _sharedManager.urlStr = @"http://developer.echonest.com/api/v4/artist";
	});	
	
	return _sharedManager;
}

#pragma mark - Notification Alert

+ (void)showAlertWithConnectionError
{
	UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Connection error"
												   message:@"Could not connect to server"
												  delegate:nil
										 cancelButtonTitle:@"OK"
										 otherButtonTitles: nil];
	[alrt show];
}

+ (void)showAlertWithHeader:(NSString*)header andMessage:(NSString*)message
{
	UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:header
												   message:message
												  delegate:nil
										 cancelButtonTitle:@"OK"
										 otherButtonTitles: nil];
	[alrt show];
}

#pragma mark - Login/Registration

- (void)getArtistList:(NSString*)name withCompletationHandler:(RMResult)handler
{	
	NSString *api_path = [NSString stringWithFormat:@"%@/search?api_key=%@&format=json&name=%@&results=20&sort=familiarity-desc", urlStr, API_KEY, name];
	
//	NSString *postBody = [NSString stringWithFormat:nil];
	
    api_path = [api_path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:api_path]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30.0];
    [req setHTTPMethod:@"GET"];
//	[req setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    [self sendHiddenRequest:req withCompletionHandler:handler];
}

- (void)getDetailArtist:(NSString*)artistID withCompletationHandler:(RMResult)handler
{
	NSString *api_path = [NSString stringWithFormat:@"%@/profile?api_key=%@&id=%@&format=json&bucket=biographies&bucket=blogs&bucket=familiarity&bucket=hotttnesss&bucket=images&bucket=news&bucket=reviews&bucket=terms&bucket=urls&bucket=video&bucket=id:musicbrainz", urlStr, API_KEY, artistID];
	
    //	NSString *postBody = [NSString stringWithFormat:nil];
	
    api_path = [api_path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:api_path]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30.0];
    [req setHTTPMethod:@"GET"];
    //	[req setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    [self sendHiddenRequest:req withCompletionHandler:handler];
}

- (NSArray*)getMyFeed:(NSRange)page
{
	NSString *api_path = [NSString stringWithFormat:@"%@/get_feed", urlStr];
	
	NSString *postBody = [NSString stringWithFormat:@"my=1&offset=%d&limit=%d", page.location, page.length];
	
    api_path = [api_path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:api_path]
															cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:30.0];
    [req setHTTPMethod:@"POST"];
	[req setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *dict = [[self sendSyncRequest:req] objectFromJSONData];
	if(dict)
	{
		if([dict isKindOfClass:[NSError class]])
		{
			UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Connection error"
														   message:@"Could not connect to server"
														  delegate:nil
												 cancelButtonTitle:@"OK"
												 otherButtonTitles: nil];
			[alrt show];
			//NSLog(@"FAIL: %@", dict);
			return [NSArray array];
		}
		else
		{
			if([[dict objectForKey:@"data"] isKindOfClass:[NSArray class]])
			{
				NSTimeInterval deviceTime = [[NSDate date] timeIntervalSince1970];
				self.timeOffset = deviceTime - [[dict objectForKey:@"time"] doubleValue];
				//NSLog(@"Time Offset: %f", self.timeOffset);
				//NSLog(@"%@", dict);
				return [dict objectForKey:@"data"];
			}
			else
			{				
				UIAlertView *alrt = [[UIAlertView alloc] initWithTitle:@"Server error"
															   message:[dict objectForKey:@"error"]
															  delegate:nil
													 cancelButtonTitle:@"OK"
													 otherButtonTitles: nil];
				[alrt show];
				return [NSArray array];
			}
		}
    }
	
	return [NSArray array];
}

@end
