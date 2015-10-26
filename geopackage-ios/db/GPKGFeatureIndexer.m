//
//  GPKGFeatureIndexer.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexer.h"
#import "GPKGMetadataDb.h"
#import "GPKGGeometryColumnsDao.h"
#import "WKBGeometryEnvelopeBuilder.h"
#import "GPKGProjectionTransform.h"

@interface GPKGFeatureIndexer()

@property (nonatomic, strong)  GPKGMetadataDb * db;
@property (nonatomic, strong)  GPKGGeometryMetadataDao * geometryMetadataDataSource;

@end

@implementation GPKGFeatureIndexer

-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self){
        self.featureDao = featureDao;
        self.db = featureDao.metadataDb;
        self.geometryMetadataDataSource = [self.db getGeometryMetadataDao];
    }
    return self;
}

-(void) close{
    
}

-(int) index{
    return [self indexWithForce:false];
}

-(int) indexWithForce: (BOOL) force{
    int count = 0;
    if(force || ![self isIndexed]){
        count = [self indexTable];
    }
    return count;
}

-(BOOL) indexFeatureRow: (GPKGFeatureRow *) row{
    
    NSNumber * geoPackageId = [self.geometryMetadataDataSource getGeoPackageIdForGeoPackageName:self.featureDao.databaseName];
    BOOL indexed = [self indexWithGeoPackageId:geoPackageId andFeatureRow:row andPossibleUpdate:true];
    
    // Update the last indexed time
    [self updateLastIndexedWithGeoPackageId:geoPackageId];
    
    return indexed;
}

-(int) indexTable{
    
    int count = 0;
    
    // Get or create the table metadata
    GPKGTableMetadataDao * tableDao = [self.db getTableMetadataDao];
    GPKGTableMetadata * metadata = [tableDao getOrCreateMetadataByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
        
    // Delete existing index rows
    [self.geometryMetadataDataSource deleteByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    
    // Autorelease to reduce memory footprint
    @autoreleasepool {
    
        // Index all features
        GPKGResultSet * results = [self.featureDao queryForAll];
        @try{
            while((self.progress == nil || [self.progress isActive]) && [results moveToNext]){
                GPKGFeatureRow * row = (GPKGFeatureRow *)[self.featureDao getObject:results];
                BOOL indexed = [self indexWithGeoPackageId:metadata.geoPackageId andFeatureRow:row andPossibleUpdate:false];
                if(indexed){
                    count++;
                }
                if(self.progress != nil){
                    [self.progress addProgress:1];
                }
            }
        }@finally{
            [results close];
        }
        
    }
    
    // Update the last indexed time
    if(self.progress == nil || [self.progress isActive]){
        [self updateLastIndexedWithGeoPackageId:metadata.geoPackageId];
    }
    
    if(self.progress != nil){
        if([self.progress isActive]){
            [self.progress completed];
        }else{
            [self.progress failureWithError:@"Operation was canceled"];
        }
    }
    
    return count;
}

-(BOOL) indexWithGeoPackageId: (NSNumber *) geoPackageId andFeatureRow: (GPKGFeatureRow *) row andPossibleUpdate: (BOOL) possibleUpdate{
    
    BOOL indexed = false;
    
    GPKGGeometryData * geomData = [row getGeometry];
    if(geomData != nil){
        
        // Get the envelope
        WKBGeometryEnvelope * envelope = geomData.envelope;
        
        // If not envelope, build on from the geometry
        if(envelope == nil){
            WKBGeometry * geometry = geomData.geometry;
            if(geometry != nil){
                envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
            }
        }
        
        // Create the new index row
        if(envelope != nil){
            GPKGGeometryMetadata * metadata = [self.geometryMetadataDataSource populateMetadataWithGeoPackageId:geoPackageId andTableName:self.featureDao.tableName andId:[row getId] andEnvelope:envelope];
            if(possibleUpdate){
                [self.geometryMetadataDataSource createOrUpdateMetadata:metadata];
            }else{
                [self.geometryMetadataDataSource create:metadata];
            }
            indexed = true;
        }
    }
    
    return indexed;
}

-(void) updateLastIndexedWithGeoPackageId: (NSNumber *) geoPackageId{
    
    NSDate * indexedTime = [NSDate date];
    
    GPKGTableMetadataDao * dao = [self.db getTableMetadataDao];
    if(![dao updateLastIndexed:indexedTime withGeoPackageId:geoPackageId andTableName:self.featureDao.tableName]){
        [NSException raise:@"Last Indexed Time" format:@"Failed to update last indexed time. GeoPackage Id: %@, Table: %@, Last Indexed: %@", geoPackageId, self.featureDao.tableName, indexedTime];
    }

}

-(BOOL) deleteIndex{
    GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:self.db.connection];
    BOOL deleted = [tableMetadataDao deleteByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    return deleted;
}

-(BOOL) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithGeomId:[row getId]];
}

