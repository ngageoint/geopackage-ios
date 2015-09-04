//
//  GPKGGeoPackageMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGConnection.h"
#import "GPKGGeoPackageMetadata.h"

/**
 * GeoPackage Metadata Data Access Object
 */
@interface GPKGGeoPackageMetadataDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new GeoPackage metadata DAO
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete the metadata
 *
 *  @param metadata metadata
 *
 *  @return true if deleted
 */
-(BOOL) deleteMetadata: (GPKGGeoPackageMetadata *) metadata;

/**
 *  Delete metadata by name
 *
 *  @param name metadata name
 *
 *  @return true if deleted
 */
-(BOOL) deleteByName: (NSString *) name;

/**
 *  Rename metadata
 *
 *  @param metadata metadata
 *  @param newName  new metadata name
 *
 *  @return true if renamed
 */
-(BOOL) renameMetadata: (GPKGGeoPackageMetadata *) metadata toNewName: (NSString *) newName;

/**
 *  Rename metadata
 *
 *  @param name    metadata name
 *  @param newName new metadata name
 *
 *  @return true if renamed
 */
-(BOOL) renameName: (NSString *) name toNewName: (NSString *) newName;

/**
 *  Get all metadata
 *
 *  @return all metadata
 */
-(NSArray *) getAll;

/**
 *  Get all metadata names
 *
 *  @return metadata names
 */
-(NSArray *) getAllNames;

/**
 *  Get all metadata names sorted
 *
 *  @return sorted metadata names
 */
-(NSArray *) getAllNamesSorted;

/**
 *  Get metadata by name
 *
 *  @param name metadata name
 *
 *  @return metadata
 */
-(GPKGGeoPackageMetadata *) getMetadataByName: (NSString *) name;

/**
 *  Get metadata by id
 *
 *  @param id metadata id
 *
 *  @return metadata
 */
-(GPKGGeoPackageMetadata *) getMetadataById: (NSNumber *) id;

/**
 *  Get or create metadata by name
 *
 *  @param name metadata name
 *
 *  @return existing or created metadata
 */
-(GPKGGeoPackageMetadata *) getOrCreateMetadataByName: (NSString *) name;

/**
 *  Check if the metadata exists
 *
 *  @param name metadata name
 *
 *  @return true if exists
 */
-(BOOL) existsByName: (NSString *) name;

@end
