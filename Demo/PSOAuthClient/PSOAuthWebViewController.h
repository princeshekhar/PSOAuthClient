//
//  PSOAuthWebViewController.h
//  PSOAuthClient
//
//  Created by Prince Shekhar Valluri on 23/04/15.
//  Copyright (c) 2015 Prince Shekhar Valluri. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSOAuthClient.h"

@protocol PSOAuthWebViewControllerDelegate <NSObject>

- (void)authWebViewControllerDismissed;
- (void)authRequestSuccessfulWithCode:(NSString *)code;
- (void)authRequestUnsuccessful;

@end

@interface PSOAuthWebViewController : UIViewController

@property (nonatomic, strong) id<PSOAuthWebViewControllerDelegate> delegate;

- (id)      initWithRequest:(NSURLRequest *)request
            withReponseType:(AuthCodeResponseType)responseType
   successAuthResponseRegex:(NSString *)successRegex
     errorAuthResponseRegex:(NSString *)errorRegex
                   andTitle:(NSString *)title;

@end
