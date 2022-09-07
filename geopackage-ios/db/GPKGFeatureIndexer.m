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
#import "SFPGeometryTransform.h"
#import "GPKGUserRowSync.h"
#import "GPKGFeatureIndexerIdQuery.h"
#import "GPKGFeatureIndexMetadataResults.h"
#import "GPKGFeatureIndexerIdResultSet.h"

@interface GPKGFeatureIndexer()

@property (nonatomic, strong)  GPKGUserRowSync *featureRowSync;
@property (nonatomic, strong)  GPKGMetadataDb *db;
@property (nonatomic, strong)  GPKGGeometryMetadataDao *geometryMetadataDataSource;

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

-(NSString *) pkColumnName{
    return [_featureDao pkColumnName];
}

-(void) close{
    
}

-(int) index{
    return [self indexWithForce:NO];
}

-(int) indexWithForce: (BOOL) force{
    int count = 0;
    if(force || ![self isIndexed]){
        count = [self indexTable];
    }
    return count;
}

-(BOOL) indexFeatureRow: (GPKGFeatureRow *) row{
    
    NSNumber *geoPackageId = [self.geometryMetadataDataSource geoPackageIdForGeoPackageName:self.featureDao.databaseName];
    BOOL indexed = [self indexWithGeoPackageId:geoPackageId andFeatureRow:row andPossibleUpdate:YES];
    
    // Update the last indexed time
    [self updateLastIndexedWithGeoPackageId:geoPackageId];
    
    return indexed;
}

-(int) indexTable{
    
    int count = 0;
    
    // Get or create the table metadata
    GPKGTableMetadataDao *tableDao = [self.db tableMetadataDao];
    GPKGTableMetadata *metadata = [tableDao metadataCreateByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
        
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
                BOOL indexed = [self indexWithGeoPackageId:geoPackageId andFeatureRow:row andPossibleUpdate:NO];
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
    
    BOOL indexed = NO;
    
    GPKGGeometryData *geomData = [row geometry];
    if(geomData != nil){
        
        // Get the envelope
        SFGeometryEnvelope *envelope = geomData.envelope;
        
        // If not envelope, build on from the geometry
        if(envelope == nil){
            SFGeometry *geometry = geomData.geometry;
            if(geometry != nil){
                envelope = [geometry envelope];
            }
        }
        
        // Create the new index row
        if(envelope != nil){
            GPKGGeometryMetadata *metadata = [self.geometryMetadataDataSource populateMetadataWithGeoPackageId:geoPackageId andTableName:self.featureDao.tableName andId:[row id] andEnvelope:envelope];
            if(possibleUpdate){
                [self.geometryMetadataDataSource createOrUpdateMetadata:metadata];
            }else{
                [self.geometryMetadataDataSource create:metadata];
            }
            indexed = YES;
        }
    }
    
    return indexed;
}

-(void) updateLastIndexedWithGeoPackageId: (NSNumber *) geoPackageId{
    
    NSDate *indexedTime = [NSDate date];
    
    GPKGTableMetadataDao *dao = [self.db tableMetadataDao];
    if(![dao updateLastIndexed:indexedTime withGeoPackageId:geoPackageId andTableName:self.featureDao.tableName]){
        [NSException raise:@"Last Indexed Time" format:@"Failed to update last indexed time. GeoPackage Id: %@, Table: %@, Last Indexed: %@", geoPackageId, self.featureDao.tableName, indexedTime];
    }

}

-(BOOL) deleteIndex{
    GPKGTableMetadataDao *tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:self.db.connection];
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
    
    BOOL indexed = NO;
    
    NSDate *lastIndexed = [self lastIndexed];
    if(lastIndexed != nil){
        GPKGGeometryColumnsDao *geometryColumnsDao = [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.featureDao.database];
        GPKGContents *contents = [geometryColumnsDao contents:self.featureDao.geometryColumns];
        NSDate *lastChange = contents.lastChange;
        indexed = [lastIndexed compare:lastChange] != NSOrderedAscending;
    }
    
    return indexed;
}

-(NSDate *) lastIndexed{
    NSDate *date = nil;
    GPKGTableMetadataDao *tableMetadataDao = [[GPKGTableMetadataDao alloc] initWithDatabase:self.db.connection];
    GPKGTableMetadata *metadata = [tableMetadataDao metadataByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
    if(metadata != nil){
        date = metadata.lastIndexed;
    }
    return date;
}

-(double) tolerance{
    return _geometryMetadataDataSource.tolerance;
}

-(void) setTolerance: (double) tolerance{
    [self.geometryMetadataDataSource setTolerance:tolerance];
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
    return [self queryFeaturesWithDistinct:NO];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithDistinct:distinct andIdQuery:idQuery];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns{
    return [self queryFeaturesWithDistinct:NO andColumns:columns];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithDistinct:distinct andColumns:columns andIdQuery:idQuery];
}

-(int) countFeatures{
    return [self countFeaturesWithDistinct:NO andColumn:nil];
}

-(int) countFeaturesWithColumn: (NSString *) column{
    return [self countFeaturesWithDistinct:NO andColumn:column];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self countWithDistinct:distinct andColumn:column andIdQuery:idQuery andWhere:nil andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithDistinct:distinct andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:nil andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:column andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countFeaturesWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:nil andWhere:where];
}

