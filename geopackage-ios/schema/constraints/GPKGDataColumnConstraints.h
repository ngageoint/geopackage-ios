//
//  GPKGDataColumnConstraints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Data Column Constraints table constants
 */
extern NSString * const GPKG_DCC_TABLE_NAME;
extern NSString * const GPKG_DCC_COLUMN_CONSTRAINT_NAME;
extern NSString * const GPKG_DCC_COLUMN_CONSTRAINT_TYPE;
extern NSString * const GPKG_DCC_COLUMN_VALUE;
extern NSString * const GPKG_DCC_COLUMN_MIN;
extern NSString * const GPKG_DCC_COLUMN_MIN_IS_INCLUSIVE;
extern NSString * const GPKG_DCC_COLUMN_MAX;
extern NSString * const GPKG_DCC_COLUMN_MAX_IS_INCLUSIVE;
extern NSString * const GPKG_DCC_COLUMN_DESCRIPTION;

/**
 *  Data Column Constraint Type enumeration
 */
enum GPKGDataColumnConstraintType{
    GPKG_DCCT_RANGE,
    GPKG_DCCT_ENUM,
    GPKG_DCCT_GLOB
};

/**
 *  Data Column Constraint Type enumeration names
 */
extern NSString * const GPKG_DCCT_RANGE_NAME;
extern NSString * const GPKG_DCCT_ENUM_NAME;
extern NSString * const GPKG_DCCT_GLOB_NAME;

/**
 *  Contains data to specify restrictions on basic data type column values
 */
@interface GPKGDataColumnConstraints : NSObject

/**
 *  Case sensitive name of constraint
 */
@property (nonatomic, strong) NSString *constraintName;

/**
 *  Lowercase type name of constraint: range | enum | glob
 */
@property (nonatomic, strong) NSString *constraintType;

/**
 *  Specified case sensitive value for enum or glob or NULL for range
 *  constraint_type
 */
@property (nonatomic, strong) NSString *value;

/**
 *  Minimum value for ‘range’ or NULL for ‘enum’ or ‘glob’ constraint_type
 */
@property (nonatomic, strong) NSDecimalNumber *min;

/**
 *  0 (false) if min value is exclusive, or 1 (true) if min value is
 *  inclusive
 */
@property (nonatomic, strong) NSNumber *minIsInclusive;

/**
 *  Maximum value for ‘range’ or NULL for ‘enum’ or ‘glob’ constraint_type
 */
@property (nonatomic, strong) NSDecimalNumber *max;

/**
 *  0 (false) if max value is exclusive, or 1 (true) if max value is
 *  inclusive
 */
@property (nonatomic, strong) NSNumber *maxIsInclusive;

/**
 *  For ranges and globs, describes the constraint; for enums, describes the
 *  enum value.
 */
@property (nonatomic, strong) NSString *theDescription;

/**
 *  Get the data column constraint type
 *
 *  @return data column constraint type
 */
-(enum GPKGDataColumnConstraintType) getDataColumnConstraintType;

/**
 *  Set the constraint type
 *
 *  @param constraintType constraint type
 */
-(void) setConstraintType:(NSString *)constraintType;

/**
 *  Set the data column constraint type
 *
 *  @param constraintType data column constraint type
 */
-(void) setDataColumnConstraintType: (enum GPKGDataColumnConstraintType) constraintType;

/**
 *  Set the value
 *
 *  @param value value
 */
-(void) setValue:(NSString *)value;

/**
 *  Set the min
 *
 *  @param min min
 */
-(void) setMin:(NSDecimalNumber *)min;

/**
 *  Set the min is inclusive
 *
 *  @param minIsInclusive min is inclusive
 */
-(void) setMinIsInclusive:(NSNumber *)minIsInclusive;

/**
 *  Set the min is inclusive value
 *
 *  @param minIsInclusive min is inclusive value
 */
-(void) setMinIsInclusiveValue:(BOOL)minIsInclusive;

/**
 *  Set the max
 *
 *  @param max max
 */
-(void) setMax:(NSDecimalNumber *)max;

/**
 *  Set the max is inclusive
 *
 *  @param maxIsInclusive max is inclusive
 */
-(void) setMaxIsInclusive:(NSNumber *)maxIsInclusive;

/**
 *  Set the max is inclusive value
 *
 *  @param maxIsInclusive max is inclusive value
 */
-(void) setMaxIsInclusiveValue:(BOOL)maxIsInclusive;

@end
