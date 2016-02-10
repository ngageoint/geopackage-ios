//
//  GPKGFeatureTileTableLinker.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"

extern NSString * const GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR;
extern NSString * const GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_FEATURE_TILE_LINK_DEFINITION;

@interface GPKGFeatureTileTableLinker : NSObject

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new feature tile table linker
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get the GeoPackage
 *
 *  @return GeoPackage
 */
-(GPKGGeoPackage *) getGeoPackage;

/**
 *  Get the Feature Tile Link DAO
 *
 *  @return feature tile link dao
 */
-(GPKGFeatureTileLinkDao *) getDao;

/**
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) getExtensionName;

/**
 *  Get the extension definition
 *
 *  @return extension definition
 */
-(NSString *) getExtensionDefinition;

/**
 *  Link a feature and tile table together. Does nothing if already linked.
 *
 *  @param featureTable feature table
 *  @param tileTable tile table
 */
-(void) linkWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

/**
 *  Determine if the feature table is linked to the tile table
 *
 *  @param featureTable feature table
 *  @param tileTable tile table
 *
 *  @return true if linked
 */
-(BOOL) isLinkedWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

/**
 *  Get the feature and tile table link if it exists
 *
 *  @param featureTable feature table
 *  @param tileTable tile table
 *
 *  @return feature tile link
 */
-(GPKGFeatureTileLink *) getLinkWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

/**
 *  Query for feature tile links by feature table
 *
 *  @param featureTable feature table
 *
 *  @return feature tile link results
 */
-(GPKGResultSet *) queryForFeatureTable: (NSString *) featureTable;

/**
 *  Query for feature tile links by tile table
 *
 *  @param tileTable tile table
 *
 *  @return feature tile link results
 */
-(GPKGResultSet *) queryForTileTable: (NSString *) tileTable;

/**
 *  Delete the feature tile table link
 *
 *  @param featureTable feature table
 *  @param tileTable tile table
 *
 *  @return true if deleted
 */
-(BOOL) deleteLinkWithFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

/**
 *  Delete the feature tile table links for the feature or tile table
 *
 *  @param table feature or tile table
 *
 *  @return links deleted
 */
-(int) deleteLinksWithTable: (NSString *) table;

/**
 *  Get the extension
 *
 *  @return extensions object or null if one does not exist
 */
-(GPKGExtensions *) getExtension;

/**
 *  Pull the the current result set feature tile link out
 *
 *  @param results result set
 *
 *  @return feature tile link
 */
-(GPKGFeatureTileLink *) getLinkFromResultSet: (GPKGResultSet *) results;

/**
 *  Query for the tile table names linked to a feature table
 *
 *  @param featureTable feature table
 *
 *  @return tiles tables
 */
-(NSArray<NSString *> *) getTileTablesForFeatureTable: (NSString *) featureTable;

/**
 *  Query for the feature table names linked to a tile table
 *
 *  @param tileTable tile table
 *
 *  @return feature tables
 */
-(NSArray<NSString *> *) getFeatureTablesForTileTable: (NSString *) tileTable;

/**
 *  Query for the tile tables linked to a feature table and return tile DAOs to those tables
 *
 *  @param featureTable feature table
 *
 *  @return tiles DAOs
 */
-(NSArray<GPKGTileDao *> *) getTileDaosForFeatureTable: (NSString *) featureTable;

/**
 *  Query for the feature tables linked to a tile table and return feature DAOs to those tables
 *
 *  @param tileTable tile table
 *
 *  @return feature DAOs
 */
-(NSArray<GPKGFeatureDao *> *) getFeatureDaosForTileTable: (NSString *) tileTable;

@end
