//
//  MyGAd.m
//  Box Jumping
//
//  Created by Alan Sparrow on 5/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MyGAd.h"
#import "GADBannerView.h"
#import "AppDelegate.h"

@implementation MyGAd

@synthesize adBannerViewIsVisible = _adBannerViewIsVisible, _adBannerView, _contentView, mIsLoaded;


-(id)init
{
    if(self=[super init])
    {
        mIsLoaded = false;
        _adBannerViewIsVisible = false;
        [self createAdBannerView];
        
    }
    return self;
}

- (void)createAdBannerView
{
    _adBannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait origin:CGPointMake(0, 0)];
    _adBannerView.adUnitID = @"ca-app-pub-4913787282598721/5698707694";
    _adBannerView.delegate = self;
    [_adBannerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    CGRect frame = _adBannerView.frame;
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    if (app.isBannerOnTop) {
        frame.origin.y = -(frame.size.height); //(IS_IPAD) ? -66.0f : -50.0f;
        frame.origin.x = 0.0f;
    } else {
        CGSize s1 = [UIScreen mainScreen].bounds.size;
        float y = fminf(s1.height, s1.width);
        frame.origin.y = y; //(IS_IPAD) ? -66.0f : -50.0f;
        frame.origin.x = 0.0f;
        
    }
    
    _adBannerView.rootViewController = app.navController;
    _adBannerView.frame = frame;
    [app.navController.view addSubview:_adBannerView];
    
    // Load Ads
    [_adBannerView loadRequest:[GADRequest request]];
}


- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"New GAd is loaded!");
    
    mIsLoaded = true;
    
    [self showBannerView];
}

-(void)showBannerView
{
    NSLog(@"In GAds showBannerView");
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    if (_adBannerViewIsVisible  || !(app.isBannerOn) || !mIsLoaded)
    {
        return;
    }
    
    if (_adBannerView)
    {
        _adBannerViewIsVisible = true;
        
        CGRect frame = _adBannerView.frame;
        
        if(app.isBannerOnTop)
        {
            frame.origin.x = 0.0f;
            frame.origin.y = -_adBannerView.frame.size.height;// - _adBannerView.frame.size.height;
            
        }
        else
        {
            CGSize s1 = [UIScreen mainScreen].bounds.size;
            float y = fminf(s1.height, s1.width);
            frame.origin.x = 0.0f;
            frame.origin.y = y;// - _adBannerView.frame.size.height;
        }
        
        
        _adBannerView.frame = frame;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        
        if(app.isBannerOnTop)
        {
            frame.origin.x = 0.0f;
            frame.origin.y = 0.0f;
        }
        else
        {
            CGSize s1 = [UIScreen mainScreen].bounds.size;
            float y = fminf(s1.height, s1.width);
            frame.origin.x = 0.0f;
            frame.origin.y = y - _adBannerView.frame.size.height;
        }
        
        _adBannerView.frame = frame;
        
        [UIView commitAnimations];
    }
    
}

-(void)hideBannerView
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    if (!_adBannerViewIsVisible)
    {
        return;
    }
    
    if (_adBannerView)
    {
        _adBannerViewIsVisible = false;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        
        CGRect frame = _adBannerView.frame;
        
        if(app.isBannerOnTop)
        {
            frame.origin.x = 0.0f;
            frame.origin.y = -_adBannerView.frame.size.height ;
        }
        else
        {
            CGSize s1 = [UIScreen mainScreen].bounds.size;
            float y = fminf(s1.height, s1.width);
            frame.origin.x = 0.0f;
            frame.origin.y = y;
        }
        
        _adBannerView.frame = frame;
        
        [UIView commitAnimations];
    }
    
}



- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"GAd failed");
    mIsLoaded = false;
    _adBannerViewIsVisible = false;
    
    if(_adBannerView)
    {
        [_adBannerView removeFromSuperview];
        _adBannerView = nil;
    }
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app GAdBannerDidFail];
    
}


@end
