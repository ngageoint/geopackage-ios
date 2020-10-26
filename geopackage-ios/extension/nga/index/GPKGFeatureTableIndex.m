//
//  GPKGFeatureTableIndex.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTableIndex.h"
#import "GPKGProperties.h"
#import "SFPProjectionTransform.h"
#import "GPKGUserRowSync.h"
#import "GPKGSqlLiteQueryBuilder.h"
#import "GPKGGeometryIndexTableCreator.h"
#import "GPKGNGAExtensions.h"

NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR = @"geometry_index";
NSString * const GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION = @"geopackage.extensions.geometry_index";

@interface GPKGFeatureTableIndex ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong)  GPKGUserRowSync *featureRowSync;
@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) GPKGTableIndexDao *tableIndexDao;
@property (nonatomic, strong) GPKGGeometryIndexDao *geometryIndexDao;

@end

@implementation GPKGFeatureTableIndex

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.featureDao = featureDao;
        self.featureRowSync = [[GPKGUserRowSync alloc] init];
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_NGA_EXTENSION_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties valueOfProperty:GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION];
        self.tableName = featureDao.tableName;
        self.columnName = [featureDao geometryColumnName];
        self.tableIndexDao = [self tableIndexDao];
        self.geometryIndexDao = [self geometryIndexDao];
        self.chunkLimit = 1000;
        self.tolerance = .00000000000001;
    }
    return self;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(NSString *) extensionName{
    return _extensionName;
}

-(NSString *) extensionDefinition{
    return _extensionDefinition;
}

-(SFPProjection *) projection{
    return _featureDao.projection;
}

-(NSString *) tableName{
    return _tableName;
}

-(NSString *) columnName{
    return _columnName;
}

-(void) close{
    // Don't close anything, leave the GeoPackage connection open
}

-(int) index{
    return [self indexWithForce:NO];
}

-(int) indexWithForce: (BOOL) force{
    int count = 0;
    if(force || ![self isIndexed]){
        [self extensionCreate];
        GPKGTableIndex *tableIndex = [self tableIndexCreate];
        [self createOrClearGeometryIndices];
        [self unindexGeometryIndexTable];
        count = [self indexTable:tableIndex];
        [self indexGeometryIndexTable];
    }
    return count;
}

-(int) indexTable: (GPKGTableIndex *) tableIndex{
    
    int count = 0;
    
    int offset = 0;
    int chunkCount = 0;
    
    NSArray<NSString *> *columns = [self.featureDao idAndGeometryColumnNames];
    
    while(chunkCount >= 0){
        
        // Autorelease to reduce memory footprint
        @autoreleasepool {
            
            GPKGResultSet *results = [self.featureDao queryForChunkWithColumns:columns andLimit:self.chunkLimit andOffset:offset];
            chunkCount = [self indexRowsWithTableIndex:tableIndex andResults:results];
            
        }
        
        if(chunkCount > 0){
            count += chunkCount;
        }
        
        offset += self.chunkLimit;
    }
    
    // Update the last indexed time
    if(self.progress == nil || [self.progress isActive]){
        [self updateLastIndexed];
    }
    
    return count;
}

-(int) indexRowsWithTableIndex: (GPKGTableIndex *) tableIndex andResults: (GPKGResultSet *) results{
    
    int count = -1;
    
    @try{
        while((self.progress == nil || [self.progress isActive]) && [results moveToNext]){
            if(count < 0){
                count++;
            }
            @try {
                GPKGFeatureRow *row = (GPKGFeatureRow *)[self.featureDao object:results];
                BOOL indexed = [self indexTableIndex:tableIndex withGeomId:[row idValue] andGeometryData:[row geometry]];
                if(indexed){
                    count++;
                }
                if(self.progress != nil){
                    [self.progress addProgress:1];
                }
                
            } @catch (NSException *exception) {
                NSLog(@"Failed to index feature. Table: %@", tableIndex.tableName);
            }
        }
    }@finally{
        [results close];
    }
    
    return count;
}

-(BOOL) indexTableIndex: (GPKGTableIndex *) tableIndex withGeomId: (int) geomId andGeometryData: (GPKGGeometryData *) geomData{
    
    BOOL indexed = NO;
    
    if(geomData != nil){
        
        // Get or build the envelope
        SFGeometryEnvelope *envelope = [geomData envelope];
        
        // Create the new index row
        if(envelope != nil){
            GPKGGeometryIndex *geometryIndex = [self.geometryIndexDao populateWithTableIndex:tableIndex andGeomId:geomId andEnvelope:envelope];
            [self.geometryIndexDao createOrUpdate:geometryIndex];
            indexed = YES;
        }
    }
    
    return indexed;
}

