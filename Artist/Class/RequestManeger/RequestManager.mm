//
//  RequestManager.m
//  RequestManager
//
//  Created by Maxim Koshtenko on 6/11/11.
//
//	Copyright 2011 Maxim Koshtenko
//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.

#import "RequestManager.h"

#define RMLog(fmt, ...)	\
if([RequestManager sharedManager].logging)NSLog((@"[Line %d] %@ " fmt), __LINE__, @"RequestManager >", ##__VA_ARGS__)

////////////////////////////////////////////////////////////////////////////////
#pragma mark RMRequest
////////////////////////////////////////////////////////////////////////////////
@interface RMRequest : NSObject 
@property (nonatomic, strong)id<NSObject> owner;
@property (nonatomic, copy)NSURLRequest	*request;
@property (nonatomic, assign)long long expectedLength;
@property (nonatomic, strong)NSMutableData* data;
@property (copy)RMResult completionHandler;
@end

@implementation RMRequest
@synthesize owner = _owner;
@synthesize request = _request;
@synthesize expectedLength = _expectedLength;
@synthesize data = _data;
@synthesize completionHandler = _completionHandler;

#if !__has_feature(objc_arc)
- (void)dealloc
{
	[_owner release];
	[_request release];
	[_data release];
	[super dealloc];
}
#endif
@end
////////////////////////////////////////////////////////////////////////////////
#pragma mark NSURLConnection+RequestManager
////////////////////////////////////////////////////////////////////////////////
@interface NSURLConnection (RequestManager) 
- (NSString *)makeKey;
@end

@implementation NSURLConnection (RequestManager)
- (NSString *)makeKey
{
	return [NSString stringWithFormat:@"%@", self];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark RequestManager Private
////////////////////////////////////////////////////////////////////////////////

@interface RequestManager () 

// Storage for active requests
@property (nonatomic, strong)NSMutableDictionary *requestsData;

@property (nonatomic, strong)UIView* loadingAlert;

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark RequestManager
////////////////////////////////////////////////////////////////////////////////
@implementation RequestManager

@synthesize requestsData = _requestsData;
@synthesize loadingAlert = _loadingAlert;
@synthesize logging = _logging;
@synthesize showLoadingProcess = _showLoadingProcess;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Singleton
////////////////////////////////////////////////////////////////////////////////
- (id)init
{
	self = [super init];
	if(self)
	{
		_requestsData = [[NSMutableDictionary alloc]init];
	}
	return self;
}

+ (RequestManager *)sharedManager
{
#if __has_feature(objc_arc)
	__strong static RequestManager*	_sharedManager = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[RequestManager alloc]init];
	});	
#else
	static RequestManager*	_sharedManager;	
    if (_sharedManager == nil) 
	{
		_sharedManager = [[super allocWithZone:NULL] init];		
		RMLog(@"Init: ARC-off");
    }
#endif
	
    return _sharedManager;
}

#if !__has_feature(objc_arc)
+ (id)allocWithZone:(NSZone *) zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *) zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;  
}

- (oneway void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

- (void)dealloc
{
	[super dealloc];
}
#endif

////////////////////////////////////////////////////////////////////////////////
#pragma mark Object Methods
////////////////////////////////////////////////////////////////////////////////
- (id)object:(id)obj sendRequest:(NSURLRequest *)req sync:(BOOL)sync
{	
	if(sync)
	{
		NSError *error = nil;
		NSURLResponse *response;
		NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&response error:&error];
		
		if(error)
		{
			RMLog(@"Error > %@", [error localizedDescription]);
			return nil;
		}
		
		return data;
	}
	else
	{
		NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];			
		
		RMRequest* request = [[RMRequest alloc]init];
		[request setOwner:obj];
		[request setRequest:req];
		[self.requestsData setObject:request forKey:[connection makeKey]];
#if !__has_feature(objc_arc)
		[request release];
#endif
		[connection start];	
	}
	
	return nil;
}

- (void)sendRequest:(NSURLRequest *)req withCompletionHandler:(RMResult)handler
{
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:req delegate:self];			
	
	RMRequest* request = [[RMRequest alloc]init];
	[request setRequest:req];
	[request setCompletionHandler:handler];
#if !__has_feature(objc_arc)
	[handler release];
#endif
	[self.requestsData setObject:request forKey:[connection makeKey]];
#if !__has_feature(objc_arc)
	[request release];
#endif
	
	if(self.showLoadingProcess)
		[self showloadingAlert];
	
	[connection start];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Notification Alert
////////////////////////////////////////////////////////////////////////////////
- (void)showloadingAlert
{
	if(!self.loadingAlert)
	{
		UIWindow *window = [(JHAppDelegate*)[[UIApplication sharedApplication] delegate] window];
		CGSize size = window.frame.size;

		_loadingAlert = [[UIView alloc] initWithFrame:CGRectMake(0, 0,  size.height, size.width)];
		_loadingAlert.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
		UIActivityIndicatorView *ind = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		ind.center = CGPointMake(size.height/2, size.width/2);
		[self.loadingAlert addSubview:ind];
		[ind startAnimating];
		[window.rootViewController.view addSubview:self.loadingAlert];
	}
}

