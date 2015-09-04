//
//  GPKGMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGMetadata.h"

/**
 *  Metadata Data Access Object
 */
@interface GPKGMetadataDao : GPKGBaseDao

/**
 *  Initialize
 *
 *  @param database database connection
 *
 *  @return new metadata dao
 */
-(instancetype) initWithDatabase: (GPKGConnection *) database;

/**
 *  Delete the Metadata, cascading
 *
 *  @param metadata metadata
 *
 *  @return rows deleted
 */
-(int) deleteCascade: (GPKGMetadata *) metadata;

/**
 *  Delete the collection of Metadata, cascading
 *
 *  @param metadataCollection metadata array
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWithCollection: (NSArray *) metadataCollection;

/**
 *  Delete the Metadata where, cascading
 *
 *  @param where     where clause
 *  @param whereArgs where args
 *
 *  @return rows deleted
 */
-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

/**
 *  Delete the Metadata by id, cascading
 *
 *  @param id id
 *
 *  @return rows deleted
 */
-(int) deleteByIdCascade: (NSNumber *) id;

/**
 *  Delete the Metadata with the ids, cascading
 *
 *  @param idCollection id array
 *
 *  @return rows deleted
 */
-(int) deleteIdsCascade: (NSArray *) idCollection;

@end
