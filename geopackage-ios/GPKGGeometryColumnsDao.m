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
        
    }
    return self;
}

-(NSArray *)getFeatureTables{
    
    NSString *queryString = [NSString stringWithFormat:@"select %@ from %@", GC_COLUMN_TABLE_NAME, GC_TABLE_NAME];
    
    NSArray *results = [self query:queryString];
    NSArray *tables = [self singleColumnResults:results];
    
    return tables;
}

-(NSString *) tableName{
    return GC_TABLE_NAME;
}

-(NSObject *) create: (NSArray *) values{
    GPKGGeometryColumns *objectResult = [[GPKGGeometryColumns alloc] init];
    objectResult.tableName = [values objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_TABLE_NAME]];
    objectResult.columnName = [values objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_COLUMN_NAME]];
    objectResult.geometryTypeName = [values objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_GEOMETRY_TYPE_NAME]];
    objectResult.srsId = [values objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_SRS_ID]];
    objectResult.z = [values objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_Z]];
    objectResult.m = [values objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_M]];
    return objectResult;
}

@end
