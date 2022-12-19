//
//  GPKGDgiwgValidationError.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgRequirements.h"
#import "GPKGDgiwgValidationKey.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) validation error
 */
@interface GPKGDgiwgValidationError : NSObject

/**
 *  Table name
 */
@property (nonatomic, strong) NSString *table;

/**
 *  Column name
 */
@property (nonatomic, strong) NSString *column;

/**
 *  Error causing value
 */
@property (nonatomic, strong) NSString *value;

/**
 *  Constraint
 */
@property (nonatomic, strong) NSString *constraint;

/**
 * Requirement
 */
@property (nonatomic) enum GPKGDgiwgRequirement requirement;

/**
 * Row primary keys
 */
@property (nonatomic, strong) NSArray<GPKGDgiwgValidationKey *> *primaryKeys;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint value
 * @param requirement
 *            requirement
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraintValue: (NSNumber *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 */
-(instancetype) initWithTable: (NSString *) table andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement;

/**
 * Initialize
 *
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 */
-(instancetype) initWithValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement;

/**
 * Initialize
 *
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 */
-(instancetype) initWithConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKey
 *            primary key
 */
-(instancetype) initWithTable: (NSString *) table andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKey: (GPKGDgiwgValidationKey *) primaryKey;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKeys
 *            primary keys
 */
-(instancetype) initWithTable: (NSString *) table andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKey
 *            primary key
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKey: (GPKGDgiwgValidationKey *) primaryKey;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKeys
 *            primary keys
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andValue: (NSString *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKey
 *            primary key
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKey: (GPKGDgiwgValidationKey *) primaryKey;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKeys
 *            primary keys
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraint: (NSString *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKey
 *            primary key
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraintValue: (NSNumber *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKey: (GPKGDgiwgValidationKey *) primaryKey;

/**
 * Initialize
 *
 * @param table
 *            table name
 * @param column
 *            column name
 * @param value
 *            error causing value
 * @param constraint
 *            constraint or error description
 * @param requirement
 *            requirement
 * @param primaryKeys
 *            primary keys
 */
-(instancetype) initWithTable: (NSString *) table andColumn: (NSString *) column andNumber: (NSNumber *) value andConstraintValue: (NSNumber *) constraint andRequirement: (enum GPKGDgiwgRequirement) requirement andKeys: (NSArray<GPKGDgiwgValidationKey *> *) primaryKeys;

@end
