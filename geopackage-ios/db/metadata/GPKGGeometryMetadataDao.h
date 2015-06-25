//
//  GPKGGeometryMetadataDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGGeometryMetadata.h"
#import "WKBGeometryEnvelope.h"
#import "GPKGBoundingBox.h"

@interface GPKGGeometryMetadataDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(GPKGGeometryMetadata *) createMetadataWithGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (WKBGeometryEnvelope *) envelope;

-(GPKGGeometryMetadata *) createMetadataWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (WKBGeometryEnvelope *) envelope;

-(GPKGGeometryMetadata *) populateMetadataWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (WKBGeometryEnvelope *) envelope;

-(BOOL) deleteMetadata: (GPKGGeometryMetadata *) metadata;

-(BOOL) deleteByGeoPackageName: (NSString *) name;

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId;

-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName;

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName andId: (NSNumber *) geomId;

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId;

-(BOOL) createOrUpdateMetadata: (GPKGGeometryMetadata *) metadata;

-(BOOL) updateMetadata: (GPKGGeometryMetadata *) metadata;

-(BOOL) existsByMetadata: (GPKGGeometryMetadata *) metadata;

-(GPKGGeometryMetadata *) getMetadataByMetadata: (GPKGGeometryMetadata *) metadata;

-(GPKGGeometryMetadata *) getMetadataByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andId: (NSNumber *) id;

-(GPKGGeometryMetadata *) getMetadataByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) id;

-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName;

-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName;

-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox;

-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andEnvelope: (WKBGeometryEnvelope *) envelope;

-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andEnvelope: (WKBGeometryEnvelope *) envelope;

-(NSNumber *) getGeoPackageIdForGeoPackageName: (NSString *) name;

@end
