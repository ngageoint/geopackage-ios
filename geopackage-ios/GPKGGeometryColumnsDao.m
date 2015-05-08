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
    
    NSString *queryString = @"select table_name from gpkg_geometry_columns";
    
    NSArray *results = [self query:queryString];
    NSMutableArray *tables = [self singleColumnResults:results];
    
    return tables;
}

@end
