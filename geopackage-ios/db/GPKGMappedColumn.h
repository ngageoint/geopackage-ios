//
//  GPKGMappedColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/22/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"

/**
 * Mapped column, to a column and potentially from a differently named column
 */
@interface GPKGMappedColumn : NSObject

/**
 * To column
 */
@property (nonatomic, strong)  NSString *toColumn;

/**
 * From column or null if the same as to column
 */
@property (nonatomic, strong)  NSString *fromColumn;

/**
 * Default to column value
 */
@property (nonatomic, strong)  NSObject *defaultValue;

/**
 * Column data type
 */
@property (nonatomic)  enum GPKGDataType dataType;

/**
 * Constant value
 */
@property (nonatomic, strong)  NSObject *constantValue;

/**
 * Where value
 */
@property (nonatomic, strong)  NSObject *whereValue;

/**
 * Where value comparison operator (=, <, etc)
 */
@property (nonatomic, strong)  NSString *whereOperator;

/**
 * Initialize
 *
 * @param toColumn
 *            to column
 *
 * @return new mapped column
 */
-(instancetype) initWithToColumn: (NSString *) toColumn;

/**
 * Initialize
 *
 * @param toColumn
 *            to column
 * @param fromColumn
 *            from column
 *
 * @return new mapped column
 */
-(instancetype) initWithToColumn: (NSString *) toColumn andFromColumn: (NSString *) fromColumn;

/**
 * Initialize
 *
 * @param toColumn
 *            to column
 * @param fromColumn
 *            from column
 * @param defaultValue
 *            default value
 * @param dataType
 *            data type
 *
 * @return new mapped column
 */
-(instancetype) initWithToColumn: (NSString *) toColumn andFromColumn: (NSString *) fromColumn andDefaultValue: (NSObject *) defaultValue andDataType: (enum GPKGDataType) dataType;

/**
 * Initialize
 *
 * @param toColumn
 *            to column
 * @param defaultValue
 *            default value
 * @param dataType
 *            data type
 *
 * @return new mapped column
 */
-(instancetype) initWithToColumn: (NSString *) toColumn andDefaultValue: (NSObject *) defaultValue andDataType: (enum GPKGDataType) dataType;

/**
 * Initialize
 *
 * @param column
 *            user column
 *
 * @return new mapped column
 */
-(instancetype) initWithUserColumn: (GPKGUserColumn *) column;

/**
 * Initialize
 *
 * @param column
 *            table column
 *
 * @return new mapped column
 */
-(instancetype) initWithTableColumn: (GPKGTableColumn *) column;

/**
 * Determine if the column has a new name
 *
 * @return true if the to and from column names are different
 */
-(BOOL) hasNewName;

/**
 * Get the from column
 *
 * @return from column
 */
-(NSString *) fromColumn;

/**
 * Check if the column has a default value
 *
 * @return true if has a default value
 */
-(BOOL) hasDefaultValue;

/**
 * Get the default value as a string
 *
 * @return default value as string
 */
-(NSString *) defaultValueAsString;

/**
 * Check if the column has a constant value
 *
 * @return true if has a constant value
 */
-(BOOL) hasConstantValue;

/**
 * Get the constant value as a string
 *
 * @return constant value as string
 */
-(NSString *) constantValueAsString;

/**
 * Check if the column has a where value
 *
 * @return true if has a where value
 */
-(BOOL) hasWhereValue;

/**
 * Get the where value as a string
 *
 * @return where value as string
 */
-(NSString *) whereValueAsString;

/**
 * Set the where value
 *
 * @param whereValue
 *            where value
 * @param whereOperator
 *            where operator
 */
-(void) setWhereValue: (NSObject *) whereValue withOperator: (NSString *) whereOperator;

/**
 * Get the where operator
 *
 * @return where operator
 */
-(NSString *) whereOperator;

@end
