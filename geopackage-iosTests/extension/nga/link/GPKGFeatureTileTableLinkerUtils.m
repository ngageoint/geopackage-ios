//
//  GPKGFeatureTileTableLinkerUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/5/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTileTableLinkerUtils.h"
#import "GPKGFeatureTileTableLinker.h"
#import "GPKGTestUtils.h"
#import "GPKGProperties.h"
#import "GPKGExtensionManager.h"

@implementation GPKGFeatureTileTableLinkerUtils

+(void) testLinkWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [[GPKGExtensionManager createWithGeoPackage:geoPackage] deleteExtensions];
    
    GPKGFeatureTileTableLinker * linker = [[GPKGFeatureTileTableLinker alloc] initWithGeoPackage:geoPackage];
    [GPKGTestUtils assertNil:[linker extension]];
    
    // Test linking feature and tile tables
    NSArray * featureTables = [geoPackage featureTables];
    NSArray * tileTables = [geoPackage tileTables];
    
    if([featureTables count] != 0 && [tileTables count] != 0){
        
        GPKGFeatureTileLinkDao * dao = [linker dao];
        
        NSMutableSet * linkedFeatureTables = [NSMutableSet set];
        
        for(NSString * featureTable in featureTables){
            
            [linkedFeatureTables addObject:featureTable];
            
            NSMutableSet * linkedTileTables = [NSMutableSet set];
            
            for(NSString * tileTable in tileTables){
                
                [linkedTileTables addObject:tileTable];
                
                [GPKGTestUtils assertFalse:[linker isLinkedWithFeatureTable:featureTable andTileTable:tileTable]];
                
                int count = 0;
                if([dao tableExists]){
                    count = [dao count];
                }
                
                // Link the tables
                [linker linkWithFeatureTable:featureTable andTileTable:tileTable];
                [GPKGTestUtils assertTrue:[linker isLinkedWithFeatureTable:featureTable andTileTable:tileTable]];
                [GPKGTestUtils assertEqualIntWithValue:count + 1 andValue2:[dao count]];
                [GPKGTestUtils assertNotNil:[linker extension]];
                
                // Shouldn't hurt to link it twice
                [linker linkWithFeatureTable:featureTable andTileTable:tileTable];
                [GPKGTestUtils assertTrue:[linker isLinkedWithFeatureTable:featureTable andTileTable:tileTable]];
                [GPKGTestUtils assertEqualIntWithValue:count + 1 andValue2:[dao count]];
                [GPKGTestUtils assertNotNil:[linker extension]];
                
                // Verify linked feature tables
                GPKGResultSet * links = [linker queryForTileTable:tileTable];
                [GPKGTestUtils assertEqualIntWithValue:(int)[linkedFeatureTables count] andValue2:[links count]];
                while([links moveToNext]){
                    GPKGFeatureTileLink * link = [linker linkFromResultSet:links];
                    [GPKGTestUtils assertTrue:[linkedFeatureTables containsObject:link.featureTableName]];
                }
                [links close];
                
                // Verify linked tile tables
                links = [linker queryForFeatureTable:featureTable];
                [GPKGTestUtils assertEqualIntWithValue:(int)[linkedTileTables count] andValue2:[links count]];
                while([links moveToNext]){
                    GPKGFeatureTileLink * link = [linker linkFromResultSet:links];
                    [GPKGTestUtils assertTrue:[linkedTileTables containsObject:link.tileTableName]];
                }
                [links close];
            }
        }
        
        GPKGExtensions * extension  = [linker extension];
        [GPKGTestUtils assertEqualWithValue:[GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR andExtensionName:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR] andValue2:extension.extensionName];
        [GPKGTestUtils assertEqualWithValue:GPKG_EXTENSION_FEATURE_TILE_LINK_AUTHOR andValue2:[extension author]];
        [GPKGTestUtils assertEqualWithValue:GPKG_EXTENSION_FEATURE_TILE_LINK_NAME_NO_AUTHOR andValue2:[extension extensionNameNoAuthor]];
        [GPKGTestUtils assertEqualWithValue:[GPKGProperties valueOfProperty:@"geopackage.extensions.feature_tile_link"] andValue2:extension.definition];
        [GPKGTestUtils assertNil:extension.tableName];
        [GPKGTestUtils assertNil:extension.columnName];
        
        // Delete a single link
        int count = [dao count];
        NSString * featureTable = [featureTables objectAtIndex:0];
        NSString * tileTable = [tileTables objectAtIndex:0];
        [GPKGTestUtils assertTrue:[linker isLinkedWithFeatureTable:featureTable andTileTable:tileTable]];
        [linker deleteLinkWithFeatureTable:featureTable andTileTable:tileTable];
        [GPKGTestUtils assertFalse:[linker isLinkedWithFeatureTable:featureTable andTileTable:tileTable]];
        [GPKGTestUtils assertEqualIntWithValue:count - 1 andValue2:[dao count]];
        
        // Delete all links from a feature table
        if([tileTables count] > 1){
            GPKGResultSet * links = [linker queryForFeatureTable:featureTable];
            int linkedTables = [links count];
            [links close];
            [GPKGTestUtils assertTrue:linkedTables > 0];
            int deletedCount = [linker deleteLinksWithTable:featureTable];
            [GPKGTestUtils assertEqualIntWithValue:linkedTables andValue2:deletedCount];
            links = [linker queryForFeatureTable:featureTable];
            [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[links count]];
            [links close];
        }
        
        // Delete all links from a tile table
        if([featureTables count] > 1){
            GPKGResultSet * links = [linker queryForTileTable:tileTable];
            int linkedTables = [links count];
            [links close];
            [GPKGTestUtils assertTrue:linkedTables > 0];
            int deletedCount = [linker deleteLinksWithTable:tileTable];
            [GPKGTestUtils assertEqualIntWithValue:linkedTables andValue2:deletedCount];
            links = [linker queryForTileTable:tileTable];
            [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[links count]];
            [links close];
        }
        
        [GPKGTestUtils assertTrue:[dao tableExists]];
        [GPKGTestUtils assertNotNil:[linker extension]];
        
        // Test deleting all extensions
        [[GPKGExtensionManager createWithGeoPackage:geoPackage] deleteExtensions];
        
        [GPKGTestUtils assertFalse:[dao tableExists]];
        [GPKGTestUtils assertNil:[linker extension]];
        
        for(NSString * ft in featureTables){
            for(NSString * tt in tileTables){
                [GPKGTestUtils assertFalse:[linker isLinkedWithFeatureTable:ft andTileTable:tt]];
            }
        }
        [GPKGTestUtils assertFalse:[dao tableExists]];
        [GPKGTestUtils assertNil:[linker extension]];
        
    }
}

@end
