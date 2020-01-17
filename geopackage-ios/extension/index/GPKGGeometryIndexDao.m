//
//  GPKGGeometryIndexDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeometryIndexDao.h"
#import "GPKGTableIndexDao.h"
#import "GPKGUtils.h"

@implementation GPKGGeometryIndexDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_GI_TABLE_NAME;
        self.idColumns = @[GPKG_GI_COLUMN_PK1, GPKG_GI_COLUMN_PK2];
        self.columnNames = @[GPKG_GI_COLUMN_TABLE_NAME, GPKG_GI_COLUMN_GEOM_ID, GPKG_GI_COLUMN_MIN_X, GPKG_GI_COLUMN_MAX_X, GPKG_GI_COLUMN_MIN_Y, GPKG_GI_COLUMN_MAX_Y, GPKG_GI_COLUMN_MIN_Z, GPKG_GI_COLUMN_MAX_Z, GPKG_GI_COLUMN_MIN_M, GPKG_GI_COLUMN_MAX_M];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGGeometryIndex alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGGeometryIndex *setObject = (GPKGGeometryIndex*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.geomId = (NSNumber *) value;
            break;
        case 2:
            setObject.minX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 3:
            setObject.maxX = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 4:
            setObject.minY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 5:
            setObject.maxY = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 6:
            setObject.minZ = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 7:
            setObject.maxZ = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 8:
            setObject.minM = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 9:
            setObject.maxM = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeometryIndex *index = (GPKGGeometryIndex*) object;
    
    switch(columnIndex){
        case 0:
            value = index.tableName;
            break;
        case 1:
            value = index.geomId;
            break;
        case 2:
            value = index.minX;
            break;
        case 3:
            value = index.maxX;
            break;
        case 4:
            value = index.minY;
            break;
        case 5:
            value = index.maxY;
            break;
        case 6:
            value = index.minZ;
            break;
        case 7:
            value = index.maxZ;
            break;
        case 8:
            value = index.minM;
            break;
        case 9:
            value = index.maxM;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGTableIndex *) tableIndex: (GPKGGeometryIndex *) geometryIndex{
    GPKGTableIndexDao * dao = [self tableIndexDao];
    GPKGTableIndex *tableIndex = (GPKGTableIndex *)[dao queryForIdObject:geometryIndex.tableName];
    return tableIndex;
}

-(GPKGTableIndexDao *) tableIndexDao{
    return [[GPKGTableIndexDao alloc] initWithDatabase:self.database];
}

-(GPKGResultSet *) queryForTableName: (NSString *) tableName{
    GPKGResultSet * results = [self queryForEqWithField:GPKG_GI_COLUMN_TABLE_NAME andValue:tableName];
    return results;
}

-(int) countByTableName: (NSString *) tableName{
    GPKGResultSet * results = [self queryForTableName:tableName];
    int count = results.count;
    [results close];
    return count;
}

-(GPKGGeometryIndex *) populateWithTableIndex: (GPKGTableIndex *) tableIndex andGeomId: (int) geomId andGeometryEnvelope: (SFGeometryEnvelope *) envelope{
    
    GPKGGeometryIndex * geometryIndex = [[GPKGGeometryIndex alloc] init];
    [geometryIndex setTableIndex:tableIndex];
    [geometryIndex setGeomId:[NSNumber numberWithInt:geomId]];
    [geometryIndex setMinX:envelope.minX];
    [geometryIndex setMaxX:envelope.maxX];
    [geometryIndex setMinY:envelope.minY];
    [geometryIndex setMaxY:envelope.maxY];
    if(envelope.hasZ){
        [geometryIndex setMinZ:envelope.minZ];
        [geometryIndex setMaxZ:envelope.maxZ];
    }
    if(envelope.hasM){
        [geometryIndex setMinM:envelope.minM];
        [geometryIndex setMaxM:envelope.maxM];
    }
    return geometryIndex;
}

-(int) deleteAll{
    
    int count = 0;
    
    if([self tableExists]){
        count = [super deleteAll];
    }
    
    return count;
}

@end
