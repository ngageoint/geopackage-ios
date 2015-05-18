//
//  GPKGGeometryColumnsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryColumnsDao.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGContentsDao.h"

@implementation GPKGGeometryColumnsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GC_TABLE_NAME;
        self.idColumns = @[GC_COLUMN_TABLE_NAME, GC_COLUMN_COLUMN_NAME];
        self.columns = @[GC_COLUMN_TABLE_NAME, GC_COLUMN_COLUMN_NAME, GC_COLUMN_GEOMETRY_TYPE_NAME, GC_COLUMN_SRS_ID, GC_COLUMN_Z, GC_COLUMN_M];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGGeometryColumns alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGGeometryColumns *setObject = (GPKGGeometryColumns*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.columnName = (NSString *) value;
            break;
        case 2:
            setObject.geometryTypeName = (NSString *) value;
            break;
        case 3:
            setObject.srsId = (NSNumber *) value;
            break;
        case 4:
            setObject.z = (NSNumber *) value;
            break;
        case 5:
            setObject.m = (NSNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGGeometryColumns *getObject = (GPKGGeometryColumns*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.tableName;
            break;
        case 1:
            value = getObject.columnName;
            break;
        case 2:
            value = getObject.geometryTypeName;
            break;
        case 3:
            value = getObject.srsId;
            break;
        case 4:
            value = getObject.z;
            break;
        case 5:
            value = getObject.m;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGGeometryColumns *) queryForTableName: (NSString *) tableName{
    
    GPKGGeometryColumns *geometryColumns = nil;
    
    GPKGResultSet * result = [self queryForEqWithField:GC_COLUMN_TABLE_NAME andValue:tableName];
    if([result moveToNext]){
        geometryColumns = (GPKGGeometryColumns *) [self getObject:result];
    }
    [result close];
    
    return geometryColumns;
}

-(NSArray *) getFeatureTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GC_COLUMN_TABLE_NAME, GC_TABLE_NAME];
    
    GPKGResultSet *results = [self rawQuery:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGGeometryColumns *) geometryColumns{
    GPKGSpatialReferenceSystemDao * dao = [self getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForId:geometryColumns.srsId];
    return srs;
}

-(GPKGContents *) getContents: (GPKGGeometryColumns *) geometryColumns{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForId:geometryColumns.tableName];
    return contents;
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
