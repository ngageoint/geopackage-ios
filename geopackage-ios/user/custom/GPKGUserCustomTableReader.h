//
//  GPKGUserCustomTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGUserCustomTable.h"

/**
 * Reads the metadata from an existing user custom table
 */
@interface GPKGUserCustomTableReader : GPKGUserTableReader

/**
 *  Initialize
 *
 *  @param tableName table name
 *
 *  @return new user custom table reader
 */
-(instancetype) initWithTable: (NSString *) tableName;

/**
 *  Read the user custom table with the database connection
 *
 *  @param db database connection
 *
 *  @return user custom table
 */
-(GPKGUserCustomTable *) readUserCustomTableWithConnection: (GPKGConnection *) db;

/**
 * Read the table
 *
 * @param db
 *            GeoPackage connection
 * @param tableName
 *            table name
 * @return table
 */
+(GPKGUserCustomTable *) readTableWithConnection: (GPKGConnection *) db andTableName: (NSString *) tableName;

@end
