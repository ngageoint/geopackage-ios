//
//  GPKGAttributesColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"

/**
 * Attributes column
 */
@interface GPKGAttributesColumn : GPKGUserColumn

/**
 *  Create a new primary key column
 *
 *  @param index column index
 *  @param name  column name
 *
 *  @return attributes column
 */
+(GPKGAttributesColumn *) createPrimaryKeyColumnWithIndex: (int) index
                                               andName: (NSString *) name;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return attributes column
 */
+(GPKGAttributesColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *  @param max          max value
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return attributes column
 */
+(GPKGAttributesColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type
                                      andMax: (NSNumber *) max
                                  andNotNull: (BOOL) notNull
                             andDefaultValue: (NSObject *) defaultValue;

/**
 *  Initialize
 *
 *  @param index        column index
 *  @param name         column name
 *  @param dataType     data type
 *  @param max          max value
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *  @param primaryKey   true if primary key
 *
 *  @return new attributes column
 */
-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey;

@end
