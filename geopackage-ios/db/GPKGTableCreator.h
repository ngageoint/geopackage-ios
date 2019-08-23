//
//  GPKGTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGUserTable.h"

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
-(instancetype)initWithDatabase:(GPKGConnection *) db;

/**
 *  Create the table
 *
 *  @param tableName table name
 *
 *  @return SQL statements executed
 */
-(int) createTable: (NSString *) tableName;

/**
 *  Execute the SQL script with the property name
 *
 *  @param propertyName property name
 *
 *  @return SQL statements executed
 */
-(int) execSQLScript: (NSString *) propertyName;

/**
 *  Execute the SQL statements
 *
 *  @param statements SQL statements
 */
-(void) execSQLStatements: (NSArray *) statements;

/**
 * Read the SQL Script and parse the statements
 *
 * @param name
 *            table or property name
 * @return statements
 */
-(NSArray<NSString *> *) readSQLScript: (NSString *) name;

@end
