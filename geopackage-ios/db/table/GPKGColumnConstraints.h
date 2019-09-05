//
//  GPKGColumnConstraints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConstraint.h"

/**
 * Column Constraints
 */
@interface GPKGColumnConstraints : NSObject

/**
 *  Column name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  Column constraints
 */
@property (nonatomic, strong) NSMutableArray<GPKGConstraint *> *constraints;

/**
 *  Initialize
 *
 *  @param name column name
 *
 *  @return new column constraints
 */
-(instancetype) initWithName: (NSString *) name;

/**
 * Add a constraint
 *
 * @param constraint
 *            constraint
 */
-(void) addConstraint: (GPKGConstraint *) constraint;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraints: (NSArray<GPKGConstraint *> *) constraints;

/**
 * Get the constraint at the index
 *
 * @param index
 *            constraint index
 * @return constraint
 */
-(GPKGConstraint *) constraintAtIndex: (int) index;

/**
 * Get the number of constraints
 *
 * @return constraints count
 */
-(int) numConstraints;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints;

/**
 * Check if there are constraints
 *
 * @return true if has constraints
 */
-(BOOL) hasConstraints;

@end
