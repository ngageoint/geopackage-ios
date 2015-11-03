//
//  GPKGFeatureTableIndex.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTableIndex.h"
#import "GPKGProperties.h"
#import "WKBGeometryEnvelopeBuilder.h"
#import "GPKGProjectionTransform.h"

NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR = @"geometry_index";
NSString * const GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION = @"geopackage.extensions.geometry_index";

@interface GPKGFeatureTableIndex ()

@property (nonatomic, strong) GPKGGeoPackage *geoPackage;
@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) GPKGExtensionsDao *extensionsDao;
@property (nonatomic, strong) GPKGTableIndexDao *tableIndexDao;
@property (nonatomic, strong) GPKGGeometryIndexDao *geometryIndexDao;

@end

@implementation GPKGFeatureTableIndex

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao{
    self = [super init];
    if(self != nil){
        self.geoPackage = geoPackage;
        self.featureDao = featureDao;
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_GEOMETRY_INDEX_DEFINITION];
        self.tableName = featureDao.tableName;
        self.columnName = featureDao.getGeometryColumnName;
        self.extensionsDao = [geoPackage getExtensionsDao];
        self.tableIndexDao = [geoPackage getTableIndexDao];
        self.geometryIndexDao = [geoPackage getGeometryIndexDao];
    }
    return self;
}

-(GPKGGeoPackage *) getGeoPackage{
    return self.geoPackage;
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
        count = [self indexTable:tableIndex];
    }
    return count;
}

-(int) indexTable: (GPKGTableIndex *) tableIndex{
    
    int count = 0;
    
    // Autorelease to reduce memory footprint
    @autoreleasepool {
    
        GPKGResultSet * results = [self.featureDao queryForAll];
        @try{
            while((self.progress == nil || [self.progress isActive]) && [results moveToNext]){
                GPKGFeatureRow * row = (GPKGFeatureRow *)[self.featureDao getObject:results];
                BOOL indexed = [self indexTableIndex:tableIndex withGeomId:[[row getId] intValue] andGeometryData:[row getGeometry]];
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
        [self updateLastIndexed];
    }
    
    return count;
}

-(BOOL) indexTableIndex: (GPKGTableIndex *) tableIndex withGeomId: (int) geomId andGeometryData: (GPKGGeometryData *) geomData{
    
    BOOL indexed = false;
    
    if(geomData != nil){
        
        // Get the envelope
        WKBGeometryEnvelope * envelope = geomData.envelope;
        
        // If no envelope, build one from the geometry
        if(envelope == nil){
            WKBGeometry * geometry = geomData.geometry;
            if(geometry != nil){
                envelope = [WKBGeometryEnvelopeBuilder buildEnvelopeWithGeometry:geometry];
            }
        }
        
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
    BOOL deleted = [self.tableIndexDao deleteByIdCascade:self.tableName] > 0;
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
    GPKGExtensions * extension = [self getExtension];
    
    if(extension == nil){
        if(![self.extensionsDao tableExists]){
            [self.geoPackage createExtensionsTable];
        }
        
        extension = [[GPKGExtensions alloc] init];
        [extension setTableName:self.tableName];
        [extension setColumnName:self.columnName];
        [extension setExtensionNameWithAuthor:GPKG_EXTENSION_GEOMETRY_INDEX_AUTHOR andExtensionName:GPKG_EXTENSION_GEOMETRY_INDEX_NAME_NO_AUTHOR];
        [extension setDefinition:self.extensionDefinition];
        [extension setExtensionScopeType:GPKG_EST_READ_WRITE];
        
        [self.extensionsDao create:extension];
    }
    
    return extension;
}

-(GPKGExtensions *) getExtension{
    
    GPKGExtensions * extension = nil;
    if([self.extensionsDao tableExists]){
        extension = [self.extensionsDao queryByExtension:self.extensionName andTable:self.tableName andColumnName:self.columnName];
    }
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

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    WKBGeometryEnvelope * envelope = [boundingBox buildEnvelope];
    GPKGResultSet * geometryResults = [self queryWithGeometryEnvelope:envelope];
    return geometryResults;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGResultSet * results = [self queryWithBoundingBox:boundingBox];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGResultSet *) queryWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope{
    
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

-(int) countWithGeometryEnvelope: (WKBGeometryEnvelope *) envelope{
    GPKGResultSet * results = [self queryWithGeometryEnvelope:envelope];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGResultSet *) queryWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    
    GPKGBoundingBox * featureBoundingBox = [self getFeatureBoundingBoxWithBoundingBox:boundingBox andProjection:projection];
    GPKGResultSet * results = [self queryWithBoundingBox:featureBoundingBox];
    
    return results;
}

-(int) countWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    GPKGResultSet * results = [self queryWithBoundingBox:boundingBox andProjection:projection];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGBoundingBox *) getFeatureBoundingBoxWithBoundingBox: (GPKGBoundingBox *) boundingBox andProjection: (GPKGProjection *) projection{
    GPKGProjectionTransform * projectionTransform = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToProjection:self.featureDao.projection];
    GPKGBoundingBox * featureBoundingBox = [projectionTransform transformWithBoundingBox:boundingBox];
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
    GPKGFeatureRow * featureRow = (GPKGFeatureRow *)[self.featureDao queryForIdObject:geometryIndex.geomId];
    return featureRow;
}

@end
