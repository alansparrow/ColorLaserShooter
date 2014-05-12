//
//  MyGAd.h
//  Box Jumping
//
//  Created by Alan Sparrow on 5/10/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerViewDelegate.h"

@interface MyGAd : NSObject <GADBannerViewDelegate>

@property (nonatomic) GADBannerView *_adBannerView;
@property (nonatomic) UIView *_contentView;
@property (nonatomic) bool mIsLoaded;
@property (nonatomic) bool adBannerViewIsVisible;

-(void)showBannerView;
-(void)createAdBannerView ;
-(void)hideBannerView;

@end
