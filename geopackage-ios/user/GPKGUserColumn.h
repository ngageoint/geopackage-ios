//
//  GPKGUserColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDataTypes.h"
#import "GPKGConstraint.h"
#import "GPKGTableColumn.h"
#import "GPKGColumnConstraints.h"
#import "GPKGConstraints.h"

/**
 * User Column index value
 */
static int NO_INDEX = -1;

/**
 * Not Null Constraint Order
 */
static int NOT_NULL_CONSTRAINT_ORDER = 1;

/**
 * Default Value Constraint Order
 */
static int DEFAULT_VALUE_CONSTRAINT_ORDER = 2;

/**
 * Primary Key Constraint Order
 */
static int PRIMARY_KEY_CONSTRAINT_ORDER = 3;

/**
 * Autoincrement Constraint Order
 */
static int AUTOINCREMENT_CONSTRAINT_ORDER = 4;

/**
 * Unique Constraint Order
 */
static int UNIQUE_CONSTRAINT_ORDER = 5;

/**
 *  Metadata about a single column from a user table
 */
@interface GPKGUserColumn : NSObject <NSMutableCopying>

/**
 *  Column index
 */
@property (nonatomic) int index;

/**
 *  Column name
 */
@property (nonatomic, strong) NSString *name;

/**
 *  Max size
 */
@property (nonatomic, strong) NSNumber *max;

/**
 *  True if a not null column
 */
@property (nonatomic) BOOL notNull;

/**
 *  Default column value
 */
@property (nonatomic, strong) NSObject *defaultValue;

/**
 *  True if a primary key column
 */
@property (nonatomic) BOOL primaryKey;

/**
 *  True if primary key is autoincrement
 */
@property (nonatomic) BOOL autoincrement;

/**
 *  True if unique column
 */
@property (nonatomic) BOOL unique;

/**
 * Type
 */
@property (nonatomic, strong) NSString *type;

/**
 *  Data type
 */
@property (nonatomic) enum GPKGDataType dataType;

/**
 *  Initialize
 *
 *  @param index        index
 *  @param name         column name
 *  @param dataType     data type
 *  @param max          max size
 *  @param notNull      true if not null
 *  @param defaultValue default value
 *  @param primaryKey   ture if primary key
 *
 *  @return new user column
 */
-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                      andDataType: (enum GPKGDataType) dataType
                      andMax: (NSNumber *) max
                      andNotNull: (BOOL) notNull
                      andDefaultValue: (NSObject *) defaultValue
                      andPrimaryKey: (BOOL) primaryKey
                      andAutoincrement: (BOOL) autoincrement;

/**
 *  Initialize
 *
 *  @param index        index
 *  @param name         column name
 *  @param type         string type
 *  @param dataType     data type
 *  @param max          max size
 *  @param notNull      true if not null
 *  @param defaultValue default value
 *  @param primaryKey   ture if primary key
 *
 *  @return new user column
 */
-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                      andType: (NSString *) type
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey
                andAutoincrement: (BOOL) autoincrement;

/**
 * Initialize
 *
 * @param tableColumn
 *            table column
 */
-(instancetype) initWithTableColumn: (GPKGTableColumn *) tableColumn;

/**
 * Get the type name from the data type
 *
 * @param dataType
 *            data type
 * @param name
 *            column name
 * @return type name
 */
+(NSString *) nameOfDataType: (enum GPKGDataType) dataType forColumn: (NSString *) name;

/**
 * Check if the column has a valid index
 *
 * @return true if has a valid index
 */
-(BOOL) hasIndex;

/**
 * Set the column index. Only allowed when #hasIndex is false (
 * #getIndex is #NO_INDEX). Setting a valid index to an
 * existing valid index does nothing.
 *
 * @param index
 *            column index
 */
-(void) setIndex: (int) index;

/**
 * Reset the column index
 */
-(void) resetIndex;

/**
 * Determine if this column is named the provided name
 *
 * @param name
 *            column name
 * @return true if named the provided name
 */
-(BOOL) isNamed: (NSString *) name;

/**
 * Determine if the column has a max value
 *
 * @return true if has max value
 */
-(BOOL) hasMax;

/**
 * Determine if the column has a default value
 *
 * @return true if has default value
 */
-(BOOL) hasDefaultValue;

/**
 * Check if has constraints
 *
 * @return true if has constraints
 */
-(BOOL) hasConstraints;

/**
 * Check if has constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return true if has constraints
 */
-(BOOL) hasConstraintsOfType: (enum GPKGConstraintType) type;

/**
 * Get the constraints
 *
 * @return constraints
 */
-(GPKGConstraints *) constraints;

/**
 * Get the constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return constraints
 */
-(NSArray<GPKGConstraint *> *) constraintsOfType: (enum GPKGConstraintType) type;

/**
 * Clear the constraints
 *
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clearConstraints;

/**
 * Clear the constraints
 *
 * @param reset
 *            true to reset constraint settings
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clearConstraintsWithReset: (BOOL) reset;

/**
 * Clear the constraints of the provided type
 *
 * @param type
 *            constraint type
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clearConstraintsOfType: (enum GPKGConstraintType) type;

/**
 * Add the default constraints that are enabled (not null, default value,
 * primary key) from the column properties
 */
-(void) addDefaultConstraints;

/**
 * Add a constraint
 *
 * @param constraint
 *            constraint
 */
-(void) addConstraint: (GPKGConstraint *) constraint;

/**
 * Set the constraint order by constraint type
 *
 * @param constraint
 *            constraint
 */
-(void) setConstraintOrder: (GPKGConstraint *) constraint;

/**
 * Add a constraint
 *
 * @param constraint
 *            constraint
 */
-(void) addConstraintSql: (NSString *) constraint;

/**
 * Add a constraint
 *
 * @param type
 *            constraint type
 * @param constraint
 *            constraint
 */
-(void) addConstraintType: (enum GPKGConstraintType) type withSql: (NSString *) constraint;

/**
 * Add a constraint
 *
 * @param type
 *            constraint type
 * @param order
 *            constraint order
 * @param constraint
 *            constraint
 */
-(void) addConstraintType: (enum GPKGConstraintType) type withOrder: (NSNumber *) order andSql: (NSString *) constraint;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraintsArray: (NSArray<GPKGConstraint *> *) constraints;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraints: (GPKGConstraints *) constraints;

/**
 * Add a not null constraint
 */
-(void) addNotNullConstraint;

/**
 * Remove a not null constraint
 */
-(void) removeNotNullConstraint;

/**
 * Add a default value constraint
 *
 * @param defaultValue
 *            default value
 */
-(void) addDefaultValueConstraint: (NSObject *) defaultValue;

/**
 * Remove a default value constraint
 */
-(void) removeDefaultValueConstraint;

/**
 * Add a primary key constraint
 */
-(void) addPrimaryKeyConstraint;

/**
 * Remove a primary key constraint
 */
-(void) removePrimaryKeyConstraint;

/**
 * Add an autoincrement constraint
 */
-(void) addAutoincrementConstraint;

/**
 * Remove an autoincrement constraint
 */
-(void) removeAutoincrementConstraint;

/**
 * Add a unique constraint
 */
-(void) addUniqueConstraint;

/**
 * Remove a unique constraint
 */
-(void) removeUniqueConstraint;

/**
 * Build the SQL for the constraint
 *
 * @param constraint
 *            constraint
 * @return SQL or null
 */
-(NSString *) buildConstraintSql: (GPKGConstraint *) constraint;

@end
