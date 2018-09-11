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

NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR = @"geometry_index";
NSString * const GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION = @"geopackage.extensions.geometry_index";

@interface GPKGFeatureTableIndex ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong)  GPKGUserRowSync * featureRowSync;
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
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION];
        self.tableName = featureDao.tableName;
        self.columnName = featureDao.getGeometryColumnName;
        self.tableIndexDao = [geoPackage getTableIndexDao];
        self.geometryIndexDao = [geoPackage getGeometryIndexDao];
        self.chunkLimit = [NSNumber numberWithInt:1000];
    }
    return self;
}

-(GPKGFeatureDao *) getFeatureDao{
    return self.featureDao;
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

-(SFPProjection *) projection{
    return self.featureDao.projection;
}

-(NSString *) getTableName{
    return self.tableName;
}

-(NSString *) getColumnName{
    return self.columnName;
}

-(void) close{
    // Don't close anything, leave the GeoPackage connection open
}

-(int) index{
    return [self indexWithForce:false];
}

-(int) indexWithForce: (BOOL) force{
    int count = 0;
    if(force || ![self isIndexed]){
        [self getOrCreateExtension];
        GPKGTableIndex * tableIndex = [self getOrCreateTableIndex];
        [self createOrClearGeometryIndices];
        [self.geoPackage unindexGeometryIndexTable];
        count = [self indexTable:tableIndex];
        [self.geoPackage indexGeometryIndexTable];
    }
    return count;
}

-(int) indexTable: (GPKGTableIndex *) tableIndex{
    
    int count = 0;
    
    int offset = 0;
    int chunkCount = 0;
    
    while(chunkCount >= 0){
        
        // Autorelease to reduce memory footprint
        @autoreleasepool {
            
            GPKGResultSet * results = [self.featureDao queryForChunkWithLimit:[self.chunkLimit intValue] andOffset:offset];
            chunkCount = [self indexRowsWithTableIndex:tableIndex andResults:results];
            
        }
        
        if(chunkCount > 0){
            count += chunkCount;
        }
        
        offset += [self.chunkLimit intValue];
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
                GPKGFeatureRow * row = (GPKGFeatureRow *)[self.featureDao getObject:results];
                BOOL indexed = [self indexTableIndex:tableIndex withGeomId:[[row getId] intValue] andGeometryData:[row getGeometry]];
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
    
    BOOL indexed = false;
    
    if(geomData != nil){
        
        // Get or build the envelope
        SFGeometryEnvelope *envelope = [geomData getOrBuildEnvelope];
        
        // Create the new index row
        if(envelope != nil){
            GPKGGeometryIndex * geometryIndex = [self.geometryIndexDao populateWithTableIndex:tableIndex andGeomId:geomId andGeometryEnvelope:envelope];
            [self.geometryIndexDao createOrUpdate:geometryIndex];
            indexed = true;
        }
    }
    
    return indexed;
}

-(void) updateLastIndexed{
    
    GPKGTableIndex * tableIndex = [[GPKGTableIndex alloc] init];
    [tableIndex setTableName:self.tableName];
    [tableIndex setLastIndexed:[NSDate date]];
    [self.tableIndexDao createOrUpdate:tableIndex];
}

-(BOOL) indexFeatureRow: (GPKGFeatureRow *) row{
    GPKGTableIndex * tableIndex = [self getTableIndex];
    if(tableIndex == nil){
        [NSException raise:@"Not Indexed" format:@"GeoPackage table is not indexed. GeoPackage: %@, Table: %@", self.geoPackage.name, self.tableName];
    }
    BOOL indexed = [self indexTableIndex:tableIndex withGeomId:[[row getId] intValue] andGeometryData:[row getGeometry]];
    
    // Update the last indexed time
    [self updateLastIndexed];
    
    return indexed;
}

-(BOOL) deleteIndex{
    BOOL deleted = NO;
    if([self.tableIndexDao tableExists]){
        deleted = [self.tableIndexDao deleteByIdCascade:self.tableName] > 0;
    }
    deleted = [self.extensionsDao deleteByExtension:self.extensionName andTable:self.tableName] > 0 || deleted;
    return deleted;
}

-(int) deleteIndexWithGeomId: (int) geomId{
    return [self.geometryIndexDao deleteByMultiId:[[NSArray alloc] initWithObjects:self.tableName, [NSNumber numberWithInt:geomId], nil]];
}

-(int) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithGeomId:[[row getId] intValue]];
}

