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
 *  @return tables created
 */
-(int) createTable: (NSString *) tableName;

@end
