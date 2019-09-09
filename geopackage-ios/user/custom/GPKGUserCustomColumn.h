//
//  GPKGUserCustomColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"
#import "GPKGTableColumn.h"

/**
 * User Custom column
 */
@interface GPKGUserCustomColumn : GPKGUserColumn

/**
 * Create a new primary key column
 *
 * @param name
 *            name
 * @return user custom column
 */
+(GPKGUserCustomColumn *) createPrimaryKeyColumnWithName: (NSString *) name;

/**
 *  Create a new primary key column
 *
 *  @param index column index
 *  @param name  column name
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createPrimaryKeyColumnWithIndex: (int) index
                                                  andName: (NSString *) name;

/**
 * Create a new column
 *
 * @param name
 *            name
 * @param type
 *            data type
 * @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type;

/**
 * Create a new column
 *
 * @param index
 *            index
 * @param name
 *            name
 * @param type
 *            data type
 * @return user custom column
 * @since 3.3.0
 */
+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                                  andName: (NSString *) name
                                              andDataType: (enum GPKGDataType) type;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *  @param max          max value
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *  @param max          max value
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *  @param max          max value
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max
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
 *  @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue;

/**
 * Create a new column
 *
 * @param tableColumn
 *            table column
 * @return user custom column
 */
+(GPKGUserCustomColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn;

@end
