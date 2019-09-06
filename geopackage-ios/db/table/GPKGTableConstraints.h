//
//  GPKGTableConstraints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConstraint.h"
#import "GPKGColumnConstraints.h"

/**
 * Table Constraints including column constraint
 */
@interface GPKGTableConstraints : NSObject

/**
 * Initialize
 */
-(instancetype) init;

/**
 * Add a table constraint
 *
 * @param constraint
 *            constraint
 */
-(void) addTableConstraint: (GPKGConstraint *) constraint;

/**
 * Add table constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addTableConstraintsInArray: (NSArray<GPKGConstraint *> *) constraints;

/**
 * Get the table constraints
 *
 * @return table constraints
 */
-(NSArray<GPKGConstraint *> *) tableConstraints;

/**
 * Get the table constraint at the index
 *
 * @param index
 *            constraint index
 * @return table constraint
 */
-(GPKGConstraint *) tableConstraintAtIndex: (int) index;

/**
 * Get the number of table constraints
 *
 * @return table constraints count
 */
-(int) numTableConstraints;

/**
 * Add a column constraint
 *
 * @param columnName
 *            column name
 * @param constraint
 *            constraint
 */
-(void) addColumnConstraint: (GPKGConstraint *) constraint forColumn: (NSString *) columnName;

/**
 * Add column constraints
 *
 * @param columnName
 *            column name
 * @param constraints
 *            constraints
 */
-(void) addColumnConstraintsInArray: (NSArray<GPKGConstraint *> *) constraints forColumn: (NSString *) columnName;

/**
 * Add column constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints;

/**
 * Add column constraints
 *
 * @param constraints
 *            column constraints
 */
-(void) addColumnConstraintsInDictionary: (NSDictionary<NSString *, GPKGColumnConstraints *> *) constraints;

/**
 * Add column constraints
 *
 * @param constraints
 *            column constraints
 */
-(void) addColumnConstraintsInArray: (NSArray<GPKGColumnConstraints *> *) constraints;

/**
 * Get the column constraints
 *
 * @return column constraints
 */
-(NSDictionary<NSString *, GPKGColumnConstraints *> *) columnConstraints;

/**
 * Get the column names with constraints
 *
 * @return column names
 */
-(NSArray<NSString *> *) columnsWithConstraints;

/**
 * Get the column constraints
 *
 * @param columnName
 *            column name
 * @return constraints
 */
-(GPKGColumnConstraints *) columnConstraintsForColumn: (NSString *) columnName;

/**
 * Get the column constraint at the index
 *
 * @param columnName
 *            column name
 * @param index
 *            constraint index
 * @return column constraint
 */
-(GPKGConstraint *) columnConstraintForColumn: (NSString *) columnName atIndex: (int) index;

/**
 * Get the number of column constraints for the column name
 *
 * @param columnName
 *            column name
 * @return column constraints count
 */
-(int) numConstraintsForColumn: (NSString *) columnName;

/**
 * Add table constraints
 *
 * @param constraints
 *            table constraints
 */
-(void) addConstraints: (GPKGTableConstraints *) constraints;

/**
 * Check if there are constraints
 *
 * @return true if has constraints
 */
-(BOOL) hasConstraints;

/**
 * Check if there are table constraints
 *
 * @return true if has table constraints
 */
-(BOOL) hasTableConstraints;

/**
 * Check if there are column constraints
 *
 * @return true if has column constraints
 */
-(BOOL) hasColumnConstraints;

/**
 * Check if there are column constraints for the column name
 *
 * @param columnName
 *            column name
 * @return true if has column constraints
 */
-(BOOL) hasConstraintsForColumn: (NSString *) columnName;

@end
