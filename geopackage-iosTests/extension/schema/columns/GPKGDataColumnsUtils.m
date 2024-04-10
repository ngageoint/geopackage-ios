//
//  GPKGDataColumnsUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/24.
//  Copyright © 2024 NGA. All rights reserved.
//

#import "GPKGDataColumnsUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageTestUtils.h"
#import "GPKGSchemaExtension.h"
#import "PROJProjectionConstants.h"

@implementation GPKGDataColumnsUtils

+(void) testColumnTitles: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    [schemaExtension createDataColumnsTable];
    GPKGDataColumnsDao *dao = [schemaExtension dataColumnsDao];
    [GPKGTestUtils assertTrue:[dao tableExists]];
    
    int count = [dao count];
    
    NSArray<GPKGFeatureColumn *> *columns = [GPKGGeoPackageTestUtils featureColumns];
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"features"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_GEOMETRY];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox *boundingBox = [GPKGBoundingBox worldWGS84];
    GPKGFeatureTableMetadata *metadata = [GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andAdditionalColumns:columns andBoundingBox:boundingBox];
    GPKGFeatureTable *table = [geoPackage createFeatureTableWithMetadata:metadata];
    GPKGContents *contents = table.contents;
    
    for(GPKGFeatureColumn *column in columns){
        GPKGDataColumns *dataColumns = [[GPKGDataColumns alloc] init];
        [dataColumns setContents:contents];
        [dataColumns setColumnName:column.name];
        [dataColumns setName:[NSString stringWithFormat:@"%@ title", column.name]];
        [dataColumns setTitle:[NSString stringWithFormat:@"%@ title", column.name]];
        [dao create:dataColumns];
    }
    
    int newCount = [dao count];
    [GPKGTestUtils assertEqualIntWithValue:count + (int)columns.count andValue2:newCount];
    
    for(GPKGFeatureColumn *column in columns){
        
        GPKGDataColumns *dataColumns = [dao dataColumnByTableName:[table tableName] andColumnName:column.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:dataColumns.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:dataColumns.title];
        
    }
    
}

+(void) testSaveLoadSchema: (GPKGGeoPackage *) geoPackage{
    
    GPKGSpatialReferenceSystemDao *srsDao = [geoPackage spatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGSchemaExtension *schemaExtension = [[GPKGSchemaExtension alloc] initWithGeoPackage:geoPackage];
    [schemaExtension removeExtension];
    
    GPKGDataColumnsDao *dao = [schemaExtension dataColumnsDao];
    [GPKGTestUtils assertFalse:[dao tableExists]];
    
    NSArray<GPKGFeatureColumn *> *columns = [GPKGGeoPackageTestUtils featureColumns];
    for(GPKGFeatureColumn *column in columns){
        GPKGDataColumns *dataColumns = [[GPKGDataColumns alloc] init];
        [dataColumns setName:[NSString stringWithFormat:@"%@ title", column.name]];
        [dataColumns setTitle:[NSString stringWithFormat:@"%@ title", column.name]];
        [column setSchema:dataColumns];
    }
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"features"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_GEOMETRY];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox *boundingBox = [GPKGBoundingBox worldWGS84];
    GPKGFeatureTableMetadata *metadata = [GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andAdditionalColumns:columns andBoundingBox:boundingBox];
    GPKGFeatureTable *table = [geoPackage createFeatureTableWithMetadata:metadata];
    
    [GPKGTestUtils assertTrue:[dao tableExists]];
    int newCount = [dao count];
    [GPKGTestUtils assertEqualIntWithValue:(int)columns.count andValue2:newCount];
    
    for(GPKGFeatureColumn *column in columns){
        
        GPKGDataColumns *dataColumns = [dao dataColumnByTableName:[table tableName] andColumnName:column.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:dataColumns.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:dataColumns.title];
        
    }
    
    GPKGFeatureTable *table2 = [[geoPackage featureDaoWithTableName:[table tableName]] featureTable];
    
    for(GPKGFeatureColumn *column in columns){
        GPKGFeatureColumn *column2 = (GPKGFeatureColumn *)[table2 columnWithColumnName:column.name];
        GPKGDataColumns *schema = column2.schema;
        [GPKGTestUtils assertNotNil:schema];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:schema.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:schema.title];
        GPKGDataColumns *schema2 = [dao schemaByTable:[table tableName] andColumn:column.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:schema2.name];
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%@ title", column.name] andValue2:schema2.title];
    }
    
}

@end
