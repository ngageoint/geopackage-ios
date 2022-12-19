//
//  GPKGConstraints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGConstraint.h"

/**
 * User table or column constraints
 */
@interface GPKGConstraints : NSObject <NSMutableCopying>

/**
 *  Initialize
 *
 *  @return new constraints
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param constraints constraints
 *
 *  @return new constraints
 */
-(instancetype) initWithConstraints: (GPKGConstraints *) constraints;

/**
 * Add constraint
 *
 * @param constraint
 *            constraint
 */
-(void) add: (GPKGConstraint *) constraint;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addArray: (NSArray<GPKGConstraint *> *) constraints;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraints: (GPKGConstraints *) constraints;

/**
 * Check if has constraints
 *
 * @return true if has constraints
 */
-(BOOL) has;

/**
 * Check if has constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return true if has constraints
 */
-(BOOL) hasType: (enum GPKGConstraintType) type;

/**
 * Get the number of constraints
 *
 * @return size
 */
-(int) size;

/**
 * Get the number of constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return size
 */
-(int) sizeOfType: (enum GPKGConstraintType) type;

/**
 * Get the constraints
 *
 * @return constraints
 */
-(NSArray<GPKGConstraint *> *) all;

/**
 * Get the constraint at the index
 *
 * @param index
 *            constraint index
 * @return constraint
 */
-(GPKGConstraint *) atIndex: (int) index;

/**
 * Get the constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return constraints
 */
-(NSArray<GPKGConstraint *> *) ofType: (enum GPKGConstraintType) type;

/**
 * Clear the constraints
 *
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clear;

/**
 * Clear the constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clearType: (enum GPKGConstraintType) type;

@end