-(BOOL) deleteIndexWithGeomId: (NSNumber *) geomId{
    BOOL deleted = [self.geometryMetadataDataSource deleteByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andId:geomId];
    return deleted;
}

-(BOOL) isIndexed{
    
    BOOL indexed = false;
    
    NSDate * lastIndexed = [self getLastIndexed];
    if(lastIndexed != nil){
        GPKGGeometryColumnsDao * geometryColumnsDao = [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.featureDao.database];
        GPKGContents * contents = [geometryColumnsDao getContents:self.featureDao.geometryColumns];
        NSDate * lastChange = contents.lastChange;
        indexed = [lastIndexed compare:lastChange] != NSOrderedAscending;
    }
    
    return indexed;
}

-(NSDate *) getLastIndexed{
    NSDate * date = nil;
    GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:self.db.connection];
    GPKGTableMetadata * metadata = [tableMetadataDao getMetadataByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    if(metadata != nil){
        date = metadata.lastIndexed;
    }
    return date;
}

-(GPKGResultSet *) query{
    GPKGResultSet * results = [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    return results;
}

-(int) count{
    int count = [self.geometryMetadataDataSource countByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    return count;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGResultSet * results = [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andBoundingBox:boundingBox];
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    int count = [self.geometryMetadataDataSource countByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andBoundingBox:boundingBox];
    return count;
}

-(GPKGResultSet *) queryWithEnvelope: (WKBGeometryEnvelope *) envelope{
    GPKGResultSet * results = [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andEnvelope:envelope];
    return results;
}

-(int) countWithEnvelope: (WKBGeometryEnvelope *) envelope{
    int count = [self.geometryMetadataDataSource countByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andEnvelope:envelope];
    return count;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    GPKGBoundingBox * featureBoundingBox = [self getFeatureBoundingBoxWithBoundingBox:boundingBox andProjection:projection];
    GPKGResultSet * results = [self queryWithBoundingBox:featureBoundingBox];
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    GPKGBoundingBox * featureBoundingBox = [self getFeatureBoundingBoxWithBoundingBox:boundingBox andProjection:projection];
    int count = [self countWithBoundingBox:featureBoundingBox];
    return count;
}

-(GPKGBoundingBox *) getFeatureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    GPKGProjectionTransform * projectionTransform = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:self.featureDao.projection];
    GPKGBoundingBox * featureBoundingBox = [projectionTransform transformWithBoundingBox:boundingBox];
    return featureBoundingBox;
}

-(GPKGGeometryMetadata *) getGeometryMetadataWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryMetadata * geometryMetadata = (GPKGGeometryMetadata *) [self.geometryMetadataDataSource getObject:resultSet];
    return geometryMetadata;
}

-(GPKGFeatureRow *) getFeatureRowWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryMetadata * geometryMetadata = [self getGeometryMetadataWithResultSet:resultSet];
    GPKGFeatureRow * featureRow = [self getFeatureRowWithGeometryMetadata:geometryMetadata];
    return featureRow;
}

-(GPKGFeatureRow *) getFeatureRowWithGeometryMetadata: (GPKGGeometryMetadata *) geometryMetadata{
    GPKGFeatureRow * featureRow = (GPKGFeatureRow *)[self.featureDao queryForIdObject:geometryMetadata.id];
    return featureRow;
}

@end
