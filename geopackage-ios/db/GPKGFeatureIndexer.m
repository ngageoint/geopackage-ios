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

@implementation GPKGFeatureIndexer

-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self){
        self.featureDao = featureDao;
    }
    return self;
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

-(void) indexFeatureRow: (GPKGFeatureRow *) row{
    
    GPKGMetadataDb * db = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGGeometryMetadataDao * geomDao = [db getGeometryMetadataDao];
        NSNumber * geoPackageId = [geomDao getGeoPackageIdForGeoPackageName:self.featureDao.databaseName];
        [self indexWithDataSource:geomDao andGeoPackageId:geoPackageId andFeatureRow:row andPossibleUpdate:true];
        
        // Update the last indexed time
        [self updateLastIndexedWithDatabase:db andGeoPackageId:geoPackageId];
    }@finally{
        [db close];
    }
}

-(int) indexTable{
    
    int count = 0;
    
    GPKGMetadataDb * db = [[GPKGMetadataDb alloc] init];
    @try{
        // Get or create the table metadata
        GPKGTableMetadataDao * tableDao = [db getTableMetadataDao];
        GPKGTableMetadata * metadata = [tableDao getOrCreateMetadataByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
        
        // Delete existing index rows
        GPKGGeometryMetadataDao * geomDao = [db getGeometryMetadataDao];
        [geomDao deleteByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
        
        // Index all features
        GPKGResultSet * results = [self.featureDao queryForAll];
        @try{
            while((self.progress == nil || [self.progress isActive]) && [results moveToNext]){
                count++;
                GPKGFeatureRow * row = (GPKGFeatureRow *)[self.featureDao getObject:results];
                [self indexWithDataSource:geomDao andGeoPackageId:metadata.geoPackageId andFeatureRow:row andPossibleUpdate:false];
                if(self.progress != nil){
                    [self.progress addProgress:1];
                }
            }
        }@finally{
            [results close];
        }
        
        // Update the last indexed time
        if(self.progress == nil || [self.progress isActive]){
            [self updateLastIndexedWithDatabase:db andGeoPackageId:metadata.geoPackageId];
        }
    }@finally{
        [db close];
    }
    
    if(self.progress == nil || [self.progress isActive]){
        [self.progress completed];
    }else{
        [self.progress failureWithError:@"Operation was canceled"];
    }
    
    return count;
}

-(void) indexWithDataSource: (GPKGGeometryMetadataDao *) geomDao andGeoPackageId: (NSNumber *) geoPackageId andFeatureRow: (GPKGFeatureRow *) row andPossibleUpdate: (BOOL) possibleUpdate{
    
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
        
        // Create teh new index row
        if(envelope != nil){
            GPKGGeometryMetadata * metadata = [geomDao populateMetadataWithGeoPackageId:geoPackageId andTableName:self.featureDao.tableName andId:[row getId] andEnvelope:envelope];
            if(possibleUpdate){
                [geomDao createOrUpdateMetadata:metadata];
            }else{
                [geomDao create:metadata];
            }
        }
    }
}

-(void) updateLastIndexedWithDatabase: (GPKGMetadataDb *) db andGeoPackageId: (NSNumber *) geoPackageId{
    
    NSDate * indexedTime = [NSDate date];
    
    GPKGTableMetadataDao * dao = [db getTableMetadataDao];
    if(![dao updateLastIndexed:indexedTime withGeoPackageId:geoPackageId andTableName:self.featureDao.tableName]){
        [NSException raise:@"Last Indexed Time" format:@"Failed to update last indexed time. GeoPackage Id: %@, Table: %@, Last Indexed: %@", geoPackageId, self.featureDao.tableName, indexedTime];
    }

}

-(BOOL) isIndexed{
    
    BOOL indexed = false;
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.featureDao.database];
    GPKGContents * contents = [geometryColumnsDao getContents:self.featureDao.geometryColumns];
    NSDate * lastChange = contents.lastChange;
    
    GPKGMetadataDb * db = [[GPKGMetadataDb alloc] init];
    @try{
        GPKGTableMetadataDao * dao = [db getTableMetadataDao];
        GPKGTableMetadata * metadata = [dao getMetadataByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
        if(metadata != nil){
            NSDate * lastIndexed = metadata.lastIndexed;
            indexed = lastIndexed != nil && [lastIndexed compare:lastChange] != NSOrderedAscending;
        }
    }@finally{
        [db close];
    }
    
    return indexed;
}

@end