-(void) updateLastIndexed{
    
    GPKGTableIndex *tableIndex = [[GPKGTableIndex alloc] init];
    [tableIndex setTableName:self.tableName];
    [tableIndex setLastIndexed:[NSDate date]];
    [self.tableIndexDao createOrUpdate:tableIndex];
}

-(BOOL) indexFeatureRow: (GPKGFeatureRow *) row{
    GPKGTableIndex *tableIndex = [self tableIndex];
    if(tableIndex == nil){
        [NSException raise:@"Not Indexed" format:@"GeoPackage table is not indexed. GeoPackage: %@, Table: %@", self.geoPackage.name, self.tableName];
    }
    BOOL indexed = [self indexTableIndex:tableIndex withGeomId:[row idValue] andGeometryData:[row geometry]];
    
    // Update the last indexed time
    [self updateLastIndexed];
    
    return indexed;
}

-(BOOL) deleteIndex{
    BOOL deleted = NO;
    if([self.tableIndexDao tableExists]){
        deleted = [self.tableIndexDao deleteByIdCascade:self.tableName] > 0;
    }
    if([self.extensionsDao tableExists]){
        deleted = [self.extensionsDao deleteByExtension:self.extensionName andTable:self.tableName] > 0 || deleted;
    }
    return deleted;
}

-(int) deleteIndexWithGeomId: (int) geomId{
    return [self.geometryIndexDao deleteByMultiId:[NSArray arrayWithObjects:self.tableName, [NSNumber numberWithInt:geomId], nil]];
}

-(int) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithGeomId:[row idValue]];
}

-(BOOL) isIndexed{
    BOOL indexed = NO;
    GPKGExtensions *extension = [self extension];
    if(extension != nil){
        
        GPKGContentsDao *contentsDao = [self.geoPackage contentsDao];
        GPKGContents *contents = (GPKGContents *)[contentsDao queryForIdObject:self.tableName];
        if(contents != nil){
            NSDate *lastChange = contents.lastChange;
            
            GPKGTableIndex *tableIndex = (GPKGTableIndex *)[self.tableIndexDao queryForIdObject:self.tableName];
            
            if(tableIndex != nil){
                NSDate *lastIndexed = tableIndex.lastIndexed;
                if(lastIndexed != nil){
                    NSComparisonResult compareResult = [lastIndexed compare:lastChange];
                    indexed = compareResult == NSOrderedDescending || compareResult == NSOrderedSame;
                }
            }
        }
    }
    return indexed;
}

-(GPKGTableIndex *) tableIndexCreate{
    GPKGTableIndex *tableIndex = [self tableIndex];
    
    if(tableIndex == nil){
        if(![self.tableIndexDao tableExists]){
            [self createTableIndexTable];
        }
        
        tableIndex = [[GPKGTableIndex alloc] init];
        [tableIndex setTableName:self.tableName];
        [tableIndex setLastIndexed:nil];
        
        [self.tableIndexDao create:tableIndex];
    }
    return tableIndex;
}

-(GPKGTableIndex *) tableIndex{
    
    GPKGTableIndex *tableIndex = nil;
    if([self.tableIndexDao tableExists]){
        tableIndex = (GPKGTableIndex *)[self.tableIndexDao queryForIdObject:self.tableName];
    }
    
    return tableIndex;
}

-(NSDate *) lastIndexed{
    NSDate *lastIndexed = nil;
    GPKGTableIndex *tableIndex = [self tableIndex];
    if(tableIndex != nil){
        lastIndexed = tableIndex.lastIndexed;
    }
    return lastIndexed;
}

-(void) createOrClearGeometryIndices{
    
    if(![self createGeometryIndexTable]){
        [self clearGeometryIndices];
    }
    
}

-(int) clearGeometryIndices{
    
    NSString *where = [self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName];
    NSArray *whereArgs = [self.geometryIndexDao buildWhereArgsWithValue:self.tableName];
    
    int deleted = [self.geometryIndexDao deleteWhere:where andWhereArgs:whereArgs];
    
    return deleted;
}

