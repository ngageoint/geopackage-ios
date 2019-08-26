//
//  GPKGSQLiteMasterTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Enumeration of SQLite Master table types
 */
enum GPKGSQLiteMasterType{
    GPKG_SMT_TABLE,
    GPKG_SMT_INDEX,
    GPKG_SMT_VIEW,
    GPKG_SMT_TRIGGER
};

/**
 *  SQLite Master table type names
 */
extern NSString * const GPKG_SMT_TABLE_NAME;
extern NSString * const GPKG_SMT_INDEX_NAME;
extern NSString * const GPKG_SMT_VIEW_NAME;
extern NSString * const GPKG_SMT_TRIGGER_NAME;

/**
 * SQLite Master table (sqlite_master) type column keywords
 */
@interface GPKGSQLiteMasterTypes : NSObject

/**
 *  Get the name of the SQLite Master table type
 *
 *  @param type SQLite Master table type
 *
 *  @return SQLite Master table type name
 */
+(NSString *) name: (enum GPKGSQLiteMasterType) type;

/**
 *  Get the SQLite Master table type from the SQLite Master table type name
 *
 *  @param name SQLite Master table type name
 *
 *  @return SQLite Master table type
 */
+(enum GPKGSQLiteMasterType) fromName: (NSString *) name;

@end
