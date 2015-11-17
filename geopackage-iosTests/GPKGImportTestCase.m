//
//  GPKGImportTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/16/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGImportTestCase.h"
#import "GPKGGeoPackageTestUtils.h"

@implementation GPKGImportTestCase

- (void)testCreateFeatureTableWithMetadata {
    
    [GPKGGeoPackageTestUtils testCreateFeatureTableWithMetadata:self.geoPackage];

}

- (void)testCreateFeatureTableWithMetadataIdColumn {
    
    [GPKGGeoPackageTestUtils testCreateFeatureTableWithMetadataIdColumn:self.geoPackage];

}

- (void)testCreateFeatureTableWithMetadataAdditionalColumns {
    
    [GPKGGeoPackageTestUtils testCreateFeatureTableWithMetadataAdditionalColumns:self.geoPackage];

}

- (void)testCreateFeatureTableWithMetadataIdColumnAdditionalColumns {
    
    [GPKGGeoPackageTestUtils testCreateFeatureTableWithMetadataIdColumnAdditionalColumns:self.geoPackage];

}

@end
