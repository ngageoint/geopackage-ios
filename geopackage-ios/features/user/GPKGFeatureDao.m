//
//  GPKGFeatureDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureDao.h"
#import "GPKGGeometryColumnsDao.h"

@implementation GPKGFeatureDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGFeatureTable *) table andGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    self = [super initWithDatabase:database andTable:table];
    if(self != nil){
        self.geometryColumns = geometryColumns;
        GPKGGeometryColumnsDao * dao = [self getGeometryColumnsDao];
        if([dao getContents:geometryColumns] == nil){
            [NSException raise:@"Missing Contents" format:@"Geometry Columns %@ has null Contents", [dao getId:geometryColumns]];
        }
        if([dao getSrs:geometryColumns] == nil){
            [NSException raise:@"Missing SRS" format:@"Geometry Columns %@ has null Spatial Reference System", [dao getId:geometryColumns]];
        }
        
        self.projection = [dao getProjection:geometryColumns];
    }
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGFeatureTable *) getFeatureTable{
    return (GPKGFeatureTable *) self.table;
}

-(GPKGFeatureRow *) getFeatureRow: (GPKGResultSet *) results{
    return (GPKGFeatureRow *) [self getRow:results];
}

-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGFeatureRow alloc] initWithFeatureTable:[self getFeatureTable] andColumnTypes:columnTypes andValues:values];
}

-(GPKGFeatureRow *) newRow{
    return [[GPKGFeatureRow alloc] initWithTable:self.table];
}

-(NSString *) getGeometryColumnName{
    return self.geometryColumns.columnName;
}

-(enum WKBGeometryType) getGeometryType{
    return [self.geometryColumns getGeometryType];
}

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}

@end
