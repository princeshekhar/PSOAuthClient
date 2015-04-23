//
//  PSOAuthClientDelegate.h
//  PSOAuthClient
//
//  Created by Prince Shekhar Valluri on 23/04/15.
//  Copyright (c) 2015 Prince Shekhar Valluri. All rights reserved.
//

@class PSOAuthClient;

@protocol PSOAuthClientDelegate <NSObject>
- (void)oauthClient:(PSOAuthClient *)client didReceiveAccessCode:(NSString *)accessCode;
- (void)oauthClient:(PSOAuthClient *)client failedToReceiveAccessCode:(NSString *)error;

- (void)oauthClient:(PSOAuthClient *)client didReceiveAccessToken:(NSDictionary *)response;
- (void)oauthClient:(PSOAuthClient *)client failedToReceiveAccessToken:(NSError *)error;

@optional
- (void)oauthClientDidCancel:(PSOAuthClient *)client;

@end
