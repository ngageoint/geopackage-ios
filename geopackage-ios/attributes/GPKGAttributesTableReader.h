//
//  GPKGAttributesTableReader.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGAttributesTable.h"

/**
 * Reads the metadata from an existing attributes table
 *
 * @author osbornb
 */
@interface GPKGAttributesTableReader : GPKGUserTableReader

/**
 *  Initialize
 *
 *  @param tableName table name
 *
 *  @return new attributes table reader
 */
-(instancetype) initWithTableName: (NSString *) tableName;

/**
 *  Read the attributes table with the database connection
 *
 *  @param db database connection
 *
 *  @return attributes table
 */
-(GPKGAttributesTable *) readAttributesTableWithConnection: (GPKGConnection *) db;

@end
