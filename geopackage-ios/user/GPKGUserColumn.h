//
//  GPKGUserColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDataTypes.h"

/**
 *  Metadata about a single column from a user table
 */
@interface GPKGUserColumn : NSObject

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
 *  Data type if not a geometry column
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
                      andPrimaryKey: (BOOL) primaryKey;

/**
 *  Get the database type name
 *
 *  @return type name
 */
-(NSString *) getTypeName;

@end
