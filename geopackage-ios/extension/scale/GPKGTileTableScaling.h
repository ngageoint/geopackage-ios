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
 *
 *  @return new tile table scaling
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get the GeoPackage
 *
 *  @return GeoPackage
 */
-(GPKGGeoPackage *) getGeoPackage;

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

@end
