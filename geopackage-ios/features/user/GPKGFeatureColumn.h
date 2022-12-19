//
//  GPKGFeatureColumn.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"
#import "SFGeometryTypes.h"

/**
 *  Feature column
 */
@interface GPKGFeatureColumn : GPKGUserColumn

/**
 *  Geometry type if a geometry column
 */
@property (nonatomic) enum SFGeometryType geometryType;

/**
 *  Create a new primary key column
 *
 *  @param name  column name
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createPrimaryKeyColumnWithName: (NSString *) name;

/**
 * Create a new primary key column
 *
 * @param name
 *            name
 * @param autoincrement
 *            autoincrement flag
 * @return feature column
 */
+(GPKGFeatureColumn *) createPrimaryKeyColumnWithName: (NSString *) name andAutoincrement: (BOOL) autoincrement;

/**
 *  Create a new primary key column
 *
 *  @param index column index
 *  @param name  column name
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createPrimaryKeyColumnWithIndex: (int) index
                      andName: (NSString *) name;

/**
 * Create a new primary key column
 *
 * @param index
 *            index
 * @param name
 *            name
 * @param autoincrement
 *            autoincrement flag
 * @return feature column
 */
+(GPKGFeatureColumn *) createPrimaryKeyColumnWithIndex: (int) index andName: (NSString *) name andAutoincrement: (BOOL) autoincrement;

/**
 *  Create a new geometry column
 *
 *  @param name         column name
 *  @param type         geometry type
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createGeometryColumnWithName: (NSString *) name
                                    andGeometryType: (enum SFGeometryType) type;

/**
 *  Create a new geometry column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         geometry type
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createGeometryColumnWithIndex: (int) index andName: (NSString *) name
                                    andGeometryType: (enum SFGeometryType) type;

/**
 *  Create a new geometry column
 *
 *  @param name         column name
 *  @param type         geometry type
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createGeometryColumnWithName: (NSString *) name
                                     andGeometryType: (enum SFGeometryType) type
                                          andNotNull: (BOOL) notNull
                                     andDefaultValue: (NSObject *) defaultValue;

/**
 *  Create a new geometry column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         geometry type
 *  @param notNull      not null
 *  @param defaultValue default value or nil
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createGeometryColumnWithIndex: (int) index
                      andName: (NSString *) name
                      andGeometryType: (enum SFGeometryType) type
                      andNotNull: (BOOL) notNull
                      andDefaultValue: (NSObject *) defaultValue;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type;

/**
 *  Create a new column
 *
 *  @param index        column index
 *  @param name         column name
 *  @param type         data type
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
                                     andName: (NSString *) name
                                 andDataType: (enum GPKGDataType) type;

/**
 *  Create a new column
 *
 *  @param name         column name
 *  @param type         data type
 *  @param notNull      not null
 *
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithName: (NSString *) name
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
 *  @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithIndex: (int) index
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
 * @return feature column
 */
+(GPKGFeatureColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn;

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
 *  @param autoincrement autoincrement flag
 *  @param geometryType geometry type
 *
 *  @return new feature column
 */
-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                      andDataType: (enum GPKGDataType) dataType
                      andMax: (NSNumber *) max
                      andNotNull: (BOOL) notNull
                      andDefaultValue: (NSObject *) defaultValue
                      andPrimaryKey: (BOOL) primaryKey
                      andAutoincrement: (BOOL) autoincrement
                      andGeometryType: (enum SFGeometryType) geometryType;

/**
 *  Determine if this column is a geometry
 *
 *  @return true if a geometry column
 */
-(BOOL) isGeometry;

@end
