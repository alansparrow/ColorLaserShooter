//
//  ColorShooterIAPHelper.m
//  ColorShooter1
//
//  Created by Alan Sparrow on 5/13/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "ColorShooterIAPHelper.h"

@implementation ColorShooterIAPHelper

+ (ColorShooterIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static ColorShooterIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.alansparrow.colorshooter.noads",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