-(GPKGExtensions *) extensionCreate{
    return [self extensionCreateWithName:self.extensionName andTableName:self.tableName andColumnName:self.columnName andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
}

-(GPKGExtensions *) extension{
    return [self extensionWithName:self.extensionName andTableName:self.tableName  andColumnName:self.columnName];
}

-(GPKGTableIndexDao *) tableIndexDao{
    return [GPKGFeatureTableIndex tableIndexDaoWithGeoPackage:self.geoPackage];
}

+(GPKGTableIndexDao *) tableIndexDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [GPKGTableIndexDao createWithDatabase:geoPackage.database];
}

+(GPKGTableIndexDao *) tableIndexDaoWithDatabase: (GPKGConnection *) database{
    return [GPKGTableIndexDao createWithDatabase:database];
}

-(BOOL) createTableIndexTable{
    [self verifyWritable];
    
    BOOL created = NO;
    if(![self.tableIndexDao tableExists]){
        GPKGGeometryIndexTableCreator *tableCreator = [[GPKGGeometryIndexTableCreator alloc] initWithDatabase:self.geoPackage.database];
        created = [tableCreator createTableIndex] > 0;
    }
    
    return created;
}

-(GPKGGeometryIndexDao *) geometryIndexDao{
    return [GPKGFeatureTableIndex geometryIndexDaoWithGeoPackage:self.geoPackage];
}

+(GPKGGeometryIndexDao *) geometryIndexDaoWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [GPKGGeometryIndexDao createWithDatabase:geoPackage.database];
}

+(GPKGGeometryIndexDao *) geometryIndexDaoWithDatabase: (GPKGConnection *) database{
    return [GPKGGeometryIndexDao createWithDatabase:database];
}

-(BOOL) createGeometryIndexTable{
    [self verifyWritable];
    
    BOOL created = NO;
    if(![self.geometryIndexDao tableExists]){
        GPKGGeometryIndexTableCreator *tableCreator = [[GPKGGeometryIndexTableCreator alloc] initWithDatabase:self.geoPackage.database];
        created = [tableCreator createGeometryIndex] > 0;
    }
    
    return created;
}

-(BOOL) indexGeometryIndexTable{
    [self verifyWritable];
    
    BOOL indexed = NO;
    if([self.geometryIndexDao tableExists]){
        GPKGGeometryIndexTableCreator *tableCreator = [[GPKGGeometryIndexTableCreator alloc] initWithDatabase:self.geoPackage.database];
        indexed = [tableCreator indexGeometryIndex] > 0;
    }
    return indexed;
}

-(BOOL) unindexGeometryIndexTable{
    [self verifyWritable];
    
    BOOL unindexed = NO;
    if([self.geometryIndexDao tableExists]){
        GPKGGeometryIndexTableCreator *tableCreator = [[GPKGGeometryIndexTableCreator alloc] initWithDatabase:self.geoPackage.database];
        unindexed = [tableCreator unindexGeometryIndex] > 0;
    }
    return unindexed;
}

