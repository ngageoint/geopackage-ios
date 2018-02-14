//
//  GPKGWebPExtensionTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGWebPExtensionTest.h"
#import "GPKGWebPExtension.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGGeoPackageExtensions.h"

@implementation GPKGWebPExtensionTest

/**
 *  Test the WebP Extension creation
 */
-(void) testWebPExtension{
    
    GPKGWebPExtension * webpExtension = [[GPKGWebPExtension alloc] initWithGeoPackage:self.geoPackage];
    
    NSString * tableName = @"table";
    
    GPKGExtensions * extension = [webpExtension getOrCreateWithTableName:tableName];
    [GPKGTestUtils assertNotNil:extension];
    [GPKGTestUtils assertTrue:[webpExtension hasWithTableName:tableName]];
     
    [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_WEBP_EXTENSION_NAME]];
    [GPKGTestUtils assertEqualWithValue:[extension getAuthor] andValue2:GPKG_GEO_PACKAGE_EXTENSION_AUTHOR];
    [GPKGTestUtils assertEqualWithValue:[extension getExtensionNameNoAuthor] andValue2:GPKG_WEBP_EXTENSION_NAME];
    [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:tableName];
    [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:GPKG_TT_COLUMN_TILE_DATA];
    [GPKGTestUtils assertEqualIntWithValue:[extension getExtensionScopeType] andValue2:GPKG_EST_READ_WRITE];
    [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:[GPKGProperties getValueOfProperty:@"geopackage.extensions.webp"]];
    
    [GPKGGeoPackageExtensions deleteTableExtensionsWithGeoPackage:self.geoPackage andTable:tableName];
    [GPKGTestUtils assertFalse:[webpExtension hasWithTableName:tableName]];
}

@end
