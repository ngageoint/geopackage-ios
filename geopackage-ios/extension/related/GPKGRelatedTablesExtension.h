//
//  GPKGRelatedTablesExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"

extern NSString * const GPKG_EXTENSION_RELATED_TABLES_AUTHOR;
extern NSString * const GPKG_EXTENSION_RELATED_TABLES_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_RELATED_TABLES_DEFINITION;

/**
 * Related Tables extension
 */
@interface GPKGRelatedTablesExtension : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new related tables
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get the extended relations DAO
 *
 * @return extended relations DAO
 */
-(GPKGExtendedRelationsDao *) getExtendedRelationsDao;

/**
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Determine if the GeoPackage has the extension for the mapping table
 
 * @param mappingTable
 *            mapping table name
 * @return true if has extension
 */
-(BOOL) hasMappingTable: (NSString *) mappingTable;

// TODO

@end
