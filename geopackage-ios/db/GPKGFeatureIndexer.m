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
#import "SFGeometryEnvelopeBuilder.h"
#import "SFPProjectionTransform.h"
#import "GPKGUserRowSync.h"
#import "GPKGFeatureIndexerIdQuery.h"
#import "GPKGFeatureIndexMetadataResults.h"
#import "GPKGFeatureIndexerIdResultSet.h"

@interface GPKGFeatureIndexer()

@property (nonatomic, strong)  GPKGUserRowSync * featureRowSync;
@property (nonatomic, strong)  GPKGMetadataDb * db;
@property (nonatomic, strong)  GPKGGeometryMetadataDao * geometryMetadataDataSource;

@end

@implementation GPKGFeatureIndexer

-(instancetype)initWithFeatureDao:(GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self){
        self.featureDao = featureDao;
        self.featureRowSync = [[GPKGUserRowSync alloc] init];
        self.db = featureDao.metadataDb;
        self.geometryMetadataDataSource = [self.db geometryMetadataDao];
        self.chunkLimit = 1000;
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
    
    NSNumber * geoPackageId = [self.geometryMetadataDataSource geoPackageIdForGeoPackageName:self.featureDao.databaseName];
    BOOL indexed = [self indexWithGeoPackageId:geoPackageId andFeatureRow:row andPossibleUpdate:true];
    
    // Update the last indexed time
    [self updateLastIndexedWithGeoPackageId:geoPackageId];
    
    return indexed;
}

