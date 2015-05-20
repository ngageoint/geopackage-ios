//
//  GPKGMetadataReferenceDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGMetadataReference.h"

@interface GPKGMetadataReferenceDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(int) deleteByMetadata: (NSNumber *) fileId;

-(int) removeMetadataParent: (NSNumber *) parentId;

-(GPKGResultSet *) queryByMetadata: (NSNumber *) fileId andParent: (NSNumber *) parentId;

-(GPKGResultSet *) queryByMetadata: (NSNumber *) fileId;

-(GPKGResultSet *) queryByMetadataParent: (NSNumber *) parentId;

@end
