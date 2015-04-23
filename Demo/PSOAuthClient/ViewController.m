//
//  ViewController.m
//  PSOAuthClient
//
//  Created by Prince Shekhar Valluri on 23/04/15.
//  Copyright (c) 2015 Prince Shekhar Valluri. All rights reserved.
//

#import "ViewController.h"
#import "PSOAuthClient.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface ViewController () <PSOAuthClientDelegate>

@property (nonatomic) NSInteger selectedButton; // 1 = Google, 2 = Facebook

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 50)];
    [label setText:@"PSOAuth Demo App"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont systemFontOfSize:20.0]];
    [self.view addSubview:label];
    
    UIButton *gBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 200/2, 120, 200, 50)];
    [gBtn setBackgroundColor:[UIColor orangeColor]];
    [gBtn setTitle:@"Google" forState:UIControlStateNormal];
    [gBtn addTarget:self action:@selector(googleOAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gBtn];
    
    UIButton *fBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 200/2, 200, 200, 50)];
    [fBtn setBackgroundColor:[UIColor blueColor]];
    [fBtn setTitle:@"Facebook" forState:UIControlStateNormal];
    [fBtn addTarget:self action:@selector(facebookOAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:fBtn];
}

- (void)googleOAuth {
    /****************************/
    /***  Google OAuth Demo   ***/
    /****************************/
    self.selectedButton = 1;
    
    PSOAuthClient *oauthClient = [[PSOAuthClient alloc] initWithClientID:G_CLIENT_ID
                                                            clientSecret:G_CLIENT_SECRET
                                                             redirectURL:G_REDIRECT_URL
                                                                 authURL:G_AUTH_URL
                                                                tokenURL:G_TOKEN_URL
                                                         withReponseType:AuthCodeResponseTypePageTitle
                                                successAuthResponseRegex:G_SUCCESS_REGEX
                                                  errorAuthResponseRegex:G_ERROR_REGEX
                                                                andTitle:G_PAGE_TITLE];
    oauthClient.parentViewController = self;
    oauthClient.delegate = self;
    
    NSDictionary *accessCodeParams = [NSDictionary dictionaryWithObjects:@[@"email", G_REDIRECT_URL, @"code", G_CLIENT_ID]
                                                                 forKeys:@[@"scope", @"redirect_uri", @"response_type", @"client_id"]];
    [oauthClient authenticateUsingWebViewAndParams:accessCodeParams];
}

- (void)facebookOAuth {
    /******************************/
    /***  Facebook OAuth Demo   ***/
    /******************************/
    self.selectedButton = 2;
    
    
    PSOAuthClient *oauthClient = [[PSOAuthClient alloc] initWithClientID:FB_CLIENT_ID
                                                            clientSecret:FB_CLIENT_SECRET
                                                             redirectURL:FB_REDIRECT_URL
                                                                 authURL:FB_AUTH_URL
                                                                tokenURL:FB_TOKEN_URL
                                                         withReponseType:AuthCodeResponseTypeURL
                                                successAuthResponseRegex:FB_SUCCESS_REGEX
                                                  errorAuthResponseRegex:FB_ERROR_REGEX
                                                                andTitle:FB_PAGE_TITLE];
    oauthClient.parentViewController = self;
    oauthClient.delegate = self;
    
    NSDictionary *accessCodeParams = [NSDictionary dictionaryWithObjects:@[FB_CLIENT_ID, FB_REDIRECT_URL, @"token"]
                                                                 forKeys:@[@"client_id", @"redirect_uri", @"response_type"]];
    [oauthClient authenticateUsingWebViewAndParams:accessCodeParams];
}

- (void)oauthClient:(PSOAuthClient *)client didReceiveAccessCode:(NSString *)accessCode {
    NSLog(@"GOT THE ACCESS CODE : %@", accessCode);
    
    if (self.selectedButton == 1) {
        /****************************/
        /***  Google OAuth Demo   ***/
        /****************************/
        
        NSDictionary *accessTokenParams = [NSDictionary dictionaryWithObjects:@[G_CLIENT_ID, G_CLIENT_SECRET, G_REDIRECT_URL, @"authorization_code", accessCode]
                                                                      forKeys:@[@"client_id", @"client_secret", @"redirect_uri", @"grant_type", @"code"]];
        [client fetchOAuthAccessTokenWithParams:accessTokenParams fromURL:G_TOKEN_URL andMethod:HTTPMethodPost];
    }
    else {
        /******************************/
        /***  Facebook OAuth Demo   ***/
        /******************************/
        
        // FOR FACEBOOK, THE ACCESS TOKEN YOU GET HERE IS THE FINAL TOKEN, NO NEED FOR ANY FURTHER REQUESTS
        NSLog(@"GOT THE ACCESS TOKEN : %@", accessCode);
    }
}

- (void)oauthClient:(PSOAuthClient *)client failedToReceiveAccessCode:(NSString *)error {
    NSLog(@"Failed to get Access Code"); // User could have cancelled here too
}

- (void)oauthClient:(PSOAuthClient *)client didReceiveAccessToken:(NSDictionary *)response {
    NSLog(@"GOT THE ACCESS TOKEN");
    
    // Use this response to get the access token from the dictionary
}

- (void)oauthClient:(PSOAuthClient *)client failedToReceiveAccessToken:(NSError *)error {
    NSLog(@"Failed to get the Access Token");
}

- (void)oauthClientDidCancel:(PSOAuthClient *)client {
    NSLog(@"Auth cancelled by user");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