-(BOOL) isIndexed{
    BOOL indexed = false;
    GPKGExtensions * extension = [self getExtension];
    if(extension != nil){
        
        GPKGContentsDao * contentsDao = [self.geoPackage getContentsDao];
        GPKGContents * contents = (GPKGContents *)[contentsDao queryForIdObject:self.tableName];
        if(contents != nil){
            NSDate * lastChange = contents.lastChange;
            
            GPKGTableIndex * tableIndex = (GPKGTableIndex *)[self.tableIndexDao queryForIdObject:self.tableName];
            
            if(tableIndex != nil){
                NSDate * lastIndexed = tableIndex.lastIndexed;
                if(lastIndexed != nil){
                    NSComparisonResult compareResult = [lastIndexed compare:lastChange];
                    indexed = compareResult == NSOrderedDescending || compareResult == NSOrderedSame;
                }
            }
        }
    }
    return indexed;
}

-(GPKGTableIndex *) getOrCreateTableIndex{
    GPKGTableIndex * tableIndex = [self getTableIndex];
    
    if(tableIndex == nil){
        if(![self.tableIndexDao tableExists]){
            [self.geoPackage createTableIndexTable];
        }
        
        tableIndex = [[GPKGTableIndex alloc] init];
        [tableIndex setTableName:self.tableName];
        [tableIndex setLastIndexed:nil];
        
        [self.tableIndexDao create:tableIndex];
    }
    return tableIndex;
}

-(GPKGTableIndex *) getTableIndex{
    
    GPKGTableIndex * tableIndex = nil;
    if([self.tableIndexDao tableExists]){
        tableIndex = (GPKGTableIndex *)[self.tableIndexDao queryForIdObject:self.tableName];
    }
    
    return tableIndex;
}

-(NSDate *) getLastIndexed{
    NSDate * lastIndexed = nil;
    GPKGTableIndex * tableIndex = [self getTableIndex];
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
    
    NSString * where = [self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName];
    NSArray * whereArgs = [self.geometryIndexDao buildWhereArgsWithValue:self.tableName];
    
    int deleted = [self.geometryIndexDao deleteWhere:where andWhereArgs:whereArgs];
    
    return deleted;
}

-(BOOL) createGeometryIndexTable{
    
    BOOL created = false;
    
    // Create the geometry index table if needed as well
    if(![self.geometryIndexDao tableExists]){
        created = [self.geoPackage createGeometryIndexTable];
    }
    
    return created;
}

-(GPKGExtensions *) getOrCreateExtension{
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:self.tableName andColumnName:self.columnName andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    return extension;
}

-(GPKGExtensions *) getExtension{
    GPKGExtensions * extension = [self getWithExtensionName:self.extensionName andTableName:self.tableName  andColumnName:self.columnName];
    return extension;
}

