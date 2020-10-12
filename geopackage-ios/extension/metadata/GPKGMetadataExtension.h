//
//  GPKGMetadataExtension.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGBaseExtension.h"
#import "GPKGMetadataDao.h"
#import "GPKGMetadataReferenceDao.h"

extern NSString * const GPKG_METADATA_EXTENSION_NAME;

@class GPKGMetadataReferenceDao;

/**
 *  Metadata extension
 *
 *  https://www.geopackage.org/spec/#extension_metadata
 */
@interface GPKGMetadataExtension : GPKGBaseExtension

/**
 *  Extension name
 */
@property (nonatomic, strong) NSString *extensionName;

/**
 *  Extension definition URL
 */
@property (nonatomic, strong) NSString *definition;

/**
 *  Initialize
 *
 *  @param geoPackage GeoPackage
 *
 *  @return new instance
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 *  Get or create the extension
 *
 *  @return extensions
 */
-(NSArray<GPKGExtensions *> *) extensionCreate;

/**
 *  Determine if the GeoPackage has the extension
 *
 *  @return true if has extension
 */
-(BOOL) has;

/**
 * Remove all trace of the extension
 */
-(void) removeExtension;

/**
 * Get a Metadata DAO
 *
 * @return Metadata DAO
 */
-(GPKGMetadataDao *) metadataDao;

/**
 * Get a Metadata DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return Metadata DAO
 */
+(GPKGMetadataDao *) metadataDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Metadata DAO
 *
 * @param db
 *            database connection
 * @return Metadata DAO
 */
+(GPKGMetadataDao *) metadataDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Metadata Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createMetadataTable;

/**
 * Get a Metadata Reference DAO
 *
 * @return Metadata Reference DAO
 */
-(GPKGMetadataReferenceDao *) metadataReferenceDao;

/**
 * Get a Metadata Reference DAO
 *
 * @param geoPackage
 *            GeoPackage
 * @return Metadata Reference DAO
 */
+(GPKGMetadataReferenceDao *) metadataReferenceDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Get a Metadata Reference DAO
 *
 * @param db
 *            database connection
 * @return Metadata Reference DAO
 */
+(GPKGMetadataReferenceDao *) metadataReferenceDaoWithDatabase: (GPKGConnection *) database;

/**
 * Create the Metadata Reference Table if it does not exist
 *
 * @return true if created
 */
-(BOOL) createMetadataReferenceTable;

@end
