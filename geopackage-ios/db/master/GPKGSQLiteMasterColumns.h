//
//  GPKGSQLiteMasterColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of SQLite Master column keywords
 */
enum GPKGSQLiteMasterColumn{
    GPKG_SMC_TYPE,
    GPKG_SMC_NAME,
    GPKG_SMC_TBL_NAME,
    GPKG_SMC_ROOTPAGE,
    GPKG_SMC_SQL
};

/**
 *  SQLite Master column keyword type names
 */
extern NSString * const GPKG_SMC_TYPE_NAME;
extern NSString * const GPKG_SMC_NAME_NAME;
extern NSString * const GPKG_SMC_TBL_NAME_NAME;
extern NSString * const GPKG_SMC_ROOTPAGE_NAME;
extern NSString * const GPKG_SMC_SQL_NAME;

/**
 * SQLite Master table (sqlite_master) column keywords
 */
@interface GPKGSQLiteMasterColumns : NSObject

/**
 *  Get the name of the SQLite Master column keyword type
 *
 *  @param type SQLite Master column keyword type
 *
 *  @return SQLite Master column keyword type name
 */
+(NSString *) name: (enum GPKGSQLiteMasterColumn) type;

/**
 *  Get the SQLite Master column keyword type from the SQLite Master column keyword type name
 *
 *  @param name SQLite Master column keyword type name
 *
 *  @return SQLite Master column keyword type
 */
+(enum GPKGSQLiteMasterColumn) fromName: (NSString *) name;

@end
