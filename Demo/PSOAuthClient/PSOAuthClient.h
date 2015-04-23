//
//  PSOAuthClient.h
//  PSOAuthClient
//
//  Created by Prince Shekhar Valluri on 23/04/15.
//  Copyright (c) 2015 Prince Shekhar Valluri. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PSOAuthClientDelegate.h"

/****************************/
/***  Google OAuth Demo   ***/
/****************************/

#define G_CLIENT_ID         @"YOUR_GOOGLE_CLIENT_ID"
#define G_CLIENT_SECRET     @"YOUR_GOOGLE_CLIENT_SECRET"
#define G_REDIRECT_URL      @"urn:ietf:wg:oauth:2.0:oob:auto"
#define G_AUTH_URL          @"https://accounts.google.com/o/oauth2/auth"
#define G_TOKEN_URL         @"https://www.googleapis.com/oauth2/v3/token"
#define G_SUCCESS_REGEX     @"(?<=Success Code=).*$"
#define G_ERROR_REGEX       @"(?<=Denied error=).*$"
#define G_PAGE_TITLE        @"Google OAuth"

/******************************/
/***  Facebook OAuth Demo   ***/
/******************************/

#define FB_CLIENT_ID        @"YOUR_FACEBOOK_CLIENT_ID"
#define FB_CLIENT_SECRET    @"YOUR_FACEBOOK_CLIENT_SECRET"
#define FB_REDIRECT_URL     @"https://www.facebook.com/connect/login_success.html"
#define FB_AUTH_URL         @"https://www.facebook.com/dialog/oauth"
#define FB_TOKEN_URL        nil
#define FB_SUCCESS_REGEX    @"(?<=access_token=).*?(?=&expires_in=)"
#define FB_ERROR_REGEX      @"(?<=error_reason=).*$"
#define FB_PAGE_TITLE       @"Facebook OAuth"

typedef enum {
    AuthCodeResponseTypeURL, // Facebook and other OAuth's
    AuthCodeResponseTypePageTitle // Google OAuth (and maybe a few others too)
} AuthCodeResponseType;

typedef enum {
    HTTPMethodGet,
    HTTPMethodPost
} HTTPMethod;

@interface PSOAuthClient : NSObject

@property (nonatomic, weak) id<PSOAuthClientDelegate> delegate;
@property (nonatomic, weak) UIViewController *parentViewController;

- (id)      initWithClientID:(NSString *)clientID
                clientSecret:(NSString *)clientSecret
                 redirectURL:(NSString *)redirectURL
                     authURL:(NSString *)authURL
                    tokenURL:(NSString *)tokenURL
             withReponseType:(AuthCodeResponseType)responseType
    successAuthResponseRegex:(NSString *)successRegex
      errorAuthResponseRegex:(NSString *)errorRegex
                    andTitle:(NSString *)title;

- (void)authenticateUsingWebViewAndParams:(NSDictionary *)params;
- (void)fetchOAuthAccessTokenWithParams:(NSDictionary *)accessTokenParams fromURL:(NSString *)tokenURL andMethod:(HTTPMethod)httpMethod;
- (void)refreshTokenWithParams:(NSDictionary *)refreshTokenParams fromURL:(NSString *)tokenURL andMethod:(HTTPMethod)httpMethod;

@end

@interface NSDictionary (GetParamsEncoding)

- (NSString *)convertToParams;

@end
