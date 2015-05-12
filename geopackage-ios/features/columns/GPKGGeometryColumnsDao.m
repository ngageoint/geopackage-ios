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
    
    GPKGResultSet *results = [self query:queryString];
    NSArray *tables = [self singleColumnResults:results];
    [results close];
    
    return tables;
}

-(NSString *) getTableName{
    return GC_TABLE_NAME;
}

-(NSArray *) getIdColumns{
    NSArray *idColumns = @[GC_COLUMN_TABLE_NAME, GC_COLUMN_COLUMN_NAME];
    return idColumns;
}

-(NSObject *) createObjectWithColumns: (NSArray *)columns andValues: (NSArray *) values{
    GPKGGeometryColumns *objectResult = [[GPKGGeometryColumns alloc] init];
    objectResult.tableName = [values objectAtIndex:[columns indexOfObject:GC_COLUMN_TABLE_NAME]];
    objectResult.columnName = [values objectAtIndex:[columns indexOfObject:GC_COLUMN_COLUMN_NAME]];
    objectResult.geometryTypeName = [values objectAtIndex:[columns indexOfObject:GC_COLUMN_GEOMETRY_TYPE_NAME]];
    objectResult.srsId = [values objectAtIndex:[columns indexOfObject:GC_COLUMN_SRS_ID]];
    objectResult.z = [values objectAtIndex:[columns indexOfObject:GC_COLUMN_Z]];
    objectResult.m = [values objectAtIndex:[columns indexOfObject:GC_COLUMN_M]];
    return objectResult;
}

@end