-(int) countFeaturesWithColumn: (NSString *) column andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:column andWhere:where];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:distinct andColumn:column andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andWhere:where andWhereArgs:whereArgs];
}
-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithDistinct:distinct andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:nil andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self countWithDistinct:distinct andColumn:column andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGBoundingBox *) boundingBox{
    return [self.geometryMetadataDataSource boundingBoxByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName];
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    GPKGBoundingBox *boundingBox = [self boundingBox];
    if(boundingBox != nil && projection != nil){
        SFPGeometryTransform *projectionTransform = [SFPGeometryTransform transformFromProjection:[self.featureDao projection] andToProjection:projection];
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
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope]];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countFeaturesWithDistinct:distinct andColumn:column andEnvelope:[boundingBox buildEnvelope]];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:distinct andColumn:column andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox andWhere:where];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox andWhere:where];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:boundingBox andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:distinct andColumn:column andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    GPKGResultSet *results = [self queryWithBoundingBox:featureBoundingBox];
    return results;
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    GPKGResultSet *results = [self queryWithColumns:columns andBoundingBox:featureBoundingBox];
    return results;
}

-(GPKGResultSet *) queryIdsWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    GPKGResultSet *results = [self queryIdsWithBoundingBox:featureBoundingBox];
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    int count = [self countWithBoundingBox:featureBoundingBox];
    return count;
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
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
    return [self queryFeaturesWithDistinct:NO andEnvelope:envelope];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithDistinct:distinct andIdQuery:idQuery];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andEnvelope:envelope];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithDistinct:distinct andColumns:columns andIdQuery:idQuery];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countFeaturesWithDistinct:NO andColumn:nil andEnvelope:envelope];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countFeaturesWithDistinct:NO andColumn:column andEnvelope:envelope];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:nil andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andEnvelope:envelope andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andEnvelope:envelope andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:nil andEnvelope:envelope andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:nil andEnvelope:envelope andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andEnvelope:envelope andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:nil andEnvelope:envelope andWhere:where];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:column andEnvelope:envelope andWhere:where];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:distinct andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithDistinct:distinct andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:nil andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:column andEnvelope:envelope andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self countWithDistinct:distinct andColumn:column andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

-(GPKGBoundingBox *) featureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection{
    SFPGeometryTransform *projectionTransform = [SFPGeometryTransform transformFromProjection:projection andToProjection:self.featureDao.projection];
    GPKGBoundingBox *featureBoundingBox = [boundingBox transform:projectionTransform];
    return featureBoundingBox;
}

-(GPKGGeometryMetadata *) geometryMetadataWithResultSet: (GPKGResultSet *) resultSet{
    return (GPKGGeometryMetadata *) [self.geometryMetadataDataSource object:resultSet];
}

-(NSNumber *) geometryIdWithResultSet: (GPKGResultSet *) resultSet{
    return [GPKGGeometryMetadataDao idWithResultSet:resultSet];
}

-(GPKGFeatureRow *) featureRowWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryMetadata *geometryMetadata = [self geometryMetadataWithResultSet:resultSet];
    GPKGFeatureRow *featureRow = [self featureRowWithGeometryMetadata:geometryMetadata];
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

-(GPKGResultSet *) queryFeaturesForChunkWithLimit: (int) limit{
    return [self queryFeaturesForChunkWithOrderBy:[self.featureDao pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithOrderBy:[self.featureDao pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andOrderBy:[self.featureDao pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andOrderBy:[self.featureDao pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andOrderBy:orderBy andLimit:limit andOffset:nil];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andOrderBy:orderBy andLimit:limit andOffsetValue:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andOrderBy:orderBy andLimit:limit andOffset:nil];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andOrderBy:orderBy andLimit:limit andOffsetValue:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:nil];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffsetValue:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:nil];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIds]];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffsetValue:offset];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryForChunkWithBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:NO andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:NO andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryForChunkWithColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:[boundingBox buildEnvelope] andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryForChunkWithBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (PROJProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGBoundingBox *featureBoundingBox = [self.featureDao boundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryForChunkWithEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:NO andEnvelope:envelope andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:NO andEnvelope:envelope andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryForChunkWithColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andDistinct:distinct andColumns:columns andEnvelope:envelope andOrderBy:orderBy andLimit:[NSString stringWithFormat:@"%d", limit]];
}

-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self.geometryMetadataDataSource queryByGeoPackageName:self.featureDao.databaseName andTableName:self.featureDao.tableName andDistinct:distinct andColumns:columns andEnvelope:envelope andOrderBy:orderBy andLimit:[self.featureDao buildLimitWithLimit:limit andOffset:offset]];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryFeaturesForChunkWithEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andFieldValues:fieldValues andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andFieldValues:fieldValues andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    NSString *where = [self.featureDao buildWhereWithFields:fieldValues];
    NSArray<NSString *> *whereArgs = [self.featureDao buildWhereArgsWithValues:fieldValues];
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:nil andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:NO andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryFeaturesForChunkWithDistinct:distinct andColumns:columns andEnvelope:envelope andWhere:where andWhereArgs:whereArgs andOrderBy:[self pkColumnName] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:nil];
}