-(int) indexTable{
    
    int count = 0;
    
    // Get or create the table metadata
    GPKGTableMetadataDao * tableDao = [self.db tableMetadataDao];
    GPKGTableMetadata * metadata = [tableDao metadataCreateByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
        
    // Delete existing index rows
    [self.geometryMetadataDataSource deleteByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    
    int offset = 0;
    int chunkCount = 0;
    
    // Index all features
    while(chunkCount >= 0){
            
        // Autorelease to reduce memory footprint
        @autoreleasepool {
            
            GPKGResultSet *results = [self.featureDao queryForChunkWithLimit:self.chunkLimit andOffset:offset];
            chunkCount = [self indexRowsWithGeoPackageId:metadata.geoPackageId andResults:results];
            
        }
        
        if(chunkCount > 0){
            count += chunkCount;
        }
        
        offset += self.chunkLimit;
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

-(int) indexRowsWithGeoPackageId: (NSNumber *) geoPackageId andResults: (GPKGResultSet *) results{
    
    int count = -1;
    
    @try {
        while((self.progress == nil || [self.progress isActive]) && [results moveToNext]){
            if(count < 0){
                count++;
            }
            @try {
                GPKGFeatureRow *row = (GPKGFeatureRow *)[self.featureDao object:results];
                BOOL indexed = [self indexWithGeoPackageId:geoPackageId andFeatureRow:row andPossibleUpdate:false];
                if(indexed){
                    count++;
                }
                if(self.progress != nil){
                    [self.progress addProgress:1];
                }
            } @catch (NSException *exception) {
                NSLog(@"Failed to index feature. Table: %@", self.featureDao.tableName);
            }
        }
    } @finally {
        [results close];
    }
    
    return count;
}

-(BOOL) indexWithGeoPackageId: (NSNumber *) geoPackageId andFeatureRow: (GPKGFeatureRow *) row andPossibleUpdate: (BOOL) possibleUpdate{
    
    BOOL indexed = false;
    
    GPKGGeometryData * geomData = [row geometry];
    if(geomData != nil){
        
        // Get the envelope
        SFGeometryEnvelope * envelope = geomData.envelope;
        
        // If not envelope, build on from the geometry
        if(envelope == nil){
            SFGeometry * geometry = geomData.geometry;
            if(geometry != nil){
                envelope = [SFGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
            }
        }
        
        // Create the new index row
        if(envelope != nil){
            GPKGGeometryMetadata * metadata = [self.geometryMetadataDataSource populateMetadataWithGeoPackageId:geoPackageId andTableName:self.featureDao.tableName andId:[row id] andEnvelope:envelope];
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
    
    GPKGTableMetadataDao * dao = [self.db tableMetadataDao];
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
    return [self deleteIndexWithGeomId:[row id]];
}

-(BOOL) deleteIndexWithGeomId: (NSNumber *) geomId{
    BOOL deleted = [self.geometryMetadataDataSource deleteByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andId:geomId];
    return deleted;
}

-(BOOL) isIndexed{
    
    BOOL indexed = false;
    
    NSDate * lastIndexed = [self lastIndexed];
    if(lastIndexed != nil){
        GPKGGeometryColumnsDao * geometryColumnsDao = [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.featureDao.database];
        GPKGContents * contents = [geometryColumnsDao contents:self.featureDao.geometryColumns];
        NSDate * lastChange = contents.lastChange;
        indexed = [lastIndexed compare:lastChange] != NSOrderedAscending;
    }
    
    return indexed;
}

-(NSDate *) lastIndexed{
    NSDate * date = nil;
    GPKGTableMetadataDao * tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:self.db.connection];
    GPKGTableMetadata * metadata = [tableMetadataDao metadataByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    if(metadata != nil){
        date = metadata.lastIndexed;
    }
    return date;
}

-(GPKGResultSet *) query{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andColumns:columns];
}

-(GPKGResultSet *) queryIds{
    return [self.geometryMetadataDataSource queryIdsByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
}

-(int) count{
    return [self.geometryMetadataDataSource countByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
}

-(GPKGResultSet *) queryFeatures{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithIdQuery:idQuery];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithColumns:columns andIdQuery:idQuery];
}

-(GPKGResultSet *) queryFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countFeaturesWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where{
    return [self queryFeaturesWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self queryFeaturesWithColumns:columns andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWhere: (NSString *) where{
    return [self countFeaturesWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self countWithIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGBoundingBox *) boundingBox{
    return [self.geometryMetadataDataSource boundingBoxByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    GPKGBoundingBox *boundingBox = [self boundingBox];
    if(boundingBox != nil && projection != nil){
        SFPProjectionTransform *projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:[self.featureDao projection] andToProjection:projection];
        boundingBox = [boundingBox transform:projectionTransform];
    }
    return boundingBox;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andBoundingBox:boundingBox];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andColumns:columns andBoundingBox:boundingBox];
}

-(GPKGResultSet *) queryIdsWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self.geometryMetadataDataSource queryIdsByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andBoundingBox:boundingBox];
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self.geometryMetadataDataSource countByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andBoundingBox:boundingBox];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithColumns:columns andEnvelope:[boundingBox buildEnvelope]];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countFeaturesWithEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithColumns:columns andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryFeaturesWithBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryFeaturesWithColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countFeaturesWithBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithColumns:columns andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    GPKGResultSet *results = [self queryWithBoundingBox:featureBoundingBox];
    return results;
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    GPKGResultSet *results = [self queryWithColumns:columns andBoundingBox:featureBoundingBox];
    return results;
}

-(GPKGResultSet *) queryIdsWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    GPKGResultSet *results = [self queryIdsWithBoundingBox:featureBoundingBox];
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    int count = [self countWithBoundingBox:featureBoundingBox];
    return count;
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithColumns:columns andBoundingBox:featureBoundingBox];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andEnvelope:envelope];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andColumns:columns andEnvelope:envelope];
}

-(GPKGResultSet *) queryIdsWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.geometryMetadataDataSource queryIdsByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andEnvelope:envelope];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.geometryMetadataDataSource countByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andEnvelope:envelope];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithIdQuery:idQuery];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithColumns:columns andIdQuery:idQuery];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self countWithIdQuery:idQuery];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countFeaturesWithEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryFeaturesWithEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryFeaturesWithColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self countFeaturesWithEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self countWithIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGBoundingBox *) featureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    SFPProjectionTransform * projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:self.featureDao.projection];
    GPKGBoundingBox * featureBoundingBox = [boundingBox transform:projectionTransform];
    return featureBoundingBox;
}

-(GPKGGeometryMetadata *) geometryMetadataWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryMetadata * geometryMetadata = (GPKGGeometryMetadata *) [self.geometryMetadataDataSource object:resultSet];
    return geometryMetadata;
}

-(NSNumber *) geometryIdWithResultSet: (GPKGResultSet *) resultSet{
    return [GPKGGeometryMetadataDao idWithResultSet:resultSet];
}

-(GPKGFeatureRow *) featureRowWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryMetadata * geometryMetadata = [self geometryMetadataWithResultSet:resultSet];
    GPKGFeatureRow * featureRow = [self featureRowWithGeometryMetadata:geometryMetadata];
    return featureRow;
}

