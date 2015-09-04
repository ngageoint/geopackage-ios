//
//  GPKGProgress.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/17/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGProgress_h
#define geopackage_ios_GPKGProgress_h

/**
 *  GeoPackage Progress protocol for receiving progress information callbacks and handling cancellations
 */
@protocol GPKGProgress <NSObject>

/**
 *  Set the max progress value
 *
 *  @param max max value
 */
-(void) setMax: (int) max;

/**
 *  Add to the total progress
 *
 *  @param progress progress made
 */
-(void) addProgress: (int) progress;

/**
 *  Is the process still active?
 *
 *  @return true if active, false if cancelled
 */
-(BOOL) isActive;

/**
 *  Should the progress so far be deleted when cancelled (isActive becomes false)
 *
 *  @return true to cleanup progress made, false to preserve progress
 */
-(BOOL) cleanupOnCancel;

/**
 *  Called when progress is completed
 */
-(void) completed;

/**
 *  Called when the process stops due to an error
 *
 *  @param error error
 */
-(void) failureWithError: (NSString *) error;

@end

#endif
