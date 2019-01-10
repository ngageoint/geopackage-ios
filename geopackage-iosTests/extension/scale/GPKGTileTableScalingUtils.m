//
//  GPKGTileTableScalingUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 3/15/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileTableScalingUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGTileTableScaling.h"
#import "GPKGProperties.h"
#import "GPKGGeoPackageExtensions.h"

@implementation GPKGTileTableScalingUtils

+(void) testScalingWithGeoPackage: (GPKGGeoPackage *) geoPackage{

    [GPKGGeoPackageExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    NSArray *tileTables = [geoPackage getTileTables];
    
    if(tileTables.count > 0){
        
        for(NSString *tableName in tileTables){
            
            GPKGTileTableScaling *tableScaling = [[GPKGTileTableScaling alloc] initWithGeoPackage:geoPackage andTableName:tableName];
            [GPKGTestUtils assertNil:[tableScaling getExtension]];
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:[tableScaling getTableName]];
            GPKGTileScalingDao *dao = [tableScaling getDao];
            
            [GPKGTestUtils assertFalse:[tableScaling has]];
            [GPKGTestUtils assertNil:[tableScaling get]];
            
            int count = 0;
            if ([dao tableExists]) {
                count = [dao count];
            }
            
            GPKGTileScaling *newTileScaling = [[GPKGTileScaling alloc] init];
            [newTileScaling setTileScalingType:GPKG_TSC_IN_OUT];
            [newTileScaling setZoomIn:[NSNumber numberWithInt:2]];
            [newTileScaling setZoomOut:[NSNumber numberWithInt:2]];
            [tableScaling createOrUpdate:newTileScaling];
            
            GPKGExtensions *extension = [tableScaling getExtension];
            NSString * extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_TILE_SCALING_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
            [GPKGTestUtils assertEqualWithValue:extensionName andValue2:extension.extensionName];
            [GPKGTestUtils assertEqualWithValue:GPKG_EXTENSION_TILE_SCALING_AUTHOR andValue2:[extension getAuthor]];
            [GPKGTestUtils assertEqualWithValue:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR andValue2:[extension getExtensionNameNoAuthor]];
            [GPKGTestUtils assertEqualWithValue:[GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_TILE_SCALING_DEFINITION] andValue2:extension.definition];
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:extension.tableName];
            [GPKGTestUtils assertNil:extension.columnName];
            
            [GPKGTestUtils assertTrue:[tableScaling has]];
            GPKGTileScaling *createdTileScaling = [tableScaling get];
            [GPKGTestUtils assertNotNil:createdTileScaling];
            [GPKGTestUtils assertEqualIntWithValue:count + 1 andValue2:[dao count]];
            
            [GPKGTestUtils assertEqualIntWithValue:[newTileScaling getTileScalingType] andValue2:[createdTileScaling getTileScalingType]];
            [GPKGTestUtils assertEqualWithValue:newTileScaling.scalingType andValue2:createdTileScaling.scalingType];
            [GPKGTestUtils assertEqualWithValue:newTileScaling.zoomIn andValue2:createdTileScaling.zoomIn];
            [GPKGTestUtils assertEqualWithValue:newTileScaling.zoomOut andValue2:createdTileScaling.zoomOut];
            
            [createdTileScaling setTileScalingType:GPKG_TSC_OUT_IN];
            [createdTileScaling setZoomIn:[NSNumber numberWithInt:3]];
            [createdTileScaling setZoomOut:nil];
            [tableScaling createOrUpdate:createdTileScaling];
            
            [GPKGTestUtils assertTrue:[tableScaling has]];
            GPKGTileScaling *updatedTileScaling = [tableScaling get];
            [GPKGTestUtils assertNotNil:updatedTileScaling];
            [GPKGTestUtils assertEqualIntWithValue:count + 1 andValue2:[dao count]];
            
            [GPKGTestUtils assertEqualIntWithValue:[createdTileScaling getTileScalingType] andValue2:[updatedTileScaling getTileScalingType]];
            [GPKGTestUtils assertEqualWithValue:createdTileScaling.scalingType andValue2:updatedTileScaling.scalingType];
            [GPKGTestUtils assertEqualWithValue:createdTileScaling.zoomIn andValue2:updatedTileScaling.zoomIn];
            [GPKGTestUtils assertEqualWithValue:createdTileScaling.zoomOut andValue2:updatedTileScaling.zoomOut];
            
            [GPKGTestUtils assertTrue:[tableScaling delete]];
            
            [GPKGTestUtils assertNil:[tableScaling getExtension]];
            [GPKGTestUtils assertFalse:[tableScaling has]];
            [GPKGTestUtils assertNil:[tableScaling get]];
            [GPKGTestUtils assertEqualIntWithValue:count andValue2:[dao count]];
            [GPKGTestUtils assertTrue:[dao tableExists]];
            
            // Test deleting all extensions
            [GPKGGeoPackageExtensions deleteExtensionsWithGeoPackage: geoPackage];
            
            [GPKGTestUtils assertFalse:[dao tableExists]];
            [GPKGTestUtils assertNil:[tableScaling getExtension]];
            [GPKGTestUtils assertFalse:[tableScaling has]];
            [GPKGTestUtils assertNil:[tableScaling get]];
            
        }
        
    }
}

@end
