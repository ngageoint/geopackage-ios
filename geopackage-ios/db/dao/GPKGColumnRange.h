//
//  GPKGColumnRange.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/22/24.
//  Copyright © 2024 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Column Range wrapper to specify a range and additional attributes, such as a
 * tolerance for floating point numbers
 */
@interface GPKGColumnRange : NSObject

/**
 *  Min Value
 */
@property (nonatomic) NSNumber *min;

/**
 *  Max Value
 */
@property (nonatomic) NSNumber *max;

/**
 *  Value tolerance
 */
@property (nonatomic) NSNumber *tolerance;

/**
 *  Initialize
 *
 *  @param min min value
 *  @param max max value
 *  @return new column range
 */
-(instancetype) initWithMin: (NSNumber *) min andMax: (NSNumber *) max;

/**
 *  Initialize
 *
 *  @param min min value
 *  @param max max value
 *  @param tolerance tolerance
 *  @return new column value
 */
-(instancetype) initWithMin: (NSNumber *) min andMax: (NSNumber *) max andTolerance: (NSNumber *) tolerance;

@end
