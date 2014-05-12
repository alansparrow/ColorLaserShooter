//
//  MyiAd.h
//  IncredibleEgg
//
//  Created by Alan Sparrow on 4/30/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "iAd/ADBannerView.h"
#import "MyGAd.h"

@interface MyiAd : NSObject<ADBannerViewDelegate>

@property (nonatomic) ADBannerView *_adBannerView;
@property (nonatomic) UIView *_contentView;
@property (nonatomic) bool mIsLoaded;
@property (nonatomic) bool adBannerViewIsVisible;

-(void)showBannerView;
-(void)removeiAd ;
-(void)createAdBannerView ;
-(void)hideBannerView;

@end