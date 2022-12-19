//
//  GPKGTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGConnection.h"

extern NSString * const GPKG_RESOURCES_TABLES;

/**
 *  Executes database scripts to create tables
 */
@interface GPKGTableCreator : NSObject

/**
 *  Database connection
 */
@property (nonatomic) GPKGConnection *db;

/**
 *  Initialize
 *
 *  @param db database connection
 *
 *  @return new table creator
 */
-(instancetype) initWithDatabase: (GPKGConnection *) db;

/**
 * Get the table creator properties name
 *
 * @return properties name or nil for base
 */
-(NSString *) properties;

/**
 *  Create the table
 *
 *  @param tableName table name
 *
 *  @return SQL statements executed
 */
-(int) createTable: (NSString *) tableName;

/**
 *  Create the table
 *
 *  @param tableName table name
 *  @param properties properties name
 *
 *  @return SQL statements executed
 */
-(int) createTable: (NSString *) tableName fromProperties: (NSString *) properties;

/**
 *  Execute the SQL statement for the property name
 *
 *  @param propertyName property name
 *
 *  @return SQL statements executed
 */
-(int) execSQLForProperty: (NSString *) propertyName;

/**
 *  Execute the SQL statement for the property name
 *
 *  @param propertyName property name
 *  @param properties properties name
 *
 *  @return SQL statements executed
 */
-(int) execSQLForProperty: (NSString *) propertyName fromProperties: (NSString *) properties;

/**
 *  Execute the SQL statements
 *
 *  @param statements SQL statements
 */
-(void) execSQLStatements: (NSArray *) statements;

/**
 * Read the SQL statements for the property name
 *
 * @param propertyName
 *            property name
 * @return statements
 */
+(NSArray<NSString *> *) readProperty: (NSString *) propertyName;

/**
 * Read the SQL statements for the property name from the properties
 *
 * @param propertyName
 *            property name
 * @param properties
 *            properties name
 * @return statements
 */
+(NSArray<NSString *> *) readProperty: (NSString *) propertyName fromProperties: (NSString *) properties;

/**
 * Read the SQL statements for the property name from the properties file
 *
 * @param propertyName
 *            property name
 * @param propertiesFile
 *            properties file
 * @return statements
 */
+(NSArray<NSString *> *) readProperty: (NSString *) propertyName fromFile: (NSString *) propertiesFile;

@end
