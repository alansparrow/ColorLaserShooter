/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "cocos2d.h"

#import "AppDelegate.h"
#import "CCBuilderReader.h"
#import "MyiAd.h"
#import "MyGAd.h"
#import "Prefix.pch"
#import "Appirater.h"
#import "AppInfo.h"
#import "SharedObject.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // Appirater
    [Appirater setAppId:APP_ID];
    [Appirater setDaysUntilPrompt:1];
    [Appirater setUsesUntilPrompt:5];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:2];
    
    // Debug mode
    //[Appirater setDebug:YES];
    
    NSLog(@"Setup TOP or BOT");
    // setup Adv
    self.isBannerOn=false;
    
    if(IS_BANNER_ON_TOP)
    {
        self.isBannerOnTop = true;
    }
    else
    {
        self.isBannerOnTop = false;
    }
    
    // Configure Cocos2d with the options set in SpriteBuilder
    NSString* configPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"]; // TODO: add support for Published-Android support
    configPath = [configPath stringByAppendingPathComponent:@"configCocos2d.plist"];
    
    NSMutableDictionary* cocos2dSetup = [NSMutableDictionary dictionaryWithContentsOfFile:configPath];
    
    // Note: this needs to happen before configureCCFileUtils is called, because we need apportable to correctly setup the screen scale factor.
#ifdef APPORTABLE
    if([cocos2dSetup[CCSetupScreenMode] isEqual:CCScreenModeFixed])
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenAspectFitEmulationMode];
    else
        [UIScreen mainScreen].currentMode = [UIScreenMode emulatedMode:UIScreenScaledAspectFitEmulationMode];
#endif
    
    // Configure CCFileUtils to work with SpriteBuilder
    [CCBReader configureCCFileUtils];
    
    // Do any extra configuration of Cocos2d here (the example line changes the pixel format for faster rendering, but with less colors)
    //[cocos2dSetup setObject:kEAGLColorFormatRGB565 forKey:CCConfigPixelFormat];
    
    [self setupCocos2dWithOptions:cocos2dSetup];
    
    // App did launch
    [Appirater appLaunched:YES];
    
    return YES;
}

- (CCScene*) startScene
{
    return [CCBReader loadAsScene:@"GameMenuScene"];
}

-(void)showAdBanner
{
    // Show ad if this is not Pro User
    if (![SharedObject sharedObject].isProUser) {
        
        self.isBannerOn = true;
        
        //
        if(mIAd && mIAd.mIsLoaded)
        {
            NSLog(@"Show iAd");
            
            // Hide GAd
            if (mGAd) {
                [mGAd hideBannerView];
            }
            
            [mIAd showBannerView];
        }
        else
        {
            if (mGAd && mGAd.mIsLoaded) {
                NSLog(@"Show GAd because iAd failed");
                [mGAd showBannerView];
            } else {
                if (!mGAd) {
                    mGAd = [[MyGAd alloc] init];
                }
            }
            
            // Retry with iAd, so it will overlap the GAd
            // In the case it is made to nil, the GAd will appear again
            // because GAd is behind it
            if (!mIAd) {
                NSLog(@"Retry with iAd");
                mIAd = [[MyiAd alloc] init];
            }
            
        }
        
    }

}



-(void)hideAdBanner
{
    self.isBannerOn = false;
    if(mIAd)
        [mIAd hideBannerView];
    
    if (mGAd) {
        [mGAd hideBannerView];
    }
    
}

-(void)iAdBannerDidFail
{
    NSLog(@"iAdBannerDidFail");
    mIAd = nil;
    //mIAd = [[MyiAd alloc] init];
    
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert= [[UIAlertView alloc] initWithTitle: @"Simulator_ShowAlert!" message: @"didFailToReceiveAdWithError:"
                                                  delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL];
	[alert show];
#endif
}

-(void)GAdBannerDidFail
{
    NSLog(@"GAdBannerDidFail");
    mGAd = nil;
    //mGAd = [[MyGAd alloc] init];
    
#if TARGET_IPHONE_SIMULATOR
    UIAlertView* alert= [[UIAlertView alloc] initWithTitle: @"Simulator_ShowAlert!" message: @"didFailToReceiveAdWithError:"
                                                  delegate: NULL cancelButtonTitle: @"OK" otherButtonTitles: NULL];
	[alert show];
#endif
}


@end