-(GPKGResultSet *) queryFeaturesForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    GPKGFeatureIndexerIdQuery *idQuery = [self buildIdQueryWithResults:[self queryIdsWithEnvelope:envelope]];
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffsetValue:offset];
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
 * @param distinct distinct rows
 * @param idQuery id query
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery{
    return [self queryWithDistinct:distinct andIdQuery:idQuery andWhere:nil andWhereArgs:nil];
}

/**
 * Query using the id query
 *
 * @param distinct distinct rows
 * @param columns columns
 * @param idQuery id query
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery{
    return [self queryWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:nil andWhereArgs:nil];
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
 * @param distinct  distinct rows
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithDistinct:distinct andColumns:nil andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs];
}

/**
 * Query using the id query and criteria
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @return feature results
 */
-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGResultSet *results = nil;
    if(columns == nil){
        columns = [self.featureDao columnNames];
    }
    if([idQuery aboveMaxArgumentsWithAdditionalArgs:whereArgs]){
        results = [[GPKGFeatureIndexerIdResultSet alloc] initWithResults:[self.featureDao queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs] andIdQuery:idQuery];
    } else {
        results = [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[idQuery sql] andNestedArgs:[idQuery args] andWhere:where andWhereArgs:whereArgs];
    }
    return results;
}

/**
 * Query using the id query
 *
 * @param distinct distinct rows
 * @param idQuery  id query
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffsetValue: (int) offset{
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andOrderBy:orderBy andLimit:limit andOffset:[NSNumber numberWithInt:offset]];
}

/**
 * Query using the id query
 *
 * @param distinct distinct rows
 * @param idQuery  id query
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (NSNumber *) offset{
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andWhere:nil andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

/**
 * Query using the id query
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param idQuery  id query
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffsetValue: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andOrderBy:orderBy andLimit:limit andOffset:[NSNumber numberWithInt:offset]];
}

/**
 * Query using the id query
 *
 * @param distinct distinct rows
 * @param columns  columns
 * @param idQuery  id query
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (NSNumber *) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:nil andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

/**
 * Query using the id query and criteria
 *
 * @param distinct  distinct rows
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffsetValue: (int) offset{
    return [self queryForChunkWithDistinct:distinct andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:[NSNumber numberWithInt:offset]];
}

/**
 * Query using the id query and criteria
 *
 * @param distinct  distinct rows
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (NSNumber *) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:nil andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

/**
 * Query using the id query and criteria
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffsetValue: (int) offset{
    return [self queryForChunkWithDistinct:distinct andColumns:columns andIdQuery:idQuery andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:[NSNumber numberWithInt:offset]];
}

/**
 * Query using the id query and criteria
 *
 * @param distinct  distinct rows
 * @param columns   columns
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @param orderBy   order by
 * @param limit     chunk limit
 * @param offset    chunk query offset
 * @return feature results
 */
-(GPKGResultSet *) queryForChunkWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (NSNumber *) offset{
    GPKGResultSet *results = nil;
    if(columns == nil){
        columns = [self.featureDao columnNames];
    }
    if(orderBy == nil){
        orderBy = [self.featureDao pkColumnName];
    }
    NSString *limitValue = nil;
    if(offset == nil){
        limitValue = [NSString stringWithFormat:@"%d", limit];
    }else{
        limitValue = [self.featureDao buildLimitWithLimit:limit andOffset:[offset intValue]];
    }
    if([idQuery aboveMaxArgumentsWithAdditionalArgs:whereArgs]){
        results = [[GPKGFeatureIndexerIdResultSet alloc] initWithResults:[self.featureDao queryWithDistinct:distinct andColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limitValue] andIdQuery:idQuery];
    }else{
        results = [self.featureDao queryInForChunkWithDistinct:distinct andColumns:columns andNestedSQL:[idQuery sql] andNestedArgs:[idQuery args] andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimitValue:limitValue];
    }
    return results;
}

/**
 * Count using the id query and criteria
 *
 * @param distinct  distinct column values
 * @param column    count column name
 * @param idQuery   id query
 * @param where     where statement
 * @param whereArgs where args
 * @return feature count
 */
-(int) countWithDistinct: (BOOL) distinct andColumn: (NSString *) column andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    if([idQuery aboveMaxArgumentsWithAdditionalArgs:whereArgs]){
        if(column != nil){
            [NSException raise:@"Invalid Query" format:@"Unable to count column with too many query arguments. column: %@", column];
        }
        GPKGResultSet *results = [self.featureDao queryWhere:where andWhereArgs:whereArgs];
        @try {
            while([results moveToNext]){
                GPKGFeatureRow *featureRow = [self.featureDao row:results];
                if([idQuery hasId:[featureRow id]]){
                    count++;
                }
            }
        } @finally {
            [results close];
        }
    } else {
        count = [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[idQuery sql] andNestedArgs:[idQuery args] andWhere:where andWhereArgs:whereArgs];
    }
    return count;
}

@end
