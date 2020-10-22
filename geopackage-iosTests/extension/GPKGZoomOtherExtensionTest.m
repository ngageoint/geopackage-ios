//
//  GPKGZoomOtherExtensionTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGZoomOtherExtensionTest.h"
#import "GPKGZoomOtherExtension.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGExtensionManager.h"

@implementation GPKGZoomOtherExtensionTest

/**
 *  Test the Zoom Other Extension creation
 */
-(void) testZoomOtherExtension{
    
    GPKGZoomOtherExtension * zoomOtherExtension = [[GPKGZoomOtherExtension alloc] initWithGeoPackage:self.geoPackage];
    
    NSString * tableName = @"table";
    
    GPKGExtensions * extension = [zoomOtherExtension extensionCreateWithTableName:tableName];
    [GPKGTestUtils assertNotNil:extension];
    [GPKGTestUtils assertTrue:[zoomOtherExtension hasWithTableName:tableName]];
    
    [GPKGTestUtils assertEqualWithValue:extension.extensionName andValue2:[NSString stringWithFormat:@"%@%@%@", GPKG_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_ZOOM_OTHER_EXTENSION_NAME]];
    [GPKGTestUtils assertEqualWithValue:[extension author] andValue2:GPKG_EXTENSION_AUTHOR];
    [GPKGTestUtils assertEqualWithValue:[extension extensionNameNoAuthor] andValue2:GPKG_ZOOM_OTHER_EXTENSION_NAME];
    [GPKGTestUtils assertEqualWithValue:extension.tableName andValue2:tableName];
    [GPKGTestUtils assertEqualWithValue:extension.columnName andValue2:GPKG_TC_COLUMN_TILE_DATA];
    [GPKGTestUtils assertEqualIntWithValue:[extension extensionScopeType] andValue2:GPKG_EST_READ_WRITE];
    [GPKGTestUtils assertEqualWithValue:extension.definition andValue2:[GPKGProperties valueOfProperty:@"geopackage.extensions.zoom_other"]];
    
    [[GPKGExtensionManager createWithGeoPackage:self.geoPackage] deleteExtensionsForTable:tableName];
    [GPKGTestUtils assertFalse:[zoomOtherExtension hasWithTableName:tableName]];
}

@end
