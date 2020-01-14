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
-(NSArray *) all;

/**
 *  Get all metadata names
 *
 *  @return metadata names
 */
-(NSArray *) allNames;

/**
 *  Get all metadata names sorted
 *
 *  @return sorted metadata names
 */
-(NSArray *) allNamesSorted;

/**
 *  Get metadata by name
 *
 *  @param name metadata name
 *
 *  @return metadata
 */
-(GPKGGeoPackageMetadata *) metadataByName: (NSString *) name;

/**
 *  Get metadata by id
 *
 *  @param id metadata id
 *
 *  @return metadata
 */
-(GPKGGeoPackageMetadata *) metadataById: (NSNumber *) id;

/**
 *  Get or create metadata by name
 *
 *  @param name metadata name
 *
 *  @return existing or created metadata
 */
-(GPKGGeoPackageMetadata *) metadataCreateByName: (NSString *) name;

/**
 *  Check if the metadata exists
 *
 *  @param name metadata name
 *
 *  @return true if exists
 */
-(BOOL) existsByName: (NSString *) name;

/**
 *  Get metadata where the name is like
 *
 *  @param like like argument
 *  @param column sort by column
 *
 *  @return metadata names
 */
-(NSArray *) metadataWhereNameLike: (NSString *) like sortedBy: (NSString *) column;

/**
 *  Get metadata where the name is not like
 *
 *  @param notLike not like argument
 *  @param column sort by column
 *
 *  @return metadata names
 */
-(NSArray *) metadataWhereNameNotLike: (NSString *) notLike sortedBy: (NSString *) column;

@end
