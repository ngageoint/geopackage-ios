//
//  GPKGGeometryMetadataDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryMetadataDao.h"
#import "GPKGGeoPackageMetadataDao.h"
#import "GPKGUtils.h"

@implementation GPKGGeometryMetadataDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_GPGM_TABLE_NAME;
        self.idColumns = @[GPKG_GPGM_COLUMN_PK1, GPKG_GPGM_COLUMN_PK2, GPKG_GPGM_COLUMN_PK3];
        self.columnNames = @[GPKG_GPGM_COLUMN_GEOPACKAGE_ID, GPKG_GPGM_COLUMN_TABLE_NAME, GPKG_GPGM_COLUMN_ID, GPKG_GPGM_COLUMN_MIN_X, GPKG_GPGM_COLUMN_MAX_X, GPKG_GPGM_COLUMN_MIN_Y, GPKG_GPGM_COLUMN_MAX_Y, GPKG_GPGM_COLUMN_MIN_Z, GPKG_GPGM_COLUMN_MAX_Z, GPKG_GPGM_COLUMN_MIN_M, GPKG_GPGM_COLUMN_MAX_M];
        [self initializeColumnIndex];
        self.tolerance = .00000000000001;
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGGeometryMetadata alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGGeometryMetadata *setObject = (GPKGGeometryMetadata*) object;
    
    switch(columnIndex){
        case 0:
            setObject.geoPackageId = (NSNumber *) value;
            break;
        case 1:
            setObject.tableName = (NSString *) value;
            break;
        case 2:
            setObject.id = (NSNumber *) value;
            break;
        case 3:
            setObject.minX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 4:
            setObject.maxX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 5:
            setObject.minY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 6:
            setObject.maxY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 7:
            setObject.minZ = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 8:
            setObject.maxZ = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 9:
            setObject.minM = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 10:
            setObject.maxM = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeometryMetadata *metadata = (GPKGGeometryMetadata*) object;
    
    switch(columnIndex){
        case 0:
            value = metadata.geoPackageId;
            break;
        case 1:
            value = metadata.tableName;
            break;
        case 2:
            value = metadata.id;
            break;
        case 3:
            value = metadata.minX;
            break;
        case 4:
            value = metadata.maxX;
            break;
        case 5:
            value = metadata.minY;
            break;
        case 6:
            value = metadata.maxY;
            break;
        case 7:
            value = metadata.minZ;
            break;
        case 8:
            value = metadata.maxZ;
            break;
        case 9:
            value = metadata.minM;
            break;
        case 10:
            value = metadata.maxM;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGGeometryMetadata *) createMetadataWithGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self createMetadataWithGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName andId:geomId andEnvelope:envelope];
}

-(GPKGGeometryMetadata *) createMetadataWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (SFGeometryEnvelope *) envelope{
    
    GPKGGeometryMetadata * metadata = [self populateMetadataWithGeoPackageId:geoPackageId andTableName:tableName andId:geomId andEnvelope:envelope];
    [self create:metadata];
    return metadata;
}

-(GPKGGeometryMetadata *) populateMetadataWithGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId andEnvelope: (SFGeometryEnvelope *) envelope{
    
    GPKGGeometryMetadata * metadata = [[GPKGGeometryMetadata alloc] init];
    [metadata setGeoPackageId:geoPackageId];
    [metadata setTableName:tableName];
    [metadata setId:geomId];
    [metadata setMinX:envelope.minX];
    [metadata setMaxX:envelope.maxX];
    [metadata setMinY:envelope.minY];
    [metadata setMaxY:envelope.maxY];
    if(envelope.hasZ){
        [metadata setMinZ:envelope.minZ];
        [metadata setMaxZ:envelope.maxZ];
    }
    if(envelope.hasM){
        [metadata setMinM:envelope.minM];
        [metadata setMaxM:envelope.maxM];
    }
    return metadata;
}

-(BOOL) deleteMetadata: (GPKGGeometryMetadata *) metadata{
    return [self deleteByGeoPackageId:metadata.geoPackageId andTableName:metadata.tableName andId:metadata.id];
}

