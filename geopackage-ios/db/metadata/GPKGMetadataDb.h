//
//  GPKGMetadataDb.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackageMetadataDao.h"
#import "GPKGTableMetadataDao.h"
#import "GPKGGeometryMetadataDao.h"

/**
 * GeoPackage Metadata Database
 */
@interface GPKGMetadataDb : NSObject

/**
 *  Connection
 */
@property (nonatomic, strong) GPKGConnection *connection;

/**
 *  Initialize
 *
 *  @return new metadata database
 */
-(instancetype) init;

/**
 *  Close the database
 */
-(void) close;

/**
 *  Get a GeoPackage Metadata DAO
 *
 *  @return GeoPackage Metadata DAO
 */
-(GPKGGeoPackageMetadataDao *) getGeoPackageMetadataDao;

/**
 *  Get a Table Metadata DAO
 *
 *  @return Table Metadata DAO
 */
-(GPKGTableMetadataDao *) getTableMetadataDao;

/**
 *  Get a Geometry Metadata DAO
 *
 *  @return Geometry Metadata DAO
 */
-(GPKGGeometryMetadataDao *) getGeometryMetadataDao;

/**
 *  Delete the metadata database file
 *
 *  @return true if deleted
 */
+(BOOL) deleteMetadataFile;

@end
