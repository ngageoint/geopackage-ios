//
//  GPKGGeometryIndexDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeometryIndexDao.h"
#import "GPKGTableIndexDao.h"

@implementation GPKGGeometryIndexDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_GI_TABLE_NAME;
        self.idColumns = @[GPKG_GI_COLUMN_PK1, GPKG_GI_COLUMN_PK2];
        self.columns = @[GPKG_GI_COLUMN_TABLE_NAME, GPKG_GI_COLUMN_GEOM_ID, GPKG_GI_COLUMN_MIN_X, GPKG_GI_COLUMN_MAX_X, GPKG_GI_COLUMN_MIN_Y, GPKG_GI_COLUMN_MAX_Y, GPKG_GI_COLUMN_MIN_Z, GPKG_GI_COLUMN_MAX_Z, GPKG_GI_COLUMN_MIN_M, GPKG_GI_COLUMN_MAX_M];
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
            setObject.minX = (NSDecimalNumber *) value;
            break;
        case 3:
            setObject.maxX = (NSDecimalNumber *) value;
            break;
        case 4:
            setObject.minY = (NSDecimalNumber *) value;
            break;
        case 5:
            setObject.maxY = (NSDecimalNumber *) value;
            break;
        case 6:
            setObject.minZ = (NSDecimalNumber *) value;
            break;
        case 7:
            setObject.maxZ = (NSDecimalNumber *) value;
            break;
        case 8:
            setObject.minM = (NSDecimalNumber *) value;
            break;
        case 9:
            setObject.maxM = (NSDecimalNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeometryIndex *getObject = (GPKGGeometryIndex*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.geomId;
            break;
        case 2:
            value = getObject.minX;
            break;
        case 3:
            value = getObject.maxX;
            break;
        case 4:
            value = getObject.minY;
            break;
        case 5:
            value = getObject.maxY;
            break;
        case 6:
            value = getObject.minZ;
            break;
        case 7:
            value = getObject.maxZ;
            break;
        case 8:
            value = getObject.minM;
            break;
        case 9:
            value = getObject.maxM;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGTableIndex *) getTableIndex: (GPKGGeometryIndex *) geometryIndex{
    GPKGTableIndexDao * dao = [self getTableIndexDao];
    GPKGTableIndex *tableIndex = (GPKGTableIndex *)[dao queryForIdObject:geometryIndex.tableName];
    return tableIndex;
}

-(GPKGTableIndexDao *) getTableIndexDao{
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

-(GPKGGeometryIndex *) populateWithTableIndex: (GPKGTableIndex *) tableIndex andGeomId: (int) geomId andGeometryEnvelope: (WKBGeometryEnvelope *) envelope{
    
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

@end
