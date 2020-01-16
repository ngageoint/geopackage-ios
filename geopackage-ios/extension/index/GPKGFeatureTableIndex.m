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
        self.extensionDefinition = [GPKGProperties valueOfProperty:GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION];
        self.tableName = featureDao.tableName;
        self.columnName = [featureDao geometryColumnName];
        self.tableIndexDao = [geoPackage tableIndexDao];
        self.geometryIndexDao = [geoPackage geometryIndexDao];
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
    return [self indexWithForce:false];
}

-(int) indexWithForce: (BOOL) force{
    int count = 0;
    if(force || ![self isIndexed]){
        [self extensionCreate];
        GPKGTableIndex * tableIndex = [self tableIndexCreate];
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
            
            GPKGResultSet * results = [self.featureDao queryForChunkWithLimit:self.chunkLimit andOffset:offset];
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
                GPKGFeatureRow * row = (GPKGFeatureRow *)[self.featureDao object:results];
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
    
    BOOL indexed = false;
    
    if(geomData != nil){
        
        // Get or build the envelope
        SFGeometryEnvelope *envelope = [geomData buildEnvelope];
        
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
    GPKGTableIndex * tableIndex = [self tableIndex];
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
    return [self.geometryIndexDao deleteByMultiId:[[NSArray alloc] initWithObjects:self.tableName, [NSNumber numberWithInt:geomId], nil]];
}

-(int) deleteIndexWithFeatureRow: (GPKGFeatureRow *) row{
    return [self deleteIndexWithGeomId:[row idValue]];
}

-(BOOL) isIndexed{
    BOOL indexed = false;
    GPKGExtensions * extension = [self extension];
    if(extension != nil){
        
        GPKGContentsDao * contentsDao = [self.geoPackage contentsDao];
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

-(GPKGTableIndex *) tableIndexCreate{
    GPKGTableIndex * tableIndex = [self tableIndex];
    
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

-(GPKGTableIndex *) tableIndex{
    
    GPKGTableIndex * tableIndex = nil;
    if([self.tableIndexDao tableExists]){
        tableIndex = (GPKGTableIndex *)[self.tableIndexDao queryForIdObject:self.tableName];
    }
    
    return tableIndex;
}

-(NSDate *) lastIndexed{
    NSDate * lastIndexed = nil;
    GPKGTableIndex * tableIndex = [self tableIndex];
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

-(GPKGExtensions *) extensionCreate{
    GPKGExtensions * extension = [self extensionCreateWithName:self.extensionName andTableName:self.tableName andColumnName:self.columnName andDefinition:self.extensionDefinition andScope:GPKG_EST_READ_WRITE];
    return extension;
}

-(GPKGExtensions *) extension{
    GPKGExtensions * extension = [self extensionWithName:self.extensionName andTableName:self.tableName  andColumnName:self.columnName];
    return extension;
}

-(GPKGResultSet *) query{
    
    NSString * where = [self.geometryIndexDao buildWhereWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:self.tableName];
    NSArray * whereArgs = [self.geometryIndexDao buildWhereArgsWithValue:self.tableName];
    
    GPKGResultSet * results = [self.geometryIndexDao queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(NSString *) queryIdsSQL{
    return [self queryIdsSQLWhere:nil];
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
    
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    
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
    
    GPKGBoundingBox *featureBoundingBox = [self featureBoundingBoxWithBoundingBox:boundingBox inProjection:projection];
    
    int count = [self countWithBoundingBox:featureBoundingBox];
    
    return count;
}

-(GPKGResultSet *) queryWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    
    NSString *where = [self whereWithGeometryEnvelope:envelope];
    NSArray *whereArgs = [self whereArgsWithGeometryEnvelope:envelope];
    
    GPKGResultSet * results = [self.geometryIndexDao queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(NSString *) whereWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    
    NSMutableString * where = [[NSMutableString alloc] init];
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

-(NSArray *) whereArgsWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    
    BOOL minXLessThanMaxX = [envelope.minX compare:envelope.maxX] != NSOrderedDescending;
    
    NSDecimalNumber *minX = [[NSDecimalNumber alloc] initWithDouble:[envelope.minX doubleValue] - self.tolerance];
    NSDecimalNumber *maxX = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxX doubleValue] + self.tolerance];
    NSDecimalNumber *minY = [[NSDecimalNumber alloc] initWithDouble:[envelope.minY doubleValue] - self.tolerance];
    NSDecimalNumber *maxY = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxY doubleValue] + self.tolerance];

    NSMutableArray *whereArgs = [[NSMutableArray alloc] init];
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

-(NSString *) queryIdsSQLWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    NSString *where = [self whereWithGeometryEnvelope:envelope];
    return [self queryIdsSQLWhere:where];
}

-(int) countWithGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGResultSet * results = [self queryWithGeometryEnvelope:envelope];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGBoundingBox *) featureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox inProjection: (SFPProjection *) projection{
    SFPProjectionTransform * projectionTransform = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:[self projection]];
    GPKGBoundingBox * featureBoundingBox = [boundingBox transform:projectionTransform];
    return featureBoundingBox;
}

-(GPKGFeatureRow *) featureRow: (GPKGGeometryIndex *) geometryIndex{
    return (GPKGFeatureRow *)[self.featureDao queryForIdObject:geometryIndex.geomId];
}

-(GPKGGeometryIndex *) geometryIndexWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryIndex * geometryIndex = (GPKGGeometryIndex *) [self.geometryIndexDao object:resultSet];
    return geometryIndex;
}

-(GPKGFeatureRow *) featureRowWithResultSet: (GPKGResultSet *) resultSet{
    GPKGGeometryIndex * geometryIndex = [self geometryIndexWithResultSet:resultSet];
    GPKGFeatureRow * featureRow = [self featureRowWithGeometryIndex:geometryIndex];
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

@end