-(GPKGFeatureRow *) featureRowWithGeometryMetadata: (GPKGGeometryMetadata *) geometryMetadata{
    
    NSNumber *geomId = geometryMetadata.id;
    
    // Get the row or lock for reading
    GPKGFeatureRow *row = (GPKGFeatureRow *)[self.featureRowSync rowOrLockNumber:geomId];
    if(row == nil){
        // Query for the row and set in the sync
        @try {
            row = (GPKGFeatureRow *)[self.featureDao queryForIdObject:geomId];
        } @finally {
            [self.featureRowSync setRow:row withNumber:geomId];
        }
    }

    return row;
}

-(double) tolerance{
    return _geometryMetadataDataSource.tolerance;
}

-(void) setTolerance: (double) tolerance{
    [self.geometryMetadataDataSource setTolerance:tolerance];
}

/**
 * Build a feature indexer nested id query from the results
 *
 * @param results results
 * @return id query
 */
-(GPKGFeatureIndexerIdQuery *) buildIdQueryWithResults: (GPKGResultSet *) results{
    GPKGFeatureIndexerIdQuery *query = nil;
    GPKGFeatureIndexMetadataResults *metadataResults = [[GPKGFeatureIndexMetadataResults alloc] initWithFeatureTableIndex:self andResults:results];
    @try {
        query = [[GPKGFeatureIndexerIdQuery alloc] init];
        while([metadataResults moveToNext]){
            [query addArgument:[metadataResults featureId]];
        }
    } @finally {
        [metadataResults close];
    }
    return query;
}

/**
 * Query using the id query
 *
 * @param idQuery id query
 * @return feature results
 */
-(GPKGResultSet *) queryWithIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery{
    return [self queryWithIdQuery:idQuery andWhere:nil andWhereArgs:nil];
}

/**
 * Query using the id query
 *
 * @param columns columns
 * @param idQuery id query
 * @return feature results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery{
    return [self queryWithColumns:columns andIdQuery:idQuery andWhere:nil andWhereArgs:nil];
}

/**
 * Count using the id query
 *
 * @param idQuery id query
 * @return feature count
 */
-(int) countWithIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery{
    return [idQuery count];
}

/**
 * Query using the id query and criteria
 *
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @return feature results
 */
-(GPKGResultSet *) queryWithIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *)
whereArgs{
    GPKGResultSet *results = nil;
    if([idQuery aboveMaxArgumentsWithAdditionalArgs:whereArgs]){
        results = [[GPKGFeatureIndexerIdResultSet alloc] initWithResults:[self.featureDao queryWhere:where andWhereArgs:whereArgs] andIdQuery:idQuery];
    } else {
        results = [self.featureDao queryInWithNestedSQL:[idQuery sql] andNestedArgs:[idQuery args] andWhere:where andWhereArgs:whereArgs];
    }
    return results;
}

/**
 * Query using the id query and criteria
 *
 * @param columns   columns
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @return feature results
 */
-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGResultSet *results = nil;
    if([idQuery aboveMaxArgumentsWithAdditionalArgs:whereArgs]){
        results = [[GPKGFeatureIndexerIdResultSet alloc] initWithResults:[self.featureDao queryWhere:where andWhereArgs:whereArgs] andIdQuery:idQuery];
    } else {
        results = [self.featureDao queryInWithColumns:columns andNestedSQL:[idQuery sql] andNestedArgs:[idQuery args] andWhere:where andWhereArgs:whereArgs];
    }
    return results;
}

/**
 * Count using the id query and criteria
 *
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @return feature count
 */
-(int) countWithIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *)
whereArgs{
    int count = 0;
    if([idQuery aboveMaxArgumentsWithAdditionalArgs:whereArgs]){
        GPKGResultSet *results = [self.featureDao queryWhere:where andWhereArgs:whereArgs];
        @try {
            while([results moveToNext]){
                GPKGFeatureRow *featureRow = [self.featureDao featureRow:results];
                if([idQuery hasId:[featureRow id]]){
                    count++;
                }
            }
        } @finally {
            [results close];
        }
    } else {
        count = [self.featureDao countInWithNestedSQL:[idQuery sql] andNestedArgs:[idQuery args] andWhere:where andWhereArgs:whereArgs];
    }
    return count;
}

@end