-(BOOL) deleteByGeoPackageName: (NSString *) name{
    return [self deleteByGeoPackageId:[self geoPackageIdForGeoPackageName:name]];
}

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId{
    
    NSString * where = [self buildWhereWithField:GPKG_GPGM_COLUMN_GEOPACKAGE_ID andValue:geoPackageId];
    NSArray * whereArgs = [self buildWhereArgsWithValue:geoPackageId];
    
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count > 0;
}

-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName{
    return [self deleteByGeoPackageId:[self geoPackageIdForGeoPackageName:name] andTableName:tableName];
}

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_GPGM_COLUMN_GEOPACKAGE_ID withValue:geoPackageId];
    [values addColumn:GPKG_GPGM_COLUMN_TABLE_NAME withValue:tableName];
    
    NSString * where = [self buildWhereWithFields:values];
    NSArray * whereArgs = [self buildWhereArgsWithValues:values];
    
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count > 0;
}

-(BOOL) deleteByGeoPackageName: (NSString *) name andTableName: (NSString *) tableName andId: (NSNumber *) geomId{
    return [self deleteByGeoPackageId:[self geoPackageIdForGeoPackageName:name] andTableName:tableName andId:geomId];
}

-(BOOL) deleteByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) geomId{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_GPGM_COLUMN_GEOPACKAGE_ID withValue:geoPackageId];
    [values addColumn:GPKG_GPGM_COLUMN_TABLE_NAME withValue:tableName];
    [values addColumn:GPKG_GPGM_COLUMN_ID withValue:geomId];
    
    NSString * where = [self buildWhereWithFields:values];
    NSArray * whereArgs = [self buildWhereArgsWithValues:values];
    
    int count = [self deleteWhere:where andWhereArgs:whereArgs];
    return count > 0;
}

-(BOOL) createOrUpdateMetadata: (GPKGGeometryMetadata *) metadata{
    
    BOOL success = false;
    
    if([self existsByMetadata:metadata]){
        success = [self updateMetadata:metadata];
    }else{
        [self create:metadata];
        success = true;
    }
    
    return success;
}

-(BOOL) updateMetadata: (GPKGGeometryMetadata *) metadata{
    
    GPKGContentValues *values = [[GPKGContentValues alloc] init];
    [values putKey:GPKG_GPGM_COLUMN_MIN_X withValue:metadata.minX];
    [values putKey:GPKG_GPGM_COLUMN_MAX_X withValue:metadata.maxX];
    [values putKey:GPKG_GPGM_COLUMN_MIN_Y withValue:metadata.minY];
    [values putKey:GPKG_GPGM_COLUMN_MAX_Y withValue:metadata.maxY];
    [values putKey:GPKG_GPGM_COLUMN_MIN_Z withValue:metadata.minZ];
    [values putKey:GPKG_GPGM_COLUMN_MAX_Z withValue:metadata.maxZ];
    [values putKey:GPKG_GPGM_COLUMN_MIN_M withValue:metadata.minM];
    [values putKey:GPKG_GPGM_COLUMN_MAX_M withValue:metadata.maxM];
    
    GPKGColumnValues *whereValues = [[GPKGColumnValues alloc] init];
    [whereValues addColumn:GPKG_GPGM_COLUMN_GEOPACKAGE_ID withValue:metadata.geoPackageId];
    [whereValues addColumn:GPKG_GPGM_COLUMN_TABLE_NAME withValue:metadata.tableName];
    [whereValues addColumn:GPKG_GPGM_COLUMN_ID withValue:metadata.id];
    
    NSString * where = [self buildWhereWithFields:whereValues];
    NSArray * whereArgs = [self buildWhereArgsWithValues:whereValues];
    
    int count = [self updateWithValues:values andWhere:where andWhereArgs:whereArgs];
    return count > 0;
}

-(BOOL) existsByMetadata: (GPKGGeometryMetadata *) metadata{
    return [self metadataByMetadata:metadata] != nil;
}