-(GPKGResultSet *) query{
    
    NSString *where = [self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName];
    NSArray *whereArgs = [self.geometryIndexDao buildWhereArgsWithValue:self.tableName];
    
    GPKGResultSet *results = [self.geometryIndexDao queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(NSString *) queryIdsSQL{
    return [self queryIdsSQLWhere:nil];
}

-(int) count{
    GPKGResultSet *results = [self query];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGBoundingBox *) boundingBox{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT MIN(%@), MIN(%@), MAX(%@), MAX(%@) FROM %@ WHERE %@ = ?", GPKG_GI_COLUMN_MIN_X, GPKG_GI_COLUMN_MIN_Y, GPKG_GI_COLUMN_MAX_X, GPKG_GI_COLUMN_MAX_Y, GPKG_GI_TABLE_NAME, GPKG_GI_COLUMN_TABLE_NAME];
    NSArray *dataTypes = [NSArray arrayWithObjects:[[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], nil];
    
    NSArray<NSNumber *> *results = (NSArray<NSNumber *> *)[self.geometryIndexDao querySingleRowResultsWithSql:sql andArgs:[NSArray arrayWithObjects:self.tableName, nil] andDataTypes:dataTypes];
    
    double minLongitude = [[results objectAtIndex:0] doubleValue];
    double minLatitude = [[results objectAtIndex:1] doubleValue];
    double maxLongitude = [[results objectAtIndex:2] doubleValue];
    double maxLatitude = [[results objectAtIndex:3] doubleValue];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    
    return boundingBox;
}

-(GPKGBoundingBox *) boundingBoxInProjection: (SFPProjection *) projection{
    GPKGBoundingBox *boundingBox = [self boundingBox];
    if(boundingBox != nil && projection != nil){
        SFPProjectionTransform *projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:[self projection] andToProjection:projection];
        boundingBox = [boundingBox transform:projectionTransform];
    }
    return boundingBox;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    SFGeometryEnvelope *envelope = [boundingBox buildEnvelope];
    GPKGResultSet *geometryResults = [self queryWithEnvelope:envelope];
    return geometryResults;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    
    GPKGResultSet *geometryIndices = [self queryWithBoundingBox:featureBoundingBox];
    
    return geometryIndices;
}
    
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGResultSet *results = [self queryWithBoundingBox:boundingBox];
    int count = results.count;
    [results close];
    return count;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    
    int count = [self countWithBoundingBox:featureBoundingBox];
    
    return count;
}

-(GPKGResultSet *) queryWithEnvelope: (SFGeometryEnvelope *) envelope{
    
    NSString *where = [self whereWithEnvelope:envelope];
    NSArray *whereArgs = [self whereArgsWithEnvelope:envelope];
    
    GPKGResultSet *results = [self.geometryIndexDao queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(NSString *) whereWithEnvelope: (SFGeometryEnvelope *) envelope{
    
    NSMutableString *where = [NSMutableString string];
    [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName]];
    [where appendString:@" and "];
    
    BOOL minXLessThanMaxX = [envelope.minX compare:envelope.maxX] != NSOrderedDescending;
    
    NSDecimalNumber *minX = [[NSDecimalNumber alloc] initWithDouble:[envelope.minX doubleValue] - self.tolerance];
    NSDecimalNumber *maxX = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxX doubleValue] + self.tolerance];
    NSDecimalNumber *minY = [[NSDecimalNumber alloc] initWithDouble:[envelope.minY doubleValue] - self.tolerance];
    NSDecimalNumber *maxY = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxY doubleValue] + self.tolerance];
    
    if(minXLessThanMaxX){
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_X andValue:maxX andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_X andValue:minX andOperation:@">="]];
    }else{
        [where appendString:@"("];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_X andValue:maxX andOperation:@"<="]];
        [where appendString:@" or "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_X andValue:minX andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_X andValue:minX andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_X andValue:maxX andOperation:@"<="]];
        [where appendString:@")"];
    }
    [where appendString:@" and "];
    [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_Y andValue:maxY andOperation:@"<="]];
    [where appendString:@" and "];
    [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_Y andValue:minY andOperation:@">="]];
    
    if(envelope.hasZ){
        NSDecimalNumber *minZ = [[NSDecimalNumber alloc] initWithDouble:[envelope.minZ doubleValue] - self.tolerance];
        NSDecimalNumber *maxZ = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxZ doubleValue] + self.tolerance];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_Z andValue:minZ andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_Z andValue:maxZ andOperation:@">="]];
    }
    
    if(envelope.hasM){
        NSDecimalNumber *minM = [[NSDecimalNumber alloc] initWithDouble:[envelope.minM doubleValue] - self.tolerance];
        NSDecimalNumber *maxM = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxM doubleValue] + self.tolerance];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_M andValue:minM andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_M andValue:maxM andOperation:@">="]];
    }
    
    return where;
}

-(NSArray *) whereArgsWithEnvelope: (SFGeometryEnvelope *) envelope{
    
    BOOL minXLessThanMaxX = [envelope.minX compare:envelope.maxX] != NSOrderedDescending;
    
    NSDecimalNumber *minX = [[NSDecimalNumber alloc] initWithDouble:[envelope.minX doubleValue] - self.tolerance];
    NSDecimalNumber *maxX = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxX doubleValue] + self.tolerance];
    NSDecimalNumber *minY = [[NSDecimalNumber alloc] initWithDouble:[envelope.minY doubleValue] - self.tolerance];
    NSDecimalNumber *maxY = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxY doubleValue] + self.tolerance];

    NSMutableArray *whereArgs = [NSMutableArray array];
    [whereArgs addObject:self.tableName];
    [whereArgs addObject:maxX];
    [whereArgs addObject:minX];
    if(!minXLessThanMaxX){
        [whereArgs addObject:minX];
        [whereArgs addObject:maxX];
    }
    [whereArgs addObject:maxY];
    [whereArgs addObject:minY];
    
    if(envelope.hasZ){
        NSDecimalNumber *minZ = [[NSDecimalNumber alloc] initWithDouble:[envelope.minZ doubleValue] - self.tolerance];
        NSDecimalNumber *maxZ = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxZ doubleValue] + self.tolerance];
        [whereArgs addObject:maxZ];
        [whereArgs addObject:minZ];
    }
    
    if(envelope.hasM){
        NSDecimalNumber *minM = [[NSDecimalNumber alloc] initWithDouble:[envelope.minM doubleValue] - self.tolerance];
        NSDecimalNumber *maxM = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxM doubleValue] + self.tolerance];
        [whereArgs addObject:maxM];
        [whereArgs addObject:minM];
    }
    
    return whereArgs;
}

