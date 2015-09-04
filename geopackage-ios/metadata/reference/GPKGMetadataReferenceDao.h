//
//  GPKGMetadataReferenceDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGMetadataReference.h"

/**
 *  Metadata Reference Data Access Object
 */
@interface GPKGMetadataReferenceDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new metadata reference dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete metadata references with foreign keys to the metadata file id
 *
 *  @param fileId file id
 *
 *  @return rows deleted
 */
-(int) deleteByMetadata: (NSNumber *) fileId;

/**
 *  Remove metadata references (by updating the field to null) with foreign
 *  keys to the metadata parent id
 *
 *  @param parentId parent id
 *
 *  @return rows updated
 */
-(int) removeMetadataParent: (NSNumber *) parentId;

/**
 *  Query by the metadata ids
 *
 *  @param fileId   file id
 *  @param parentId parent id
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByMetadata: (NSNumber *) fileId andParent: (NSNumber *) parentId;

/**
 *  Query by the metadata ids
 *
 *  @param fileId file id
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByMetadata: (NSNumber *) fileId;

/**
 *  Query by the metadata parent ids
 *
 *  @param parentId parent id
 *
 *  @return result set
 */
-(GPKGResultSet *) queryByMetadataParent: (NSNumber *) parentId;

@end