-(GPKGGeometryMetadata *) metadataByMetadata: (GPKGGeometryMetadata *) metadata{
    return [self metadataByGeoPackageId:metadata.geoPackageId andTableName:metadata.tableName andId:metadata.id];
}

-(GPKGGeometryMetadata *) metadataByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andId: (NSNumber *) id{
    return [self metadataByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName andId:id];
}

-(GPKGGeometryMetadata *) metadataByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andId: (NSNumber *) id{
    
    GPKGGeometryMetadata * metadata = nil;
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_GPGM_COLUMN_GEOPACKAGE_ID withValue:geoPackageId];
    [values addColumn:GPKG_GPGM_COLUMN_TABLE_NAME withValue:tableName];
    [values addColumn:GPKG_GPGM_COLUMN_ID withValue:id];
    
    GPKGResultSet * results = [self queryForFieldValues:values];
    @try{
        if([results moveToNext]){
            metadata = (GPKGGeometryMetadata *) [self object:results];
        }
    }@finally{
        [results close];
    }
    
    return metadata;
}

-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName{
    return [self queryByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName];
}

-(int) countByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName{
    return [self countByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName];
}

-(GPKGBoundingBox *) boundingBoxByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName{
    return [self boundingBoxByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName];
}

-(GPKGBoundingBox *) boundingBoxByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName{
    
    NSString *sql = [NSString stringWithFormat:@"SELECT MIN(%@), MIN(%@), MAX(%@), MAX(%@) FROM %@ WHERE %@ = ? AND %@ = ?", GPKG_GPGM_COLUMN_MIN_X, GPKG_GPGM_COLUMN_MIN_Y, GPKG_GPGM_COLUMN_MAX_X, GPKG_GPGM_COLUMN_MAX_Y, GPKG_GPGM_TABLE_NAME, GPKG_GPGM_COLUMN_GEOPACKAGE_ID, GPKG_GPGM_COLUMN_TABLE_NAME];
    NSArray *args = [[NSArray alloc] initWithObjects:[geoPackageId stringValue], tableName, nil];
    NSArray *dataTypes = [[NSArray alloc] initWithObjects:[[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], [[NSNumber alloc] initWithInt:GPKG_DT_DOUBLE], nil];
    
    NSArray<NSNumber *> *results = (NSArray<NSNumber *> *) [self querySingleRowResultsWithSql:sql andArgs:args andDataTypes:dataTypes];
    
    double minLongitude = [[results objectAtIndex:0] doubleValue];
    double minLatitude = [[results objectAtIndex:1] doubleValue];
    double maxLongitude = [[results objectAtIndex:2] doubleValue];
    double maxLatitude = [[results objectAtIndex:3] doubleValue];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
    
    return boundingBox;
}

-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName{
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_GPGM_COLUMN_GEOPACKAGE_ID withValue:geoPackageId];
    [values addColumn:GPKG_GPGM_COLUMN_TABLE_NAME withValue:tableName];
    
    GPKGResultSet * results = [self queryForFieldValues:values];
    return results;
}

-(int) countByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName{
    GPKGResultSet * results = [self queryByGeoPackageId:geoPackageId andTableName:tableName];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self queryByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName andBoundingBox:boundingBox];
}

-(int) countByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox{
    return [self countByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName andBoundingBox:boundingBox];
}

-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox{
    SFGeometryEnvelope * envelope = [[SFGeometryEnvelope alloc] init];
    [envelope setMinX:boundingBox.minLongitude];
    [envelope setMaxX:boundingBox.maxLongitude];
    [envelope setMinY:boundingBox.minLatitude];
    [envelope setMaxY:boundingBox.maxLatitude];
    return [self queryByGeoPackageId:geoPackageId andTableName:tableName andEnvelope:envelope];
}

