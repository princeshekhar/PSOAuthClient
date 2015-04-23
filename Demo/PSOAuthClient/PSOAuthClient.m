//
//  PSOAuthClient.m
//  PSOAuthClient
//
//  Created by Prince Shekhar Valluri on 23/04/15.
//  Copyright (c) 2015 Prince Shekhar Valluri. All rights reserved.
//

#import "PSOAuthClient.h"
#import "PSOAuthWebViewController.h"

@interface PSOAuthClient() <UIWebViewDelegate, PSOAuthWebViewControllerDelegate>

@property (nonatomic, strong) NSString *pageTitle;
@property (nonatomic, strong) NSString *clientID;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURL;
@property (nonatomic, strong) NSString *authURL;
@property (nonatomic, strong) NSString *tokenURL;

@property (nonatomic) AuthCodeResponseType authResponseType;
@property (nonatomic, strong) NSString *successAuthResponseRegex;
@property (nonatomic, strong) NSString *errorAuthResponseRegex;

@property (nonatomic, strong) PSOAuthWebViewController *authWebViewController;
@property (nonatomic, strong) UINavigationController *authNavigationViewController;

@end

@implementation PSOAuthClient

- (id)      initWithClientID:(NSString *)clientID
                clientSecret:(NSString *)clientSecret
                 redirectURL:(NSString *)redirectURL
                     authURL:(NSString *)authURL
                    tokenURL:(NSString *)tokenURL
             withReponseType:(AuthCodeResponseType)responseType
    successAuthResponseRegex:(NSString *)successRegex
      errorAuthResponseRegex:(NSString *)errorRegex
                    andTitle:(NSString *)title {
    self = [super init];
    if (self) {
        self.clientID = [clientID copy];
        self.clientSecret = [clientSecret copy];
        self.redirectURL = [redirectURL copy];
        self.authURL = [authURL copy];
        self.tokenURL = [tokenURL copy];
        
        self.pageTitle = [title copy];
        
        self.authResponseType = responseType;
        self.successAuthResponseRegex = successRegex;
        self.errorAuthResponseRegex = errorRegex;
    }
    return self;
}

- (void)authenticateUsingWebViewAndParams:(NSDictionary *)params {
    if (!self.parentViewController) {
        NSLog(@"Please set a parentViewController for this object, to show the webview in");
        return;
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.authURL, [params convertToParams]]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    self.authWebViewController = [[PSOAuthWebViewController alloc] initWithRequest:request
                                                                   withReponseType:self.authResponseType
                                                          successAuthResponseRegex:self.successAuthResponseRegex
                                                            errorAuthResponseRegex:self.errorAuthResponseRegex
                                                                          andTitle:self.pageTitle];
    self.authWebViewController.delegate = self;
    
    self.authNavigationViewController = [[UINavigationController alloc] initWithRootViewController:self.authWebViewController];
    self.authNavigationViewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.parentViewController presentViewController:self.authNavigationViewController animated:YES completion:nil];
}

- (void)authWebViewControllerDismissed {
    [self.authNavigationViewController dismissViewControllerAnimated:YES completion:nil];
    if([self.delegate respondsToSelector:@selector(oauthClientDidCancel:)]) {
        [self.delegate oauthClientDidCancel:self];
    }
}

- (void)authRequestUnsuccessful {
    [self.authNavigationViewController dismissViewControllerAnimated:YES completion:nil];
    
    if([self.delegate respondsToSelector:@selector(oauthClient:failedToReceiveAccessCode:)]) {
        [self.delegate oauthClient:self failedToReceiveAccessCode:@"Couldn't fetch access code"];
    }
}

- (void)authRequestSuccessfulWithCode:(NSString *)code {
    [self.authNavigationViewController dismissViewControllerAnimated:YES completion:nil];
    
    if([self.delegate respondsToSelector:@selector(oauthClient:didReceiveAccessCode:)]) {
        [self.delegate oauthClient:self didReceiveAccessCode:code];
    }
}

- (void)fetchOAuthAccessTokenWithParams:(NSDictionary *)accessTokenParams fromURL:(NSString *)tokenURL andMethod:(HTTPMethod)httpMethod {
    
    NSMutableURLRequest *request;
    
    switch (httpMethod) {
        case HTTPMethodGet:
        {
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", tokenURL, [accessTokenParams convertToParams]]];
            request = [[NSMutableURLRequest alloc] initWithURL:url];
        }
            break;
        case HTTPMethodPost:
        {
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.tokenURL]];
            [request setHTTPMethod:@"POST"];
            
            NSString *postString = [accessTokenParams convertToParams];
            [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        }
            break;
    }
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSLog(@"TOKEN RESPONSE: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        NSError *error;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if (error) {
            if ([self.delegate respondsToSelector:@selector(oauthClient:failedToReceiveAccessToken:)]) {
                [self.delegate oauthClient:self failedToReceiveAccessToken:error];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(oauthClient:didReceiveAccessToken:)]) {
                [self.delegate oauthClient:self didReceiveAccessToken:dictionary];
            }
        }
    }];
}

- (void)refreshTokenWithParams:(NSDictionary *)refreshTokenParams fromURL:(NSString *)tokenURL andMethod:(HTTPMethod)httpMethod {
    [self fetchOAuthAccessTokenWithParams:refreshTokenParams fromURL:tokenURL andMethod:httpMethod];
}

@end

@implementation NSDictionary (GetParamsEncoding)

- (NSString *)convertToParams {
    NSMutableArray *array = [NSMutableArray array];
    for(id key in self) {
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, [self valueForKey:key]]];
    }
    return [array componentsJoinedByString:@"&"];
}

@end