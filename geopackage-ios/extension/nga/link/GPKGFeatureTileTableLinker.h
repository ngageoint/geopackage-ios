//
//  GPKGFeatureTileTableLinker.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackage.h"
#import "GPKGBaseExtension.h"
#import "GPKGFeatureTileLinkDao.h"

extern NSString * const GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_FEATURE_TILE_LINK_DEFINITION;

/**
 * Feature Tile Table linker, used to link feature and tile tables
 * together when the tiles represent the feature data
 *
 * http://ngageoint.github.io/GeoPackage/docs/extensions/feature-tile-link.html
 */
@interface GPKGFeatureTileTableLinker : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new feature tile table linker
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get the Feature Tile Link DAO
 *
 *  @return feature tile link dao
 */
-(GPKGFeatureTileLinkDao *) dao;

/**
 *  Get the extension name
 *
 *  @return extension name
 */
-(NSString *) extensionName;

/**
 *  Get the extension definition
 *
 *  @return extension definition
 */
-(NSString *) extensionDefinition;

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
-(GPKGFeatureTileLink *) linkFromFeatureTable: (NSString *) featureTable andTileTable: (NSString *) tileTable;

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
 * Check if has extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 *  Get the extension
 *
 *  @return extensions object or null if one does not exist
 */
-(GPKGExtensions *) extension;

/**
 * Get a Feature Tile Link DAO
 *
 * @return feature tile link dao
 */
-(GPKGFeatureTileLinkDao *) featureTileLinkDao;

/**
 * Get a Feature Tile Link DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return feature tile link dao
 */
+(GPKGFeatureTileLinkDao *) featureTileLinkDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Feature Tile Link DAO
 *
 * @param db
 *            database connection
 * @return feature tile link dao
 */
+(GPKGFeatureTileLinkDao *) featureTileLinkDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Feature Tile Link Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createFeatureTileLinkTable;

/**
 *  Pull the the current result set feature tile link out
 *
 *  @param results result set
 *
 *  @return feature tile link
 */
-(GPKGFeatureTileLink *) linkFromResultSet: (GPKGResultSet *) results;

/**
 *  Query for the tile table names linked to a feature table
 *
 *  @param featureTable feature table
 *
 *  @return tiles tables
 */
-(NSArray<NSString *> *) tileTablesForFeatureTable: (NSString *) featureTable;

/**
 *  Query for the feature table names linked to a tile table
 *
 *  @param tileTable tile table
 *
 *  @return feature tables
 */
-(NSArray<NSString *> *) featureTablesForTileTable: (NSString *) tileTable;

/**
 *  Query for the tile tables linked to a feature table and return tile DAOs to those tables
 *
 *  @param featureTable feature table
 *
 *  @return tiles DAOs
 */
-(NSArray<GPKGTileDao *> *) tileDaosForFeatureTable: (NSString *) featureTable;

/**
 *  Query for the feature tables linked to a tile table and return feature DAOs to those tables
 *
 *  @param tileTable tile table
 *
 *  @return feature DAOs
 */
-(NSArray<GPKGFeatureDao *> *) featureDaosForTileTable: (NSString *) tileTable;

@end
