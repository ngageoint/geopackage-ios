//
//  GPKGCrsWktExtensionTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGCrsWktExtensionTest.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGTestUtils.h"
#import "PROJProjectionConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

@implementation GPKGCrsWktExtensionTest

/**
 * Test the Extension version 1
 */
-(void) testVersion1{
    [self testExtension:GPKG_CRS_WKT_V_1];
}

/**
 * Test the Extension version 1.1
 */
-(void) testVersion1_1{
    [self testExtension:GPKG_CRS_WKT_V_1_1];
}

/**
 * Test the Extension latest version
 */
-(void) testLatestVersion{
    [self testExtension:-1];
}

/**
 * Test the extension for the version
 *
 * @param version
 *            extension version
 */
-(void) testExtension: (enum GPKGCrsWktExtensionVersion) version{
    
    GPKGSpatialReferenceSystemDao *srsDao = [self.geoPackage spatialReferenceSystemDao];
    
    GPKGCrsWktExtension *wktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:self.geoPackage];
    [GPKGTestUtils assertFalse:[wktExtension has]];
    if(version != -1){
        [GPKGTestUtils assertFalse:[wktExtension hasVersion:version]];
        [GPKGTestUtils assertFalse:[wktExtension hasMinimum:version]];
    }
    
    // Test querying and setting the definitions before the column exists
    GPKGSpatialReferenceSystem *wgs84Srs = [srsDao srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [GPKGTestUtils assertNotNil:wgs84Srs];
    [GPKGTestUtils assertNil:wgs84Srs.definition_12_063];
    [GPKGTestUtils assertNil:wgs84Srs.epoch];
    [srsDao setExtensionWithSrs:wgs84Srs];
    [GPKGTestUtils assertNil:wgs84Srs.definition_12_063];
    [GPKGTestUtils assertNil:wgs84Srs.epoch];
    
    GPKGSpatialReferenceSystem *undefinedCartesianSrs = [srsDao srsWithOrganization:PROJ_AUTHORITY_NONE andCoordsysId:[NSNumber numberWithInt:PROJ_UNDEFINED_CARTESIAN]];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.definition_12_063];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.epoch];
    [srsDao setExtensionWithSrs:undefinedCartesianSrs];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.definition_12_063];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.epoch];
    
    GPKGSpatialReferenceSystem *undefinedGeographicSrs = [srsDao srsWithOrganization:PROJ_AUTHORITY_NONE andCoordsysId:[NSNumber numberWithInt:PROJ_UNDEFINED_GEOGRAPHIC]];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.definition_12_063];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.epoch];
    [srsDao setExtensionWithSrs:undefinedGeographicSrs];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.definition_12_063];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.epoch];
    
    // Create a new SRS
    GPKGSpatialReferenceSystem *newSrs = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs setSrsName:@"name"];
    [newSrs setSrsId:[NSNumber numberWithInt:1234]];
    [newSrs setOrganization:@"organization"];
    [newSrs setOrganizationCoordsysId:[NSNumber numberWithInt:1234]];
    [newSrs setDefinition:@"definition"];
    [newSrs setTheDescription:@"description"];
    [srsDao create:newSrs];
    newSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs.srsId];
    [GPKGTestUtils assertNotNil:newSrs];
    [GPKGTestUtils assertNil:newSrs.definition_12_063];
    [GPKGTestUtils assertNil:newSrs.epoch];
    [srsDao setExtensionWithSrs:newSrs];
    [GPKGTestUtils assertNil:newSrs.definition_12_063];
    [GPKGTestUtils assertNil:newSrs.epoch];
    
    // Create the extension
    NSArray<GPKGExtensions *> *extensions = nil;
    if(version != -1){
        extensions = [wktExtension extensionCreateVersion:version];
    }else{
        extensions = [wktExtension extensionCreate];
    }
    [GPKGTestUtils assertTrue:[wktExtension has]];
    if(version != -1){
        [GPKGTestUtils assertTrue:[wktExtension hasVersion:version]];
        [GPKGTestUtils assertTrue:[wktExtension hasMinimum:version]];
    }
    GPKGExtensions *extension = [extensions objectAtIndex:0];
    [GPKGTestUtils assertNotNil:extension];
    [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:@"gpkg_crs_wkt"];
    [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:@"gpkg"];
    [GPKGTestUtils assertEqualWithValue:[extension extensionNameNoAuthor] andValue2:@"crs_wkt"];
    [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:@"gpkg_spatial_ref_sys"];
    [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:@"definition_12_063"];
    [GPKGTestUtils assertEqualWithValue:extension.scope andValue2:GPKG_EST_READ_WRITE_NAME];
    [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:[GPKGProperties valueOfProperty:@"geopackage.extensions.crs_wkt"]];
    if(version == -1 || [GPKGCrsWktExtensionVersions isVersion:version atMinimum:GPKG_CRS_WKT_V_1_1]){
        extension = [extensions objectAtIndex:1];
        [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:@"gpkg_crs_wkt_1_1"];
        [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:@"gpkg"];
        [GPKGTestUtils assertEqualWithValue:[extension extensionNameNoAuthor] andValue2:@"crs_wkt_1_1"];
        [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:@"gpkg_spatial_ref_sys"];
        [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:@"definition_12_063"];
        [GPKGTestUtils assertEqualWithValue:extension.scope andValue2:GPKG_EST_READ_WRITE_NAME];
        [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:[GPKGProperties valueOfProperty:@"geopackage.extensions.crs_wkt_1_1"]];
        extension = [extensions objectAtIndex:2];
        [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:@"gpkg_crs_wkt_1_1"];
        [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:@"gpkg"];
        [GPKGTestUtils assertEqualWithValue:[extension extensionNameNoAuthor] andValue2:@"crs_wkt_1_1"];
        [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:@"gpkg_spatial_ref_sys"];
        [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:@"epoch"];
        [GPKGTestUtils assertEqualWithValue:extension.scope andValue2:GPKG_EST_READ_WRITE_NAME];
        [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:[GPKGProperties valueOfProperty:@"geopackage.extensions.crs_wkt_1_1"]];
    }
    
    // Test querying and setting the definitions after the column exists
    wgs84Srs = [srsDao srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [GPKGTestUtils assertNotNil:wgs84Srs];
    [GPKGTestUtils assertNotNil:wgs84Srs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:wgs84Srs.definition_12_063 andValue2:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [GPKGTestUtils assertNil:wgs84Srs.epoch];
    
    undefinedCartesianSrs = [srsDao srsWithOrganization:PROJ_AUTHORITY_NONE andCoordsysId:[NSNumber numberWithInt:PROJ_UNDEFINED_CARTESIAN]];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:undefinedCartesianSrs.definition_12_063 andValue2:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.epoch];
    
    undefinedGeographicSrs = [srsDao srsWithOrganization:PROJ_AUTHORITY_NONE andCoordsysId:[NSNumber numberWithInt:PROJ_UNDEFINED_GEOGRAPHIC]];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:undefinedGeographicSrs.definition_12_063 andValue2:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.epoch];
    
    
    newSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs.srsId];
    [GPKGTestUtils assertNotNil:newSrs];
    [GPKGTestUtils assertNotNil:newSrs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:newSrs.definition_12_063 andValue2:@""];
    [GPKGTestUtils assertNil:newSrs.epoch];
    
    // Test the get or create auto set
    wgs84Srs = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [GPKGTestUtils assertNotNil:wgs84Srs];
    [GPKGTestUtils assertNotNil:wgs84Srs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:wgs84Srs.definition_12_063 andValue2:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [GPKGTestUtils assertNil:wgs84Srs.epoch];
    
    undefinedCartesianSrs = [srsDao srsWithOrganization:PROJ_AUTHORITY_NONE andCoordsysId:[NSNumber numberWithInt:PROJ_UNDEFINED_CARTESIAN]];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:undefinedCartesianSrs.definition_12_063 andValue2:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.epoch];
    
    undefinedGeographicSrs = [srsDao srsWithOrganization:PROJ_AUTHORITY_NONE andCoordsysId:[NSNumber numberWithInt:PROJ_UNDEFINED_GEOGRAPHIC]];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:undefinedGeographicSrs.definition_12_063 andValue2:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.epoch];
    
    // Create the web mercator srs and test
    GPKGSpatialReferenceSystem *webMercator = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    [GPKGTestUtils assertNotNil:webMercator.definition_12_063];
    [GPKGTestUtils assertNil:webMercator.epoch];
    
    // Read the web mercator srs and test
    GPKGSpatialReferenceSystem *webMercator2 = [srsDao srsWithEpsg:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    [GPKGTestUtils assertNotNil:webMercator2.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:webMercator.definition_12_063 andValue2:webMercator2.definition_12_063];
    [GPKGTestUtils assertNil:webMercator2.epoch];
    
    GPKGSpatialReferenceSystem *newSrs2 = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs2 setSrsName:@"name"];
    [newSrs2 setSrsId:[NSNumber numberWithInt:4321]];
    [newSrs2 setOrganization:@"organization"];
    [newSrs2 setOrganizationCoordsysId:[NSNumber numberWithInt:4321]];
    [newSrs2 setDefinition:@"definition"];
    [newSrs2 setTheDescription:@"description"];
    [newSrs2 setDefinition_12_063:@"definition_12_063"];
    [srsDao create:newSrs2];
    newSrs2 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs2.srsId];
    [GPKGTestUtils assertNotNil:newSrs2];
    [GPKGTestUtils assertNotNil:newSrs2.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:newSrs2.definition_12_063 andValue2:@"definition_12_063"];
    [GPKGTestUtils assertNil:newSrs2.epoch];
    [newSrs2 setDefinition_12_063:nil];
    [srsDao updateExtensionWithSrs:newSrs2];
    newSrs2 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs2.srsId];
    [GPKGTestUtils assertNotNil:newSrs2];
    [GPKGTestUtils assertNotNil:newSrs2.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:newSrs2.definition_12_063 andValue2:@""];
    [newSrs2 setDefinition_12_063:@"definition_12_063 2"];
    [srsDao updateExtensionWithSrs:newSrs2];
    newSrs2 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs2.srsId];
    [GPKGTestUtils assertNotNil:newSrs2];
    [GPKGTestUtils assertNotNil:newSrs2.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:newSrs2.definition_12_063 andValue2:@"definition_12_063 2"];
    
    // Create a new SRS without specifying new definition
    GPKGSpatialReferenceSystem *newSrs3 = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs3 setSrsName:@"name"];
    [newSrs3 setSrsId:[NSNumber numberWithInt:1324]];
    [newSrs3 setOrganization:@"organization"];
    [newSrs3 setOrganizationCoordsysId:[NSNumber numberWithInt:1324]];
    [newSrs3 setDefinition:@"definition"];
    [newSrs3 setTheDescription:@"description"];
    [srsDao create:newSrs3];
    newSrs3 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs3.srsId];
    [GPKGTestUtils assertNotNil:newSrs3];
    [GPKGTestUtils assertNotNil:newSrs3.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:newSrs3.definition_12_063 andValue2:@""];
    
    // Create a new SRS without specifying new definition
    GPKGSpatialReferenceSystem *newSrs4 = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs4 setSrsName:@"name"];
    [newSrs4 setSrsId:[NSNumber numberWithInt:5678]];
    [newSrs4 setOrganization:@"organization"];
    [newSrs4 setOrganizationCoordsysId:[NSNumber numberWithInt:5678]];
    [newSrs4 setDefinition:@"definition"];
    [newSrs4 setTheDescription:@"description"];
    [newSrs4 setDefinition_12_063:@"definition_12_063"];
    [newSrs4 setEpochValue:12.345];
    [srsDao create:newSrs4];
    newSrs4 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs4.srsId];
    [GPKGTestUtils assertNotNil:newSrs4];
    [GPKGTestUtils assertNotNil:newSrs4.definition_12_063];
    [GPKGTestUtils assertEqualWithValue:newSrs4.definition_12_063 andValue2:@"definition_12_063"];
    if(version == -1 || [GPKGCrsWktExtensionVersions isVersion:version atMinimum:GPKG_CRS_WKT_V_1_1]){
        [GPKGTestUtils assertNotNil:newSrs4.epoch];
        [GPKGTestUtils assertEqualDoubleWithValue:[newSrs4.epoch doubleValue] andValue2:12.345];
        [newSrs4 setEpoch:nil];
        [srsDao updateExtensionWithSrs:newSrs4];
        newSrs4 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs4.srsId];
        [GPKGTestUtils assertNotNil:newSrs4];
        [GPKGTestUtils assertNil:newSrs4.epoch];
        [newSrs4 setEpochValue:543.21];
        [srsDao updateExtensionWithSrs:newSrs4];
        newSrs4 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs4.srsId];
        [GPKGTestUtils assertNotNil:newSrs4];
        [GPKGTestUtils assertNotNil:newSrs4.epoch];
        [GPKGTestUtils assertEqualDoubleWithValue:[newSrs4.epoch doubleValue] andValue2:543.21];
    }else{
        [GPKGTestUtils assertNil:newSrs4.epoch];
    }
    
}

@end
