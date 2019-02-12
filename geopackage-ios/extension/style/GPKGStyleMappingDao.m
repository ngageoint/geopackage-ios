//
//  GPKGStyleMappingDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleMappingDao.h"

@implementation GPKGStyleMappingDao

-(instancetype) initWithDao: (GPKGUserCustomDao *) dao{
    self = [self initWithDao:dao andTable:[[GPKGStyleMappingTable alloc] initWithTable:[dao table]]];
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGStyleMappingTable *) table{
    return (GPKGStyleMappingTable *)[super table];
}

-(GPKGStyleMappingRow *) row: (GPKGResultSet *) results{
    return (GPKGStyleMappingRow *) [self getRow:results];
}

-(GPKGStyleMappingRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGStyleMappingRow alloc] initWithStyleMappingTable:[self table] andColumnTypes:columnTypes andValues:values];
}

-(GPKGStyleMappingRow *) newRow{
    return [[GPKGStyleMappingRow alloc] initWithStyleMappingTable:[self table]];
}

-(NSArray<GPKGStyleMappingRow *> *) queryByBaseFeatureId: (int) id{
    NSMutableArray *rows = [[NSMutableArray alloc] init];
    GPKGResultSet *resultSet = [self queryByBaseId:id];
    @try{
        while([resultSet moveToNext]){
            [rows addObject:[self row:resultSet]];
        }
    }@finally{
        [resultSet close];
    }
    return rows;
}

-(int) deleteByBaseId: (int) id andGeometryType: (enum SFGeometryType) geometryType{
    
    NSString *geometryTypeName = nil;
    if (geometryType != SF_NONE && geometryType >= 0) {
        geometryTypeName = [SFGeometryTypes name:geometryType];
    }
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_UMT_COLUMN_BASE_ID withValue:[NSNumber numberWithInt:id]];
    [values addColumn:GPKG_SMT_COLUMN_GEOMETRY_TYPE_NAME withValue:geometryTypeName];
    
    NSString * where = [self buildWhereWithFields:values];
    NSArray * whereArgs = [self buildWhereArgsWithValues:values];
    
    int deleted = [self deleteWhere:where andWhereArgs:whereArgs];
    
    return deleted;
}

@end
