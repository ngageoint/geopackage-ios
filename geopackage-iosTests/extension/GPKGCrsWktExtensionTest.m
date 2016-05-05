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
#import "GPKGProjectionConstants.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

@implementation GPKGCrsWktExtensionTest

- (void)testExtension {
    
    GPKGSpatialReferenceSystemDao * srsDao = [self.geoPackage getSpatialReferenceSystemDao];
    
    GPKGCrsWktExtension * wktExtension = [[GPKGCrsWktExtension alloc] initWithGeoPackage:self.geoPackage];
    [GPKGTestUtils assertFalse:[wktExtension has]];
    
    // Test querying and setting the definitions before the column exists
    GPKGSpatialReferenceSystem * wgs84Srs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [GPKGTestUtils assertNotNil:wgs84Srs];
    [GPKGTestUtils assertNil:wgs84Srs.definition_12_163];
    [srsDao setDefinition_12_163WithSrs:wgs84Srs];
    [GPKGTestUtils assertNil:wgs84Srs.definition_12_163];
    
    GPKGSpatialReferenceSystem * undefinedCartesianSrs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:[NSNumber numberWithInt:PROJ_UNDEFINED_CARTESIAN]];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.definition_12_163];
    [srsDao setDefinition_12_163WithSrs:undefinedCartesianSrs];
    [GPKGTestUtils assertNil:undefinedCartesianSrs.definition_12_163];
    
    GPKGSpatialReferenceSystem * undefinedGeographicSrs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:[NSNumber numberWithInt:PROJ_UNDEFINED_GEOGRAPHIC]];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.definition_12_163];
    [srsDao setDefinition_12_163WithSrs:undefinedGeographicSrs];
    [GPKGTestUtils assertNil:undefinedGeographicSrs.definition_12_163];
    
    // Create a new SRS
    GPKGSpatialReferenceSystem * newSrs = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs setSrsName:@"name"];
    [newSrs setSrsId:[NSNumber numberWithInt:1234]];
    [newSrs setOrganization:@"organization"];
    [newSrs setOrganizationCoordsysId:[NSNumber numberWithInt:1234]];
    [newSrs setDefinition:@"definition"];
    [newSrs setTheDescription:@"description"];
    [srsDao create:newSrs];
    newSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs.srsId];
    [GPKGTestUtils assertNotNil:newSrs];
    [GPKGTestUtils assertNil:newSrs.definition_12_163];
    [srsDao setDefinition_12_163WithSrs:newSrs];
    [GPKGTestUtils assertNil:newSrs.definition_12_163];
    
    // Create the extension
    GPKGExtensions * extension = [wktExtension getOrCreate];
    [GPKGTestUtils assertNotNil:extension];
    [GPKGTestUtils assertTrue:[wktExtension has]];
    [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:@"gpkg_crs_wkt"];
    [GPKGTestUtils assertEqualWithValue:[extension getAuthor] andValue2:@"gpkg"];
    [GPKGTestUtils assertEqualWithValue:[extension getExtensionNameNoAuthor] andValue2:@"crs_wkt"];
    [GPKGTestUtils assertNil:extension.tableName];
    [GPKGTestUtils assertNil:extension.columnName];
    [GPKGTestUtils assertEqualWithValue:extension.scope andValue2:GPKG_EST_READ_WRITE_NAME];
    [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:[GPKGProperties getValueOfProperty:@"geopackage.extensions.crs_wkt"]];
    
    // Test querying and setting the definitions after the column exists
    wgs84Srs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [GPKGTestUtils assertNotNil:wgs84Srs];
    [GPKGTestUtils assertNotNil:wgs84Srs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:wgs84Srs.definition_12_163 andValue2:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_163]];
    
    undefinedCartesianSrs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:[NSNumber numberWithInt:PROJ_UNDEFINED_CARTESIAN]];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:undefinedCartesianSrs.definition_12_163 andValue2:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_163]];
    
    undefinedGeographicSrs = (GPKGSpatialReferenceSystem *) [srsDao queryForIdObject:[NSNumber numberWithInt:PROJ_UNDEFINED_GEOGRAPHIC]];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:undefinedGeographicSrs.definition_12_163 andValue2:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_163]];
    
    
    newSrs = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs.srsId];
    [GPKGTestUtils assertNotNil:newSrs];
    [GPKGTestUtils assertNotNil:newSrs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:newSrs.definition_12_163 andValue2:@"undefined"];
    
    // Test the get or create auto set
    wgs84Srs = [srsDao getOrCreateWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    [GPKGTestUtils assertNotNil:wgs84Srs];
    [GPKGTestUtils assertNotNil:wgs84Srs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:wgs84Srs.definition_12_163 andValue2:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_163]];
    
    undefinedCartesianSrs = [srsDao getOrCreateWithSrsId:[NSNumber numberWithInt:PROJ_UNDEFINED_CARTESIAN]];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs];
    [GPKGTestUtils assertNotNil:undefinedCartesianSrs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:undefinedCartesianSrs.definition_12_163 andValue2:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_163]];
    
    undefinedGeographicSrs = [srsDao getOrCreateWithSrsId:[NSNumber numberWithInt:PROJ_UNDEFINED_GEOGRAPHIC]];
    [GPKGTestUtils assertNotNil:undefinedGeographicSrs.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:undefinedGeographicSrs.definition_12_163 andValue2:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_163]];
    
    // Create the web mercator srs and test
    GPKGSpatialReferenceSystem * webMercator = [srsDao getOrCreateWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    [GPKGTestUtils assertNotNil:webMercator.definition_12_163];
    
    // Read the web mercator srs and test
    GPKGSpatialReferenceSystem * webMercator2 = [srsDao getOrCreateWithSrsId:[NSNumber numberWithInt:PROJ_EPSG_WEB_MERCATOR]];
    [GPKGTestUtils assertNotNil:webMercator2.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:webMercator.definition_12_163 andValue2:webMercator2.definition_12_163];
    
    GPKGSpatialReferenceSystem * newSrs2 = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs2 setSrsName:@"name"];
    [newSrs2 setSrsId:[NSNumber numberWithInt:4321]];
    [newSrs2 setOrganization:@"organization"];
    [newSrs2 setOrganizationCoordsysId:[NSNumber numberWithInt:4321]];
    [newSrs2 setDefinition:@"definition"];
    [newSrs2 setTheDescription:@"description"];
    [newSrs2 setDefinition_12_163:@"definition_12_163"];
    [srsDao create:newSrs2];
    newSrs2 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs2.srsId];
    [GPKGTestUtils assertNotNil:newSrs2];
    [GPKGTestUtils assertNotNil:newSrs2.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:newSrs2.definition_12_163 andValue2:@"definition_12_163"];
    
    // Create a new SRS without specifying new definition
    GPKGSpatialReferenceSystem * newSrs3 = [[GPKGSpatialReferenceSystem alloc] init];
    [newSrs3 setSrsName:@"name"];
    [newSrs3 setSrsId:[NSNumber numberWithInt:1324]];
    [newSrs3 setOrganization:@"organization"];
    [newSrs3 setOrganizationCoordsysId:[NSNumber numberWithInt:1324]];
    [newSrs3 setDefinition:@"definition"];
    [newSrs3 setTheDescription:@"description"];
    [srsDao create:newSrs3];
    newSrs3 = (GPKGSpatialReferenceSystem *)[srsDao queryForIdObject:newSrs3.srsId];
    [GPKGTestUtils assertNotNil:newSrs3];
    [GPKGTestUtils assertNotNil:newSrs3.definition_12_163];
    [GPKGTestUtils assertEqualWithValue:newSrs3.definition_12_163 andValue2:@"undefined"];

}

@end