- (void)hideLoadingAlert
{
	if(self.loadingAlert)
	{
		[_loadingAlert removeFromSuperview];
		self.loadingAlert = nil;
	}
}


////////////////////////////////////////////////////////////////////////////////
#pragma mark NSURLConnectionDelegate
////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response 
{	
	RMRequest* request = [self.requestsData objectForKey:[connection makeKey]];
	
	// Save length of all expected data
	long long expLength = [response expectedContentLength];
	[request setExpectedLength:expLength];
	// Container for future data
	NSMutableData* data = [[NSMutableData alloc]init];
#if !__has_feature(objc_arc)
	[data autorelease];
#endif
	[request setData:data];
	
	// Using protocol
	if([[request owner] respondsToSelector:@selector(managedRequestStartLoading:)])
		[[request owner]performSelector:@selector(managedRequestStartLoading:) withObject:[request request]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	// Dictionary with data for request 
	RMRequest* request = [self.requestsData objectForKey:[connection makeKey]];
	
	// Append new bytes
	[[request data] appendData:data];
	
	// Calculating percentages
	long long expLength = [request expectedLength];
	if(expLength != NSURLResponseUnknownLength)
	{
		NSInteger recvLength = [[request data] length];
		float percent = (float)recvLength/expLength*100.0;		
		
		// Using protocol
		if([[request owner] respondsToSelector:@selector(managedRequest:didReceivePercent:)])
			[[request owner] performSelector:@selector(managedRequest:didReceivePercent:) withObject:[request request] withObject:[NSNumber numberWithFloat:percent]];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
	// Dictionary with data for request 
	RMRequest* request = [self.requestsData objectForKey:[connection makeKey]];
#if !__has_feature(objc_arc)	
    [connection release];
#endif
	
    RMLog(@"Error > %@",[error localizedDescription]);

	// Using protocol
	if([[request owner] respondsToSelector:@selector(managedRequest:didReceiveError:)])
		[[request owner] performSelector:@selector(managedRequest:didReceiveError:) withObject:[request request] withObject:error];
	
	if([[request owner] respondsToSelector:@selector(managedRequestEndLoading:)])
		[[request owner]performSelector:@selector(managedRequestEndLoading:) withObject:[request request]];
	
	// Using handler
	if([request completionHandler])
	{
		request.completionHandler(nil, error);
#if !__has_feature(objc_arc)
		[request.completionHandler release];
#endif
	}
	
	// Remove terminated url request from queue
	[self.requestsData removeObjectForKey:[connection makeKey]];
	
	[self hideLoadingAlert];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{		
	// Dictionary with data for request 
	RMRequest* request = [self.requestsData objectForKey:[connection makeKey]];
#if !__has_feature(objc_arc)	
	[connection release];	
#endif

	// Using protocol
	if([[request owner] respondsToSelector:@selector(managedRequest:didReceiveData:)])
		[[request owner] performSelector:@selector(managedRequest:didReceiveData:) withObject:[request request] withObject:[request data]];
	
	if([[request owner] respondsToSelector:@selector(managedRequestEndLoading:)])
		[[request owner]performSelector:@selector(managedRequestEndLoading:) withObject:[request request]];
	
	// Using handler
	if([request completionHandler])
	{
		NSData* dataCopy = [[request data]copy];
#if !__has_feature(objc_arc)
		[dataCopy autorelease];
#endif
		request.completionHandler(dataCopy, nil);
#if !__has_feature(objc_arc)
		[request.completionHandler release];
#endif
	}
	
	// Remove completed url request from queue
	[self.requestsData removeObjectForKey:[connection makeKey]];
	
	[self hideLoadingAlert];
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
			[challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
	
	[challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject+RequestManager
////////////////////////////////////////////////////////////////////////////////
@implementation NSObject (RequestManagerEx) 

- (void)sendRequest:(NSURLRequest *)req
{
	[[RequestManager sharedManager]object:self sendRequest:req sync:NO];
}

- (id)sendSyncRequest:(NSURLRequest *)req
{
	return [[RequestManager sharedManager]object:self sendRequest:req sync:YES];
}

- (void)sendRequest:(NSURLRequest *)req withCompletionHandler:(RMResult)handler
{
	[[RequestManager sharedManager] setShowLoadingProcess:YES];
	[[RequestManager sharedManager]sendRequest:req withCompletionHandler:handler];
}

- (void)sendHiddenRequest:(NSURLRequest *)req withCompletionHandler:(RMResult)handler
{
	[[RequestManager sharedManager] setShowLoadingProcess:NO];
	[[RequestManager sharedManager]sendRequest:req withCompletionHandler:handler];
}

- (void)requestURL:(NSURL *)url withCompletionHandler:(RMResult)handler
{
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc]init];
#if !__has_feature(objc_arc)
	[request autorelease];
#endif
	[request setURL:url];
	[request setHTTPMethod:@"GET"];
	[self sendRequest:request withCompletionHandler:handler];
}

@end

