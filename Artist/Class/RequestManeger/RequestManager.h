//
//  RequestManager.h
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

#import <Foundation/Foundation.h>
#import "JSONKit.h"
#import "JHAppDelegate.h"

typedef void (^RMResult)(NSData* response, NSError* error);

/******************************************************************************* 
 * RequestManager adds to object url-request sending possibility 
 * Response can be received with delegate methods, or with block completion handler.
 */
@interface RequestManager : NSObject 

// Shows logging strings in console if YES
@property (nonatomic, assign)BOOL logging;
@property (nonatomic, assign)BOOL showLoadingProcess;

// Returns shared instance of RequestManager class
+ (RequestManager *)sharedManager;

// Performs request. If sync == TRUE, result will be returned via delegate.
- (id)object:(id)obj sendRequest:(NSURLRequest *)req sync:(BOOL)sync;

// Asynchronously performs request
- (void)sendRequest:(NSURLRequest *)req withCompletionHandler:(RMResult)handler;

//Notification Alert
- (void)showloadingAlert;
- (void)hideLoadingAlert;

@end

/******************************************************************************* 
 * RequestManagerDelegate shows info about RequestManager status. 
 * Delegate methods can be used with or without object callback method.
 */
@protocol RequestManagerDelegate <NSObject>
@optional

/* StartLoading will be called when manager connection received response from the server.
 * Returns curent url request. 
 */
- (void)managedRequestStartLoading:(NSURLRequest *)request;

/* EndLoading will be called when manager connection finished load data from the server. 
 * Returns curent url request.
 */
- (void)managedRequestEndLoading:(NSURLRequest *)request;

/* Will be called when manager connection received part of data. 
 * Returns curent url request and percentage of all received bytes
 */
- (void)managedRequest:(NSURLRequest *)request didReceivePercent:(NSNumber *)percent;

/*Returns bytes in NSData format when manager received all expected data.
 */
- (void)managedRequest:(NSURLRequest *)request didReceiveData:(NSData *)data;

/* Will be called when manager connection received an error. 
 * Returns curent url request and pointer to NSErrror object.
 */
- (void)managedRequest:(NSURLRequest *)request didReceiveError:(NSError *)error;
@end

/******************************************************************************* 
 * RequestManager additions to NSObject class. 
 * Requests can be sended as current class method.
 */
@interface NSObject (RequestManagerEx) 

- (void)sendRequest:(NSURLRequest *)req;
- (id)sendSyncRequest:(NSURLRequest *)req;

- (void)sendRequest:(NSURLRequest *)req withCompletionHandler:(RMResult)handler;
- (void)sendHiddenRequest:(NSURLRequest *)req withCompletionHandler:(RMResult)handler;

- (void)requestURL:(NSURL *)url withCompletionHandler:(RMResult)handler;

@end