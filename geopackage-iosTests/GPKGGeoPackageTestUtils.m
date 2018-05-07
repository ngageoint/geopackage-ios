//
//  GPKGGeoPackageTestUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/16/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestUtils.h"
#import "GPKGUtils.h"
#import "GPKGTestUtils.h"

@implementation GPKGGeoPackageTestUtils

+(void)testCreateFeatureTableWithMetadata: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata"];
    [geometryColumns setColumnName:@"geom"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    GPKGSpatialReferenceSystem * srs = [[geoPackage getSpatialReferenceSystemDao] createWebMercator];
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:nil];
}

+(void)testCreateFeatureTableWithMetadataIdColumn: (GPKGGeoPackage *) geoPackage{

    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata2"];
    [geometryColumns setColumnName:@"geom2"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    GPKGSpatialReferenceSystem * srs = [[geoPackage getSpatialReferenceSystemDao] createWebMercator];
    NSString * idColumn = @"my_id";
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:idColumn andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:nil];
}

+(void)testCreateFeatureTableWithMetadataAdditionalColumns: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata3"];
    [geometryColumns setColumnName:@"geom3"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSArray * additionalColumns = [self getFeatureColumns];
    
    GPKGSpatialReferenceSystem * srs = [[geoPackage getSpatialReferenceSystemDao] createWebMercator];
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andAdditionalColumns:additionalColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:nil andAdditionalColumns:additionalColumns];
}

+(void)testCreateFeatureTableWithMetadataIdColumnAdditionalColumns: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumns * geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:@"feature_metadata4"];
    [geometryColumns setColumnName:@"geom4"];
    [geometryColumns setGeometryType:SF_POINT];
    [geometryColumns setZ:[NSNumber numberWithInt:1]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-90 andMinLatitudeDouble:-45 andMaxLongitudeDouble:90 andMaxLatitudeDouble:45];
    
    NSArray * additionalColumns = [self getFeatureColumns];
    
    GPKGSpatialReferenceSystem * srs = [[geoPackage getSpatialReferenceSystemDao] createWebMercator];
    NSString * idColumn = @"my_other_id";
    geometryColumns = [geoPackage createFeatureTableWithGeometryColumns:geometryColumns andIdColumnName:idColumn andAdditionalColumns:additionalColumns andBoundingBox:boundingBox andSrsId:srs.srsId];
    
    [self validateFeatureTableWithMetadata:geoPackage andGeometryColumns:geometryColumns andIdColumn:idColumn andAdditionalColumns:additionalColumns];
}

+(NSArray *) getFeatureColumns{
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:7 andName:@"test_text_limited" andDataType:GPKG_DT_TEXT andMax: [NSNumber numberWithInt:5] andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:8 andName:@"test_blob_limited" andDataType:GPKG_DT_BLOB andMax: [NSNumber numberWithInt:7] andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:9 andName:@"test_date" andDataType:GPKG_DT_DATE andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:10 andName:@"test_datetime" andDataType:GPKG_DT_DATETIME andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:2 andName:@"test_text" andDataType:GPKG_DT_TEXT andNotNull:false andDefaultValue:@""] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:3 andName:@"test_real" andDataType:GPKG_DT_REAL andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:4 andName:@"test_boolean" andDataType:GPKG_DT_BOOLEAN andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:5 andName:@"test_blob" andDataType:GPKG_DT_BLOB andNotNull:false andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGFeatureColumn createColumnWithIndex:6 andName:@"test_integer" andDataType:GPKG_DT_INTEGER andNotNull:false andDefaultValue:nil] toArray:columns];
    
    return columns;
}

+(void) validateFeatureTableWithMetadata: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andIdColumn: (NSString *) idColumn andAdditionalColumns: (NSArray *) additionalColumns{
    
    GPKGGeometryColumnsDao * dao = [geoPackage getGeometryColumnsDao];
    
    GPKGGeometryColumns * queryGeometryColumns = (GPKGGeometryColumns *)[dao queryForMultiIdObject:[dao getMultiId:geometryColumns]];
    [GPKGTestUtils assertNotNil:queryGeometryColumns];
    
    [GPKGTestUtils assertEqualWithValue:geometryColumns.tableName andValue2:queryGeometryColumns.tableName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.columnName andValue2:queryGeometryColumns.columnName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.geometryTypeName andValue2:queryGeometryColumns.geometryTypeName];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.z andValue2:queryGeometryColumns.z];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.m andValue2:queryGeometryColumns.m];
    
    GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:geometryColumns.tableName];
    GPKGFeatureRow * featureRow = [featureDao newRow];
    
    [GPKGTestUtils assertEqualIntWithValue:(2 + (additionalColumns != nil ? (int)[additionalColumns count] : 0)) andValue2:[featureRow columnCount]];
    if(idColumn == nil){
        idColumn = @"id";
    }
    [GPKGTestUtils assertEqualWithValue:idColumn andValue2:[featureRow getColumnNameWithIndex:0]];
    [GPKGTestUtils assertEqualWithValue:geometryColumns.columnName andValue2:[featureRow getColumnNameWithIndex:1]];
    
    if(additionalColumns != nil){
        [GPKGTestUtils assertEqualWithValue:@"test_text" andValue2:[featureRow getColumnNameWithIndex:2]];
        [GPKGTestUtils assertEqualWithValue:@"test_real" andValue2:[featureRow getColumnNameWithIndex:3]];
        [GPKGTestUtils assertEqualWithValue:@"test_boolean" andValue2:[featureRow getColumnNameWithIndex:4]];
        [GPKGTestUtils assertEqualWithValue:@"test_blob" andValue2:[featureRow getColumnNameWithIndex:5]];
        [GPKGTestUtils assertEqualWithValue:@"test_integer" andValue2:[featureRow getColumnNameWithIndex:6]];
        [GPKGTestUtils assertEqualWithValue:@"test_text_limited" andValue2:[featureRow getColumnNameWithIndex:7]];
        [GPKGTestUtils assertEqualWithValue:@"test_blob_limited" andValue2:[featureRow getColumnNameWithIndex:8]];
        [GPKGTestUtils assertEqualWithValue:@"test_date" andValue2:[featureRow getColumnNameWithIndex:9]];
        [GPKGTestUtils assertEqualWithValue:@"test_datetime" andValue2:[featureRow getColumnNameWithIndex:10]];
    }
}

@end
