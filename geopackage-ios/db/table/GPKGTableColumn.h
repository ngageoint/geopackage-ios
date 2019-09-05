//
//  GPKGTableColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/20/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGDataTypes.h"

/**
 * Table Column from Table Info
 */
@interface GPKGTableColumn : NSObject

/**
 * Initialize
 *
 * @param index
 *            column index
 * @param name
 *            column name
 * @param type
 *            column type
 * @param dataType
 *            column data type
 * @param max
 *            max value
 * @param notNull
 *            not null flag
 * @param defaultValueString
 *            default value as a string
 * @param defaultValue
 *            default value
 * @param primaryKey
 *            primary key flag
 */
-(instancetype) initWithIndex: (int) index andName: (NSString *) name andType: (NSString *) type andDataType: (enum GPKGDataType) dataType andMax: (NSNumber *) max andNotNull: (BOOL) notNull andDefaultValueString: (NSString *) defaultValueString andDefaultValue: (NSObject *) defaultValue andPrimaryKey: (BOOL) primaryKey;

/**
 * Get the column index
 *
 * @return column index
 */
-(int) index;

/**
 * Get the column name
 *
 * @return column name
 */
-(NSString *) name;

/**
 * Get the column type
 *
 * @return column type
 */
-(NSString *) type;

/**
 * Get the column data type
 *
 * @return column data type, may be null
 */
-(enum GPKGDataType) dataType;

/**
 * Is the column the data type
 *
 * @param dataType
 *            data type
 * @return true if the data type
 */
-(BOOL) isDataType: (enum GPKGDataType) dataType;

/**
 * Get the column max value
 *
 * @return max value or null if no max
 */
-(NSNumber *) max;

/**
 * Is this a not null column?
 *
 * @return true if not nullable
 */
-(BOOL) notNull;

/**
 * Get the default value as a string
 *
 * @return default value as a string
 */
-(NSString *) defaultValueString;

/**
 * Get the default value
 *
 * @return default value
 */
-(NSObject *) defaultValue;

/**
 * Is this a primary key column?
 *
 * @return true if primary key column
 */
-(BOOL) primaryKey;

@end
