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

/**
 * User Column index value
 */
static int NO_INDEX = -1;

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
 * Type
 */
@property (nonatomic, strong) NSString *type;

/**
 *  Data type
 */
@property (nonatomic) enum GPKGDataType dataType;

/**
 * List of column constraints
 */
@property (nonatomic, strong) NSMutableArray<GPKGConstraint *> *constraints;

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
                      andPrimaryKey: (BOOL) primaryKey;

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
                andPrimaryKey: (BOOL) primaryKey;

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
 * Clear the constraints
 *
 * @return cleared constraints
 */
-(NSArray<GPKGConstraint *> *) clearConstraints;

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
 * Add a constraint
 *
 * @param constraint
 *            constraint
 */
-(void) addConstraintSql: (NSString *) constraint;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addConstraints: (NSArray<GPKGConstraint *> *) constraints;

/**
 * Add constraints
 *
 * @param constraints
 *            constraints
 */
-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints;

/**
 * Add a not null constraint
 */
-(void) addNotNullConstraint;

/**
 * Add a default value constraint
 *
 * @param defaultValue
 *            default value
 */
-(void) addDefaultValueConstraint: (NSObject *) defaultValue;

/**
 * Add a primary key constraint
 */
-(void) addPrimaryKeyConstraint;

/**
 * Add a unique constraint
 */
-(void) addUniqueConstraint;

@end
