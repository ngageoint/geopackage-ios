//
//  GPKGGeometryColumnsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeometryColumnsDao.h"

@implementation GPKGGeometryColumnsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GC_TABLE_NAME;
        self.idColumns = @[GC_COLUMN_TABLE_NAME, GC_COLUMN_COLUMN_NAME];
        self.columns = @[GC_COLUMN_TABLE_NAME, GC_COLUMN_COLUMN_NAME, GC_COLUMN_GEOMETRY_TYPE_NAME, GC_COLUMN_SRS_ID, GC_COLUMN_Z, GC_COLUMN_M];
        [self.columnIndex setObject:[NSNumber numberWithInt:1] forKey:GC_COLUMN_TABLE_NAME];
        [self.columnIndex setObject:[NSNumber numberWithInt:2] forKey:GC_COLUMN_COLUMN_NAME];
        [self.columnIndex setObject:[NSNumber numberWithInt:3] forKey:GC_COLUMN_GEOMETRY_TYPE_NAME];
        [self.columnIndex setObject:[NSNumber numberWithInt:4] forKey:GC_COLUMN_SRS_ID];
        [self.columnIndex setObject:[NSNumber numberWithInt:5] forKey:GC_COLUMN_Z];
        [self.columnIndex setObject:[NSNumber numberWithInt:6] forKey:GC_COLUMN_M];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGGeometryColumns alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGGeometryColumns *setObject = (GPKGGeometryColumns*) object;
    
    switch(columnIndex){
        case 1:
            setObject.tableName = (NSString *) value;
            break;
        case 2:
            setObject.columnName = (NSString *) value;
            break;
        case 3:
            setObject.geometryTypeName = (NSString *) value;
            break;
        case 4:
            setObject.srsId = (NSNumber *) value;
            break;
        case 5:
            setObject.z = (NSNumber *) value;
            break;
        case 6:
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
        case 1:
            value = getObject.tableName;
            break;
        case 2:
            value = getObject.columnName;
            break;
        case 3:
            value = getObject.geometryTypeName;
            break;
        case 4:
            value = getObject.srsId;
            break;
        case 5:
            value = getObject.z;
            break;
        case 6:
            value = getObject.m;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(NSArray *)getFeatureTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GC_COLUMN_TABLE_NAME, GC_TABLE_NAME];
    
    GPKGResultSet *results = [self rawQuery:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

@end
