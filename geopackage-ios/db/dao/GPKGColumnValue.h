//
//  GPKGColumnValue.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/12/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Column Value wrapper to specify additional value attributes, such as a range
 * tolerance for floating point numbers
 */
@interface GPKGColumnValue : NSObject

/**
 *  Value
 */
@property (nonatomic, strong) NSObject *value;

/**
 *  Value tolerance
 */
@property (nonatomic) NSNumber *tolerance;

@end
