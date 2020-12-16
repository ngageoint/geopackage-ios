//
//  GPKGTestGeoPackageProgress.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGTestGeoPackageProgress.h"

@implementation GPKGTestGeoPackageProgress

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.progress = 0;
        self.active = YES;
    }
    return self;
}

-(void) setMax: (int) max{
    self.maxValue = [NSNumber numberWithInt:max];
}

-(void) addProgress: (int) progress{
    self.progress += progress;
}

-(BOOL) isActive{
    return self.active && (self.maxValue == nil || self.progress < [self.maxValue intValue]);
}

-(BOOL) cleanupOnCancel{
    return NO;
}

-(void) completed{
    
}

-(void) failureWithError: (NSString *) error{
    self.error = error;
}

-(void) cancel{
    self.active = NO;
}

@end
