//
//  PSOAuthWebViewController.m
//  PSOAuthClient
//
//  Created by Prince Shekhar Valluri on 23/04/15.
//  Copyright (c) 2015 Prince Shekhar Valluri. All rights reserved.
//

#import "PSOAuthWebViewController.h"

@interface PSOAuthWebViewController() <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *pageTitle;

@property (nonatomic) AuthCodeResponseType authResponseType;
@property (nonatomic, strong) NSString *successAuthResponseRegex;
@property (nonatomic, strong) NSString *errorAuthResponseRegex;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation PSOAuthWebViewController

- (id)      initWithRequest:(NSURLRequest *)request
            withReponseType:(AuthCodeResponseType)responseType
   successAuthResponseRegex:(NSString *)successRegex
     errorAuthResponseRegex:(NSString *)errorRegex
                   andTitle:(NSString *)title{
    self = [super init];
    if (self) {
        self.pageTitle = title;
        self.webView = [[UIWebView alloc] init];
        [self.webView loadRequest:request];
        [self.webView setDelegate:self];
        [self.view addSubview:self.webView];
        
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.activityIndicator setColor:[UIColor blackColor]];
        [self.activityIndicator startAnimating];
        
        self.authResponseType = responseType;
        self.successAuthResponseRegex = successRegex;
        self.errorAuthResponseRegex = errorRegex;
    }
    return self;
}

- (void)viewDidLoad {
    [self.webView setFrame:self.view.frame];
    
    self.navigationItem.title = self.pageTitle;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeWebViewController:)];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    
    NSLog(@"Started : %@", [webView.request.URL absoluteString]);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.navigationItem.leftBarButtonItem = nil;
    
    NSString *verifyResponseString = @"";
    switch (self.authResponseType) {
        case AuthCodeResponseTypeURL:
        {
            verifyResponseString = [webView.request.URL absoluteString];
            NSLog(@"URL : %@", verifyResponseString);
        }
            break;
        case AuthCodeResponseTypePageTitle:
        {
            verifyResponseString = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            NSLog(@"Web Page Title : %@", verifyResponseString);
        }
            break;
    }

    NSRegularExpression *successRegex = [NSRegularExpression regularExpressionWithPattern:self.successAuthResponseRegex
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
    [successRegex enumerateMatchesInString:verifyResponseString options:0 range:NSMakeRange(0, [verifyResponseString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSLog(@"Matched Success Regex: %@", [verifyResponseString substringWithRange:match.range]);
        if ([self.delegate respondsToSelector:@selector(authRequestSuccessfulWithCode:)]) {
            [self.delegate authRequestSuccessfulWithCode:[verifyResponseString substringWithRange:match.range]];
        }
    }];
    
    NSRegularExpression *errorRegex = [NSRegularExpression regularExpressionWithPattern:self.errorAuthResponseRegex
                                                                                options:NSRegularExpressionCaseInsensitive
                                                                                  error:nil];
    [errorRegex enumerateMatchesInString:verifyResponseString options:0 range:NSMakeRange(0, [verifyResponseString length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
        NSLog(@"Matched Error Regex: %@", [verifyResponseString substringWithRange:match.range]);
        if ([self.delegate respondsToSelector:@selector(authRequestUnsuccessful)]) {
            [self.delegate authRequestUnsuccessful];
        }
    }];
}

- (void)closeWebViewController:(id)sender {
    if ([self.delegate respondsToSelector:@selector(authWebViewControllerDismissed)]) {
        [self.delegate authWebViewControllerDismissed];
    }
}

@end