-(NSString *) queryIdsSQLWithEnvelope: (SFGeometryEnvelope *) envelope{
    NSString *where = [self whereWithEnvelope:envelope];
    return [self queryIdsSQLWhere:where];
}

-(int) countWithEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGResultSet *results = [self queryWithEnvelope:envelope];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGBoundingBox *) featureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    SFPProjectionTransform *projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:[self projection]];
    GPKGBoundingBox *featureBoundingBox = [boundingBox transform:projectionTransform];
    return featureBoundingBox;
}

-(GPKGFeatureRow *) featureRow: (GPKGGeometryIndex *) geometryIndex{
    return (GPKGFeatureRow *)[self.featureDao queryForIdObject:geometryIndex.geomId];
}

-(GPKGGeometryIndex *) geometryIndexWithResultSet: (GPKGResultSet *) resultSet{
    return (GPKGGeometryIndex *) [self.geometryIndexDao object:resultSet];
}

-(GPKGFeatureRow *) featureRowWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryIndex *geometryIndex = [self geometryIndexWithResultSet:resultSet];
    GPKGFeatureRow *featureRow = [self featureRowWithGeometryIndex:geometryIndex];
    return featureRow;
}

-(GPKGFeatureRow *) featureRowWithGeometryIndex: (GPKGGeometryIndex *) geometryIndex{
    
    NSNumber *geomId = geometryIndex.geomId;
    
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

-(NSString *) queryIdsSQLWhere: (NSString *) where{
    return [GPKGSqlLiteQueryBuilder buildQueryWithDistinct:NO
         andTable:GPKG_GI_TABLE_NAME
        andColumns:[NSArray arrayWithObject:GPKG_GI_COLUMN_GEOM_ID]
          andWhere:where
        andGroupBy:nil
         andHaving:nil
        andOrderBy:nil
          andLimit:nil];
}

-(GPKGResultSet *) queryFeatures{
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQL]];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQL]];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQL]];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQL]];
}

-(int) countFeatures{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQL]];
}

-(int) countFeaturesWithColumn: (NSString *) column{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQL]];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQL]];
}

-(GPKGResultSet *) queryFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(int) countFeaturesWithFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQL] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where{
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andWhere: (NSString *) where{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(int) countFeaturesWhere: (NSString *) where{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(int) countFeaturesWithColumn: (NSString *) column andWhere: (NSString *) where{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQL] andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQL] andWhere:where andWhereArgs:whereArgs];
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

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andFieldValues: (GPKGColumnValues *) fieldValues{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where{
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryFeaturesWithDistinct:NO andColumns:columns andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self queryFeaturesWithDistinct:distinct andColumns:columns andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:nil andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countFeaturesWithDistinct:NO andColumn:column andBoundingBox:boundingBox inProjection:projection andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    return [self countFeaturesWithDistinct:distinct andColumn:column andBoundingBox:featureBoundingBox andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope]];
}

-(GPKGResultSet *) queryFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andFieldValues:fieldValues];
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
    return [self.featureDao queryInWithNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithDistinct:distinct andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithColumns:columns andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryFeaturesWithDistinct: (BOOL) distinct andColumns: (NSArray<NSString *> *) columns andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao queryInWithDistinct:distinct andColumns:columns andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countInWithNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countInWithColumn:column andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

-(int) countFeaturesWithDistinct: (BOOL) distinct andColumn: (NSString *) column andEnvelope: (SFGeometryEnvelope *) envelope andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.featureDao countInWithDistinct:distinct andColumn:column andNestedSQL:[self queryIdsSQLWithEnvelope:envelope] andNestedArgs:[self whereArgsWithEnvelope:envelope] andWhere:where andWhereArgs:whereArgs];
}

@end
