//
//  GPKGTableMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTableMetadata.h"

@interface GPKGTableMetadataDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(BOOL) deleteMetadata: (GPKGTableMetadata *) metadata;

-(BOOL) deleteByGeoPackageName: (NSString *) name;

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId;

-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

-(BOOL) updateLastIndexed: (NSDate *) lastIndexed inMetadata: (GPKGTableMetadata *) metadata;

-(BOOL) updateLastIndexed: (NSDate *) lastIndexed withGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

-(BOOL) updateLastIndexed: (NSDate *) lastIndexed withGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

-(GPKGTableMetadata *) getMetadataByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

-(GPKGTableMetadata *) getMetadataByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

-(GPKGTableMetadata *) getOrCreateMetadataByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

-(NSNumber *) getGeoPackageIdForGeoPackageName: (NSString *) name;

@end
