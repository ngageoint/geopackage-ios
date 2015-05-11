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

-(BOOL) isTableExists{
    
    NSString *queryString = [NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'", GC_TABLE_NAME];
    
    NSArray *results = [self query:queryString];
    NSInteger count = [results count];
    
    return count > 0;
}

-(NSArray *) queryForAll{
    
    NSString *queryString = [NSString stringWithFormat:@"select * from %@", GC_TABLE_NAME];
    
    NSArray *results = [self query:queryString];
    
    NSMutableArray *objectResults = [[NSMutableArray alloc] init];
    for(NSArray *result in results){
        GPKGGeometryColumns *objectResult = [[GPKGGeometryColumns alloc] init];
        objectResult.tableName = [result objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_TABLE_NAME]];
        objectResult.columnName = [result objectAtIndex:[self.database.arrColumnNames indexOfObject:GC_COLUMN_COLUMN_NAME]];
        [objectResults addObject: objectResult];
    }
    
    return objectResults;
}

@end