-(GPKGResultSet *) query{
    
    NSString * where = [self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName];
    NSArray * whereArgs = [self.geometryIndexDao buildWhereArgsWithValue:self.tableName];
    
    GPKGResultSet * results = [self.geometryIndexDao queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(int) count{
    GPKGResultSet * results = [self query];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGBoundingBox *) boundingBox{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT MIN(%@), MIN(%@), MAX(%@), MAX(%@) FROM %@ WHERE %@ = ?", GPKG_GI_COLUMN_MIN_X, GPKG_GI_COLUMN_MIN_Y, GPKG_GI_COLUMN_MAX_X, GPKG_GI_COLUMN_MAX_Y, GPKG_GI_TABLE_NAME, GPKG_GI_COLUMN_TABLE_NAME];
    NSArray *dataTypes = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], nil];
    
    NSArray<NSNumber *> *results = (NSArray<NSNumber *> *)[self.geometryIndexDao querySingleRowResultsWithSql:sql andArgs:[[NSArray alloc] initWithObjects:self.tableName, nil] andDataTypes:dataTypes];
    
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
    SFGeometryEnvelope * envelope = [boundingBox buildEnvelope];
    GPKGResultSet * geometryResults = [self queryWithGeometryEnvelope:envelope];
    return geometryResults;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    
    GPKGBoundingBox *featureBoundingBox = [self getFeatureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    
    GPKGResultSet *geometryIndices = [self queryWithBoundingBox:featureBoundingBox];
    
    return geometryIndices;
}
    
-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGResultSet * results = [self queryWithBoundingBox:boundingBox];
    int count = results.count;
    [results close];
    return count;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    
    GPKGBoundingBox *featureBoundingBox = [self getFeatureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    
    int count = [self countWithBoundingBox:featureBoundingBox];
    
    return count;
}

-(GPKGResultSet *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    
    NSMutableString * where = [[NSMutableString alloc] init];
    [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName]];
    [where appendString:@" and "];
    BOOL minXLessThanMaxX = [envelope.minX compare:envelope.maxX] == NSOrderedAscending;
    if(minXLessThanMaxX){
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_X andValue:envelope.maxX andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_X andValue:envelope.minX andOperation:@">="]];
    }else{
        [where appendString:@"("];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_X andValue:envelope.maxX andOperation:@"<="]];
        [where appendString:@" or "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_X andValue:envelope.minX andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_X andValue:envelope.minX andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_X andValue:envelope.maxX andOperation:@"<="]];
        [where appendString:@")"];
    }
    [where appendString:@" and "];
    [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_Y andValue:envelope.maxY andOperation:@"<="]];
    [where appendString:@" and "];
    [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_Y andValue:envelope.minY andOperation:@">="]];
    
    NSMutableArray * whereArgs = [[NSMutableArray alloc] init];
    [whereArgs addObject:self.tableName];
    [whereArgs addObject:envelope.maxX];
    [whereArgs addObject:envelope.minX];
    if(!minXLessThanMaxX){
        [whereArgs addObject:envelope.minX];
        [whereArgs addObject:envelope.maxX];
    }
    [whereArgs addObject:envelope.maxY];
    [whereArgs addObject:envelope.minY];
    
    if(envelope.hasZ){
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_Z andValue:envelope.minZ andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_Z andValue:envelope.maxZ andOperation:@">="]];
        [whereArgs addObject:envelope.maxZ];
        [whereArgs addObject:envelope.minZ];
    }
    
    if(envelope.hasM){
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MIN_M andValue:envelope.minM andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_MAX_M andValue:envelope.maxM andOperation:@">="]];
        [whereArgs addObject:envelope.maxM];
        [whereArgs addObject:envelope.minM];
    }
    
    GPKGResultSet * results = [self.geometryIndexDao queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGResultSet * results = [self queryWithGeometryEnvelope:envelope];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGBoundingBox *) getFeatureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    SFPProjectionTransform * projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:[self projection]];
    GPKGBoundingBox * featureBoundingBox = [boundingBox transform:projectionTransform];
    return featureBoundingBox;
}

-(GPKGFeatureRow *) getFeatureRow: (GPKGGeometryIndex *) geometryIndex{
    return (GPKGFeatureRow *)[self.featureDao queryForIdObject:geometryIndex.geomId];
}

-(GPKGGeometryIndex *) getGeometryIndexWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryIndex * geometryIndex = (GPKGGeometryIndex *) [self.geometryIndexDao getObject:resultSet];
    return geometryIndex;
}

-(GPKGFeatureRow *) getFeatureRowWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryIndex * geometryIndex = [self getGeometryIndexWithResultSet:resultSet];
    GPKGFeatureRow * featureRow = [self getFeatureRowWithGeometryIndex:geometryIndex];
    return featureRow;
}

-(GPKGFeatureRow *) getFeatureRowWithGeometryIndex: (GPKGGeometryIndex *) geometryIndex{
    
    NSNumber *geomId = geometryIndex.geomId;
    
    // Get the row or lock for reading
    GPKGFeatureRow *row = (GPKGFeatureRow *)[self.featureRowSync getRowOrLockNumber:geomId];
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

@end
