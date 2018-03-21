//
//  GPKGTileTableScaling.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"

extern NSString * const GPKG_EXTENSION_TILE_SCALING_AUTHOR;
extern NSString * const GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR;
extern NSString * const GPKG_PROP_EXTENSION_TILE_SCALING_DEFINITION;

@interface GPKGTileTableScaling : GPKGBaseExtension

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileMatrixSet tile matrix set
 *
 *  @return new tile table scaling
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileMatrix tile matrix
 *
 *  @return new tile table scaling
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileMatrix: (GPKGTileMatrix *) tileMatrix;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tileDao tile dao
 *
 *  @return new tile table scaling
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTileDao: (GPKGTileDao *) tileDao;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *  @param tableName table name
 *
 *  @return new tile table scaling
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) tableName;

/**
 *  Get the GeoPackage
 *
 *  @return GeoPackage
 */
-(GPKGGeoPackage *) getGeoPackage;

/**
 *  Get the table name
 *
 *  @return table name
 */
-(NSString *) getTableName;

/**
 *  Get the Tile Scaling DAO
 *
 *  @return tile scaling dao
 */
-(GPKGTileScalingDao *) getDao;

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
 * Determine if the GeoPackage has the extension
 *
 * @return true if has extension
 */
-(BOOL) has;

/**
 * Get the tile scaling
 *
 * @return tile scaling
 */
-(GPKGTileScaling *) get;

/**
 * Create the tile scaling (same as calling
 * createOrUpdate(TileScaling))
 *
 * @param tileScaling
 *            tile scaling
 */
-(void) create: (GPKGTileScaling *) tileScaling;

/**
 * Update the tile scaling (same as calling
 * createOrUpdate(TileScaling))
 *
 * @param tileScaling
 *            tile scaling
 */
-(void) update: (GPKGTileScaling *) tileScaling;

/**
 * Create or update the tile scaling
 *
 * @param tileScaling
 *            tile scaling
 */
-(void) createOrUpdate: (GPKGTileScaling *) tileScaling;

/**
 * Delete the tile table scaling for the tile table
 *
 * @return true if deleted
 */
-(BOOL) delete;

/**
 * Get the extension
 *
 * @return extensions object or null if one does not exist
 */
-(GPKGExtensions *) getExtension;

@end
