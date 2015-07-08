//
//  GPKGProgress.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGProgress_h
#define geopackage_ios_GPKGProgress_h

@protocol GPKGProgress <NSObject>

-(void) setMax: (int) max;

-(void) addProgress: (int) progress;

-(BOOL) isActive;

-(BOOL) cleanupOnCancel;

-(void) completed;

-(void) failureWithError: (NSString *) error;

@end

#endif
