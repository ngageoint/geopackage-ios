//
//  GPKGExtensionManagement.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

@class GPKGGeoPackage;

/**
 * Extension Management for deleting and copying extensions
 */
@interface GPKGExtensionManagement : NSObject

/**
 * Initialize
 *
 * @param geoPackage
 *            GeoPackage
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the GeoPackage
 *
 * @return GeoPackage
 */
-(GPKGGeoPackage *) geoPackage;

/**
 * Get the extension author
 *
 * @return author
 */
-(NSString *) author;

/**
 * Delete all table extensions for the table
 *
 * @param table
 *            table name
 */
-(void) deleteExtensionsForTable: (NSString *) table;

/**
 * Delete all extensions including custom extension tables
 */
-(void) deleteExtensions;

/**
 * Copy all table extensions for the table
 *
 * @param table
 *            table name
 * @param newTable
 *            new table name
 */
-(void) copyExtensionsFromTable: (NSString *) table toTable: (NSString *) newTable;

@end
