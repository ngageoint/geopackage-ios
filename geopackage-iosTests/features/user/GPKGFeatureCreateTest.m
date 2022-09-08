//
//  GPKGFeatureCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/27/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGFeatureCreateTest.h"
#import "GPKGFeatureUtils.h"
#import "PROJProjectionConstants.h"
#import "GPKGSqlUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGFeatureCreateTest

-(void) testCreate{
    [GPKGFeatureUtils testCreateWithGeoPackage:self.geoPackage];
}

-(void) testDelete{
    [GPKGFeatureUtils testDeleteWithGeoPackage:self.geoPackage];
}

-(void) testPkModifiableAndValueValidation{
    [GPKGFeatureUtils testPkModifiableAndValueValidationWithGeoPackage:self.geoPackage];
}

-(void) testColumnNameWithFrom{
    
    NSString *columnTestName = @"convertFrom";
    
     GPKGSpatialReferenceSystem *srs = [[self.geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
     
     GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
     [geometryColumns setTableName:@"test_table"];
     [geometryColumns setColumnName:@"geom"];
     [geometryColumns setGeometryType:SF_GEOMETRY];
     [geometryColumns setZ:[NSNumber numberWithInt:0]];
     [geometryColumns setM:[NSNumber numberWithInt:0]];
     [geometryColumns setSrs:srs];
     
     NSMutableArray *additionalColumns = [NSMutableArray array];
     [additionalColumns addObject:[GPKGFeatureColumn createColumnWithName:columnTestName andDataType:GPKG_DT_TEXT]];
     
     GPKGFeatureTable *table = [self.geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andAdditionalColumns:additionalColumns]];
    
    GPKGFeatureDao *dao = [self.geoPackage featureDaoWithTable:table];
    
    GPKGFeatureRow *newRow = [dao newRow];
    
    NSString *value = @"test";
    [newRow setValueWithColumnName:columnTestName andValue:value];
    
    [dao create:newRow];
    
    NSString *statment = [NSString stringWithFormat:@"select \"%@\", \"%@\" from \"%@\" where \"%@\" = ?", [table idColumnName], columnTestName, table.tableName, columnTestName];
    NSArray *args = [NSArray arrayWithObject:value];
    GPKGResultSet *resultSet = [dao rawQuery:statment andArgs:args];
    int count = resultSet.count;
    [resultSet close];
    
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:count];
    
}

@end
