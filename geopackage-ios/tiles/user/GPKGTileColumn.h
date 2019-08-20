//
//  GPKGTileColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"
#import "GPKGTableColumn.h"

/**
 *  Tile column
 */
@interface GPKGTileColumn : GPKGUserColumn

/**
 *  Create an id column
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createIdColumn;

/**
 *  Create an id column
 *
 *  @param index column index
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createIdColumn: (int) index;

/**
 *  Create a zoom level column
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createZoomLevelColumn;

/**
 *  Create a zoom level column
 *
 *  @param index column index
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createZoomLevelColumn: (int) index;

/**
 *  Create a tile column column
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createTileColumnColumn;

/**
 *  Create a tile column column
 *
 *  @param index column index
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createTileColumnColumn: (int) index;

/**
 *  Create a tile row column
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createTileRowColumn;

/**
 *  Create a tile row column
 *
 *  @param index column index
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createTileRowColumn: (int) index;

/**
 *  Create a tile data column
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createTileDataColumn;

/**
 *  Create a tile data column
 *
 *  @param index column index
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createTileDataColumn: (int) index;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithName: (NSString *) name
                              andDataType: (enum GPKGDataType) type;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithIndex: (int) index
                                  andName: (NSString *) name
                              andDataType: (enum GPKGDataType) type;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithName: (NSString *) name
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithIndex: (int) index
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithName: (NSString *) name
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithIndex: (int) index
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithName: (NSString *) name
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithIndex: (int) index
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithName: (NSString *) name
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
 *  @return tile column
 */
+(GPKGTileColumn *) createColumnWithIndex: (int) index
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
 * @return tile column
 */
+(GPKGTileColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn;

/**
 *  Intialize
 *
 *  @param index        column index
 *  @param name         column name
 *  @param dataType     data type
 *  @param max          max value
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *  @param primaryKey   true if a primary key
 *
 *  @return new tile column
 */
-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey;

@end
