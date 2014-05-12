//
//  MyiAd.m
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "MyiAd.h"
#import "AppDelegate.h"
#import <math.h>

@implementation MyiAd

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
    _adBannerView = [[ADBannerView alloc] initWithFrame:CGRectZero];
    _adBannerView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
    _adBannerView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
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
    
    
    _adBannerView.frame = frame;
    [app.navController.view addSubview:_adBannerView];
}


#pragma mark ADBannerViewDelegate

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    NSLog(@"New adv is loaded!");
    
    mIsLoaded = true;
    
    [self showBannerView];
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"iAd failed");
    mIsLoaded = false;
    _adBannerViewIsVisible = false;
    
    if(_adBannerView)
    {
        [_adBannerView removeFromSuperview];
        _adBannerView = nil;
    }
    
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    [app iAdBannerDidFail];
}

-(void)removeiAd
{
    _adBannerViewIsVisible = false;
    
    [self dismissAdView];
    //[_adBannerView removeFromSuperview];
}


-(void)showBannerView
{
    AppDelegate * app = (((AppDelegate*) [UIApplication sharedApplication].delegate));
    
    if (_adBannerViewIsVisible  || !(app.isBannerOn) || !mIsLoaded)
    {
        return;
    }
    
    // If iAd fails, _adBannerView will be nil
    if (_adBannerView)
    {
        _adBannerViewIsVisible = true;
        
        CGSize s = [[CCDirector sharedDirector] viewSize];
        
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
    
    // If iAd fails, _adBannerView will be nil
    if (_adBannerView)
    {
        _adBannerViewIsVisible = false;
        
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        CGSize s = [[CCDirector sharedDirector] viewSize];
        
        
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


-(void)dismissAdView
{
    if (_adBannerView)
    {
        [UIView animateWithDuration:0.2
                              delay:0.1
                            options: UIViewAnimationCurveEaseOut
                         animations:^
         {
             CGSize s = [[CCDirector sharedDirector] viewSize];
             
             CGRect frame = _adBannerView.frame;
             frame.origin.y = s.height;
             frame.origin.x = 0.0f;
             _adBannerView.frame = frame;
         }
                         completion:^(BOOL finished)
         {
             [_adBannerView removeFromSuperview];
             _adBannerView.delegate = nil;
             _adBannerView = nil;
             
         }];
    }
    
}




@end
