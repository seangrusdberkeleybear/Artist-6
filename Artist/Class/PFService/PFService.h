//
//  RGService.h
//  RevolutionGolf
//
//  Created by Zhuk Evgen on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"

#define DEFAULT_PAGINATION_LIMIT 20
#define TESTING_SERVER 1

typedef enum
{
	PFServiceOrderLevel = 0,
	PFServiceOrderName = 1,
	PFServiceOrderNationality = 2
}PFServiceOrder;

@interface PFService : NSObject

@property (assign, nonatomic) NSTimeInterval timeOffset;
@property (strong, nonatomic) NSString *urlStr;

+ (PFService*)sharedManeger;
+ (void)showAlertWithHeader:(NSString*)header andMessage:(NSString*)message;
+ (void)showAlertWithConnectionError;

- (NSArray*)getMyFeed:(NSRange)page;
- (void)getArtistList:(NSString*)name withCompletationHandler:(RMResult)handler;
- (void)getDetailArtist:(NSString*)artistID withCompletationHandler:(RMResult)handler;

@end