-(int) countByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andBoundingBox: (GPKGBoundingBox *) boundingBox{
    GPKGResultSet * results = [self queryByGeoPackageId:geoPackageId andTableName:tableName andBoundingBox:boundingBox];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGResultSet *) queryByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self queryByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName andEnvelope:envelope];
}

-(int) countByGeoPackageName: (NSString *) geoPackageName andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope{
    return [self countByGeoPackageId:[self geoPackageIdForGeoPackageName:geoPackageName] andTableName:tableName andEnvelope:envelope];
}

-(GPKGResultSet *) queryByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope{
    
    NSMutableString * where = [[NSMutableString alloc] init];
    [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_GEOPACKAGE_ID andValue:geoPackageId]];
    [where appendString:@" and "];
    [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_TABLE_NAME andValue:tableName]];
    [where appendString:@" and "];
    
    BOOL minXLessThanMaxX = [envelope.minX compare:envelope.maxX] != NSOrderedDescending;
    
    NSDecimalNumber *minX = [[NSDecimalNumber alloc] initWithDouble:[envelope.minX doubleValue] - self.tolerance];
    NSDecimalNumber *maxX = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxX doubleValue] + self.tolerance];
    NSDecimalNumber *minY = [[NSDecimalNumber alloc] initWithDouble:[envelope.minY doubleValue] - self.tolerance];
    NSDecimalNumber *maxY = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxY doubleValue] + self.tolerance];
    
    if(minXLessThanMaxX){
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MIN_X andValue:maxX andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MAX_X andValue:minX andOperation:@">="]];
    }else{
        [where appendString:@"("];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MIN_X andValue:maxX andOperation:@"<="]];
        [where appendString:@" or "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MAX_X andValue:minX andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MIN_X andValue:minX andOperation:@">="]];
        [where appendString:@" or "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MAX_X andValue:maxX andOperation:@"<="]];
        [where appendString:@")"];
    }
    [where appendString:@" and "];
    [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MIN_Y andValue:maxY andOperation:@"<="]];
    [where appendString:@" and "];
    [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MAX_Y andValue:minY andOperation:@">="]];
    
    NSMutableArray * whereArgs = [[NSMutableArray alloc] init];
    [whereArgs addObject:geoPackageId];
    [whereArgs addObject:tableName];
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
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MIN_Z andValue:minZ andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MAX_Z andValue:maxZ andOperation:@">="]];
        [whereArgs addObject:maxZ];
        [whereArgs addObject:minZ];
    }
    
    if(envelope.hasM){
        NSDecimalNumber *minM = [[NSDecimalNumber alloc] initWithDouble:[envelope.minM doubleValue] - self.tolerance];
        NSDecimalNumber *maxM = [[NSDecimalNumber alloc] initWithDouble:[envelope.maxM doubleValue] + self.tolerance];
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MIN_M andValue:minM andOperation:@"<="]];
        [where appendString:@" and "];
        [where appendString:[self buildWhereWithField:GPKG_GPGM_COLUMN_MAX_M andValue:maxM andOperation:@">="]];
        [whereArgs addObject:maxM];
        [whereArgs addObject:minM];
    }
    
    GPKGResultSet * results = [self queryWhere:where andWhereArgs:whereArgs];
    
    return results;
}

-(int) countByGeoPackageId: (NSNumber *) geoPackageId andTableName: (NSString *) tableName andEnvelope: (SFGeometryEnvelope *) envelope{
    GPKGResultSet * results = [self queryByGeoPackageId:geoPackageId andTableName:tableName andEnvelope:envelope];
    int count = results.count;
    [results close];
    return count;
}

-(NSNumber *) geoPackageIdForGeoPackageName: (NSString *) name{
    NSNumber * id  = [NSNumber numberWithInt:-1];
    GPKGGeoPackageMetadataDao * ds = [[GPKGGeoPackageMetadataDao alloc] initWithDatabase:self.database];
    GPKGGeoPackageMetadata * metadata = [ds metadataCreateByName:name];
    if(metadata != nil){
        id = metadata.id;
    }
    return id;
}

@end
