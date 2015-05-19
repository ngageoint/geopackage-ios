//
//  GPKGMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGMetadata.h"

@interface GPKGMetadataDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(int) deleteCascade: (GPKGMetadata *) metadata;

-(int) deleteCascadeWithCollection: (NSArray *) metadataCollection;

-(int) deleteCascadeWhere: (NSString *) where;

-(int) deleteByIdCascade: (NSNumber *) id;

-(int) deleteIdsCascade: (NSArray *) idCollection;

@end
