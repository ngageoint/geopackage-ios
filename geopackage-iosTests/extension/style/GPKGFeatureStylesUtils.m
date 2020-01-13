//
//  GPKGFeatureStylesUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureStylesUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGFeatureTableStyles.h"
#import "GPKGTestConstants.h"
#import "SFGeometryUtils.h"
#import "GPKGGeoPackageExtensions.h"

@implementation GPKGFeatureStylesUtils

+(void) testFeatureStylesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    [GPKGGeoPackageExtensions deleteExtensionsWithGeoPackage:geoPackage];
    
    GPKGFeatureStyleExtension *featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
    
    [GPKGTestUtils assertFalse:[featureStyleExtension has]];
    
    NSArray<NSString *> *featureTables = [geoPackage getFeatureTables];
    
    if(featureTables.count > 0){
        
        [GPKGTestUtils assertFalse:[geoPackage isTable:GPKG_ST_TABLE_NAME]];
        [GPKGTestUtils assertFalse:[geoPackage isTable:GPKG_IT_TABLE_NAME]];
        [GPKGTestUtils assertFalse:[geoPackage isTable:GPKG_CI_TABLE_NAME]];
        
        for(NSString *tableName in featureTables){
            
            [GPKGTestUtils assertFalse:[featureStyleExtension hasWithTable:tableName]];
            
            GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:tableName];
            
            GPKGFeatureTableStyles *featureTableStyles = [[GPKGFeatureTableStyles alloc] initWithGeoPackage:geoPackage andTable:[featureDao getFeatureTable]];
            [GPKGTestUtils assertFalse:[featureTableStyles has]];
            
            enum SFGeometryType geometryType = [featureDao getGeometryType];
            NSDictionary<NSNumber *, NSDictionary *> *childGeometryTypes = [SFGeometryUtils childHierarchyOfType:geometryType];
            
            [GPKGTestUtils assertFalse:[featureTableStyles hasTableStyleRelationship]];
            [GPKGTestUtils assertFalse:[featureTableStyles hasStyleRelationship]];
            [GPKGTestUtils assertFalse:[featureTableStyles hasTableIconRelationship]];
            [GPKGTestUtils assertFalse:[featureTableStyles hasIconRelationship]];
            
            [GPKGTestUtils assertNotNil:[featureTableStyles tableName]];
            [GPKGTestUtils assertEqualWithValue:tableName andValue2:[featureTableStyles tableName]];
            [GPKGTestUtils assertNotNil:[featureTableStyles featureStyleExtension]];
            
            [GPKGTestUtils assertNil:[featureTableStyles tableFeatureStyles]];
            [GPKGTestUtils assertNil:[featureTableStyles tableStyles]];
            [GPKGTestUtils assertNil:[featureTableStyles cachedTableStyles]];
            [GPKGTestUtils assertNil:[featureTableStyles tableStyleDefault]];
            [GPKGTestUtils assertNil:[featureTableStyles tableStyleWithGeometryType:SF_GEOMETRY]];
            [GPKGTestUtils assertNil:[featureTableStyles tableIcons]];
            [GPKGTestUtils assertNil:[featureTableStyles cachedTableIcons]];
            [GPKGTestUtils assertNil:[featureTableStyles tableIconDefault]];
            [GPKGTestUtils assertNil:[featureTableStyles tableIconWithGeometryType:SF_GEOMETRY]];
            
            GPKGResultSet *featureResultSet = [featureDao queryForAll];
            while([featureResultSet moveToNext]){
                GPKGFeatureRow *featureRow = [featureDao getFeatureRow:featureResultSet];
                
                [GPKGTestUtils assertNil:[featureTableStyles featureStylesWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles featureStylesWithIdNumber:[featureRow id]]];
                
                [GPKGTestUtils assertNil:[featureTableStyles featureStyleWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles featureStyleDefaultWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles featureStyleWithIdNumber:[featureRow id] andGeometryType:[featureRow getGeometryType]]];
                [GPKGTestUtils assertNil:[featureTableStyles featureStyleDefaultWithIdNumber:[featureRow id]]];

                [GPKGTestUtils assertNil:[featureTableStyles stylesWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles stylesWithIdNumber:[featureRow id]]];
                
                [GPKGTestUtils assertNil:[featureTableStyles styleWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles styleDefaultWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles styleWithIdNumber:[featureRow id] andGeometryType:[featureRow getGeometryType]]];
                [GPKGTestUtils assertNil:[featureTableStyles styleDefaultWithIdNumber:[featureRow id]]];
                
                [GPKGTestUtils assertNil:[featureTableStyles  iconsWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles iconsWithIdNumber:[featureRow id]]];
                
                [GPKGTestUtils assertNil:[featureTableStyles iconWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles iconDefaultWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureTableStyles iconWithIdNumber:[featureRow id] andGeometryType:[featureRow getGeometryType]]];
                [GPKGTestUtils assertNil:[featureTableStyles iconDefaultWithIdNumber:[featureRow id]]];
            }
            [featureResultSet close];
            
            // Table Styles
            [GPKGTestUtils assertFalse:[featureTableStyles hasTableStyleRelationship]];
            [GPKGTestUtils assertFalse:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:tableName]]];
            
            // Add a default table style
            GPKGStyleRow *tableStyleDefault = [self randomStyle];
            [featureTableStyles setTableStyleDefault:tableStyleDefault];
            
            [GPKGTestUtils assertTrue:[featureStyleExtension has]];
            [GPKGTestUtils assertTrue:[featureStyleExtension hasWithTable:tableName]];
            [GPKGTestUtils assertTrue:[featureTableStyles has]];
            [GPKGTestUtils assertTrue:[featureTableStyles hasTableStyleRelationship]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_ST_TABLE_NAME]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_CI_TABLE_NAME]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_STYLE andTable:tableName]]];
            
            // Add geometry type table styles
            NSMutableDictionary *geometryTypeTableStyles = [self randomStylesWithGeometryTypes:childGeometryTypes];
            for(NSNumber *geometryTypeNumber in [geometryTypeTableStyles allKeys]){
                enum SFGeometryType geometryType = (enum SFGeometryType) [geometryTypeNumber intValue];
                GPKGStyleRow *styleRow = [geometryTypeTableStyles objectForKey:geometryTypeNumber];
                [featureTableStyles setTableStyle:styleRow withGeometryType:geometryType];
            }
            
            GPKGFeatureStyles *featureStyles = [featureTableStyles tableFeatureStyles];
            [GPKGTestUtils assertNotNil:featureStyles];
            [GPKGTestUtils assertNotNil:featureStyles.styles];
            [GPKGTestUtils assertNil:featureStyles.icons];
            
            GPKGStyles *tableStyles = [featureTableStyles tableStyles];
            [GPKGTestUtils assertNotNil:tableStyles];
            [GPKGTestUtils assertNotNil:[tableStyles defaultStyle]];
            [GPKGTestUtils assertEqualWithValue:[tableStyleDefault id] andValue2:[[tableStyles defaultStyle] id]];
            [GPKGTestUtils assertEqualWithValue:[tableStyleDefault id] andValue2:[[featureTableStyles tableStyleWithGeometryType:SF_NONE] id]];
            [GPKGTestUtils assertEqualWithValue:[tableStyleDefault id] andValue2:[[featureTableStyles tableStyleWithGeometryType:geometryType] id]];
            [self validateTableStyles:featureTableStyles andStyle:tableStyleDefault andStyles:geometryTypeTableStyles andTypes:childGeometryTypes];
            
            // Table Icons
            [GPKGTestUtils assertFalse:[featureTableStyles hasTableIconRelationship]];
            [GPKGTestUtils assertFalse:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:tableName]]];
            
            // Create table icon relationship
            [GPKGTestUtils assertFalse:[featureTableStyles hasTableIconRelationship]];
            [featureTableStyles createTableIconRelationship];
            [GPKGTestUtils assertTrue:[featureTableStyles hasTableIconRelationship]];
            
            GPKGIcons *createTableIcons = [[GPKGIcons alloc] init];
            GPKGIconRow *tableIconDefault = [self randomIcon];
            [createTableIcons setDefaultIcon:tableIconDefault];
            NSMutableDictionary<NSNumber *, GPKGIconRow *> *geometryTypeTableIcons = [self randomIconsWithGeometryTypes:childGeometryTypes];
            GPKGIconRow *baseGeometryTypeIcon = [self randomIcon];
            [geometryTypeTableIcons setObject:baseGeometryTypeIcon forKey:[NSNumber numberWithInt:geometryType]];
            for(NSNumber *geometryTypeNumber in [geometryTypeTableIcons allKeys]){
                [createTableIcons setIcon:[geometryTypeTableIcons objectForKey:geometryTypeNumber] forGeometryType:[geometryTypeNumber intValue]];
            }
            
            // Set the table icons
            [featureTableStyles setTableIcons:createTableIcons];
            
            [GPKGTestUtils assertTrue:[featureTableStyles hasTableIconRelationship]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_IT_TABLE_NAME]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_TABLE_ICON andTable:tableName]]];
            
            featureStyles = [featureTableStyles tableFeatureStyles];
            [GPKGTestUtils assertNotNil:featureStyles];
            [GPKGTestUtils assertNotNil:featureStyles.styles];
            GPKGIcons *tableIcons = featureStyles.icons;
            [GPKGTestUtils assertNotNil:tableIcons];
            
            [GPKGTestUtils assertNotNil:[tableIcons defaultIcon]];
            [GPKGTestUtils assertEqualWithValue:[tableIconDefault id] andValue2:[[tableIcons defaultIcon] id]];
            [GPKGTestUtils assertEqualWithValue:[tableIconDefault id] andValue2:[[featureTableStyles tableIconWithGeometryType:SF_NONE] id]];
            [GPKGTestUtils assertEqualWithValue:[baseGeometryTypeIcon id] andValue2:[[featureTableStyles tableIconWithGeometryType:geometryType] id]];
            [self validateTableIcons:featureTableStyles andIcon:baseGeometryTypeIcon andIcons:geometryTypeTableIcons andTypes:childGeometryTypes];
            
            [GPKGTestUtils assertFalse:[featureTableStyles hasStyleRelationship]];
            [GPKGTestUtils assertFalse:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_STYLE andTable:tableName]]];
            [GPKGTestUtils assertFalse:[featureTableStyles hasIconRelationship]];
            [GPKGTestUtils assertFalse:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_ICON andTable:tableName]]];
            
            GPKGStyleDao *styleDao = [featureTableStyles styleDao];
            GPKGIconDao *iconDao = [featureTableStyles iconDao];
            
            NSMutableArray<GPKGStyleRow *> *randomStyles = [[NSMutableArray alloc] init];
            NSMutableArray<GPKGIconRow *> *randomIcons = [[NSMutableArray alloc] init];
            for (int i = 0; i < 10; i++) {
                GPKGStyleRow *styleRow = [self randomStyle];
                [randomStyles addObject:styleRow];
                GPKGIconRow *iconRow = [self randomIcon];
                [randomIcons addObject:iconRow];
                
                if (i % 2 == 0) {
                    [styleDao insert:styleRow];
                    [iconDao insert:iconRow];
                }
            }
            
            // Create style and icon relationship
            [featureTableStyles createStyleRelationship];
            [GPKGTestUtils assertTrue:[featureTableStyles hasStyleRelationship]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_STYLE andTable:tableName]]];
            [featureTableStyles createIconRelationship];
            [GPKGTestUtils assertTrue:[featureTableStyles hasIconRelationship]];
            [GPKGTestUtils assertTrue:[geoPackage isTable:[[featureTableStyles featureStyleExtension] mappingTableNameWithPrefix:GPKG_FSE_TABLE_MAPPING_ICON andTable:tableName]]];
            
            NSMutableDictionary<NSNumber *, NSMutableDictionary *> *featureResultsStyles = [[NSMutableDictionary alloc] init];
            NSMutableDictionary<NSNumber *, NSMutableDictionary *> *featureResultsIcons = [[NSMutableDictionary alloc] init];
            
            featureResultSet = [featureDao queryForAll];
            while([featureResultSet moveToNext]){
                
                double randomFeatureOption = [GPKGTestUtils randomDouble];
                
                if (randomFeatureOption < .25) {
                    continue;
                }
                
                GPKGFeatureRow *featureRow = [featureDao getFeatureRow:featureResultSet];
                
                if (randomFeatureOption < .75) {
                    
                    // Feature Styles
                    
                    NSMutableDictionary<NSNumber *, GPKGStyleRow *> *featureRowStyles = [[NSMutableDictionary alloc] init];
                    [featureResultsStyles setObject:featureRowStyles forKey:[featureRow id]];
                    
                    // Add a default style
                    GPKGStyleRow *styleDefault = [self randomStyleWithRandomStyles:randomStyles];
                    [featureTableStyles setStyleDefault:styleDefault withFeature:featureRow];
                    [featureRowStyles setObject:styleDefault forKey:[NSNumber numberWithInt:SF_NONE]];
                    
                    // Add geometry type styles
                    NSMutableDictionary<NSNumber *, GPKGStyleRow *> *geometryTypeStyles = [self randomStylesWithGeometryTypes:childGeometryTypes andRandomSyles:randomStyles];
                    for(NSNumber *geometryTypeStyleNumber in [geometryTypeStyles allKeys]){
                        enum SFGeometryType geometryTypeStyle = (enum SFGeometryType) [geometryTypeStyleNumber intValue];
                        GPKGStyleRow *style = [geometryTypeStyles objectForKey:geometryTypeStyleNumber];
                        [featureTableStyles setStyle:style withFeature:featureRow andGeometryType:geometryTypeStyle];
                        [featureRowStyles setObject:style forKey:geometryTypeStyleNumber];
                    }
                    
                }
                
                if (randomFeatureOption >= .5) {
                    
                    // Feature Icons
                    
                    NSMutableDictionary<NSNumber *, GPKGIconRow *> *featureRowIcons = [[NSMutableDictionary alloc] init];
                    [featureResultsIcons setObject:featureRowIcons forKey:[featureRow id]];
                    
                    // Add a default icon
                    GPKGIconRow *iconDefault = [self randomIconWithRandomIcons:randomIcons];
                    [featureTableStyles setIconDefault:iconDefault withFeature:featureRow];
                    [featureRowIcons setObject:iconDefault forKey:[NSNumber numberWithInt:SF_NONE]];
                    
                    // Add geometry type icons
                    NSMutableDictionary<NSNumber *, GPKGIconRow *> *geometryTypeIcons = [self randomIconsWithGeometryTypes:childGeometryTypes andRandomIcons:randomIcons];
                    for(NSNumber *geometryTypeIconNumber in [geometryTypeIcons allKeys]){
                        enum SFGeometryType geometryTypeIcon = (enum SFGeometryType) [geometryTypeIconNumber intValue];
                        GPKGIconRow *icon = [geometryTypeIcons objectForKey:geometryTypeIconNumber];
                        [featureTableStyles setIcon:icon withFeature:featureRow andGeometryType:geometryTypeIcon];
                        [featureRowIcons setObject:icon forKey:geometryTypeIconNumber];
                    }
                    
                }
                
            }
            [featureResultSet close];
            
            featureResultSet = [featureDao queryForAll];
            while([featureResultSet moveToNext]){
                
                GPKGFeatureRow *featureRow = [featureDao getFeatureRow:featureResultSet];
                
                [self validateRowStyles:featureTableStyles andFeature:featureRow andTableStyleDefault:tableStyleDefault andTableStyles:geometryTypeTableStyles andFeatureStyles:featureResultsStyles];
                
                [self validateRowIcons:featureTableStyles andFeature:featureRow andTableIconDefault:tableIconDefault andTableIcons:geometryTypeTableIcons andFeatureIcons:featureResultsIcons];
                
            }
            [featureResultSet close];
            
        }

        NSArray<NSString *> *tables = [featureStyleExtension tables];
        [GPKGTestUtils assertEqualUnsignedLongWithValue:featureTables.count andValue2:tables.count];
        
        for(NSString *tableName in featureTables){
            
            [GPKGTestUtils assertTrue:[tables containsObject:tableName]];
            
            [GPKGTestUtils assertNotNil:[featureStyleExtension tableStylesWithTableName:tableName]];
            [GPKGTestUtils assertNotNil:[featureStyleExtension tableIconsWithTableName:tableName]];
            
            [featureStyleExtension deleteAllFeatureStylesWithTableName:tableName];
            
            [GPKGTestUtils assertNil:[featureStyleExtension tableStylesWithTableName:tableName]];
            [GPKGTestUtils assertNil:[featureStyleExtension tableIconsWithTableName:tableName]];
            
            GPKGFeatureDao *featureDao = [geoPackage getFeatureDaoWithTableName:tableName];
            GPKGResultSet *featureResultSet = [featureDao queryForAll];
            while([featureResultSet moveToNext]){
                
                GPKGFeatureRow *featureRow = [featureDao getFeatureRow:featureResultSet];
                
                [GPKGTestUtils assertNil:[featureStyleExtension stylesWithFeature:featureRow]];
                [GPKGTestUtils assertNil:[featureStyleExtension iconsWithFeature:featureRow]];
                
            }
            [featureResultSet close];
            
            [featureStyleExtension deleteRelationshipsWithTable:tableName];
            [GPKGTestUtils assertFalse:[featureStyleExtension hasWithTable:tableName]];
            
        }
        
        [GPKGTestUtils assertFalse:[featureStyleExtension has]];
        
        [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_ST_TABLE_NAME]];
        [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_IT_TABLE_NAME]];
        [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_CI_TABLE_NAME]];
        
        [featureStyleExtension removeExtension];
        
        [GPKGTestUtils assertFalse:[geoPackage isTable:GPKG_ST_TABLE_NAME]];
        [GPKGTestUtils assertFalse:[geoPackage isTable:GPKG_IT_TABLE_NAME]];
        [GPKGTestUtils assertTrue:[geoPackage isTable:GPKG_CI_TABLE_NAME]];
        
        GPKGContentsIdExtension *contentsIdExtension = [featureStyleExtension contentsId];
        [GPKGTestUtils assertEqualIntWithValue:(int)featureTables.count andValue2:[contentsIdExtension count]];
        [GPKGTestUtils assertEqualIntWithValue:(int)featureTables.count andValue2:[contentsIdExtension deleteIds]];
        [contentsIdExtension removeExtension];
        [GPKGTestUtils assertFalse:[geoPackage isTable:GPKG_CI_TABLE_NAME]];
        
    }

}

+(void) validateTableStyles: (GPKGFeatureTableStyles *) featureTableStyles andStyle: (GPKGStyleRow *) styleRow andStyles: (NSDictionary *) geometryTypeStyles andTypes: (NSDictionary *) geometryTypes{
    
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            GPKGStyleRow *typeStyleRow = styleRow;
            if([geometryTypeStyles objectForKey:typeNumber] != nil){
                typeStyleRow = [geometryTypeStyles objectForKey:typeNumber];
            }
            [GPKGTestUtils assertEqualWithValue:[typeStyleRow id] andValue2:[[featureTableStyles tableStyleWithGeometryType:type] id]];
            NSDictionary *childGeometryTypes = [geometryTypes objectForKey:typeNumber];
            [self validateTableStyles:featureTableStyles andStyle:typeStyleRow andStyles:geometryTypeStyles andTypes:childGeometryTypes];
        }
    }
}

+(void) validateTableIcons: (GPKGFeatureTableStyles *) featureTableStyles andIcon: (GPKGIconRow *) iconRow andIcons: (NSDictionary *) geometryTypeIcons andTypes: (NSDictionary *) geometryTypes{
    
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            GPKGIconRow *typeIconRow = iconRow;
            if([geometryTypeIcons objectForKey:typeNumber] != nil){
                typeIconRow = [geometryTypeIcons objectForKey:typeNumber];
                [GPKGTestUtils assertTrue:[typeIconRow idValue] >= 0];
                [GPKGTestUtils assertNotNil:[typeIconRow data]];
                [GPKGTestUtils assertEqualWithValue:[[NSString alloc] initWithFormat:@"image/%@", GPKG_TEST_ICON_POINT_IMAGE_EXTENSION] andValue2:[typeIconRow contentType]];
                UIImage *iconImage = [typeIconRow dataImage];
                [GPKGTestUtils assertNotNil:iconImage];
                [GPKGTestUtils assertTrue:iconImage.size.width > 0];
                [GPKGTestUtils assertTrue:iconImage.size.height > 0];
            }
            [GPKGTestUtils assertEqualWithValue:[typeIconRow id] andValue2:[[featureTableStyles tableIconWithGeometryType:type] id]];
            NSDictionary *childGeometryTypes = [geometryTypes objectForKey:typeNumber];
            [self validateTableIcons:featureTableStyles andIcon:typeIconRow andIcons:geometryTypeIcons andTypes:childGeometryTypes];
        }
    }
}

+(void) validateRowStyles: (GPKGFeatureTableStyles *) featureTableStyles andFeature: (GPKGFeatureRow *) featureRow andTableStyleDefault: (GPKGStyleRow *) tableStyleDefault andTableStyles: (NSDictionary *) geometryTypeTableStyles andFeatureStyles: (NSDictionary *) featureResultsStyles{
    
    enum SFGeometryType geometryType = [featureRow getGeometryType];
    
    [self validateRowStyles:featureTableStyles andFeature:featureRow andGeometryType:SF_NONE andTableStyleDefault:tableStyleDefault andTableStyles:geometryTypeTableStyles andFeatureStyles:featureResultsStyles];
    
    if(geometryType != SF_NONE && geometryType >= 0){
        
        NSArray<NSNumber *> *geometryTypes = [SFGeometryUtils parentHierarchyOfType:geometryType];
        for(NSNumber *parentGeometryTypeNumber in geometryTypes){
            enum SFGeometryType parentGeometryType = (enum SFGeometryType) [parentGeometryTypeNumber intValue];
            [self validateRowStyles:featureTableStyles andFeature:featureRow andGeometryType:parentGeometryType andTableStyleDefault:tableStyleDefault andTableStyles:geometryTypeTableStyles andFeatureStyles:featureResultsStyles];
        }
        
        NSArray<NSNumber *> *childTypes = [self allChildTypes:geometryType];
        for(NSNumber *childGeometryTypeNumber in childTypes){
            enum SFGeometryType childGeometryType = (enum SFGeometryType) [childGeometryTypeNumber intValue];
            [self validateRowStyles:featureTableStyles andFeature:featureRow andGeometryType:childGeometryType andTableStyleDefault:tableStyleDefault andTableStyles:geometryTypeTableStyles andFeatureStyles:featureResultsStyles];
        }
    }
    
}

+(void) validateRowStyles: (GPKGFeatureTableStyles *) featureTableStyles andFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andTableStyleDefault: (GPKGStyleRow *) tableStyleDefault andTableStyles: (NSDictionary *) geometryTypeTableStyles andFeatureStyles: (NSDictionary *) featureResultsStyles{
    
    GPKGStyleRow *styleRow = nil;
    if (geometryType == SF_NONE || geometryType < 0) {
        styleRow = [featureTableStyles styleWithFeature:featureRow];
        geometryType = [featureRow getGeometryType];
    } else {
        styleRow = [featureTableStyles styleWithFeature:featureRow andGeometryType:geometryType];
    }
    
    NSMutableArray<NSNumber *> *geometryTypes = [[NSMutableArray alloc] init];
    if(geometryType != SF_NONE && geometryType >= 0){
        [geometryTypes addObject:[NSNumber numberWithInt:geometryType]];
        [geometryTypes addObjectsFromArray:[SFGeometryUtils parentHierarchyOfType:geometryType]];
    }
    [geometryTypes addObject:[NSNumber numberWithInt:SF_NONE]];
    
    GPKGStyleRow *expectedStyleRow = nil;
    NSDictionary *geometryTypeRowStyles = [featureResultsStyles objectForKey:[featureRow id]];
    if(geometryTypeRowStyles != nil){
        for(NSNumber *typeNumber in geometryTypes){
            expectedStyleRow = [geometryTypeRowStyles objectForKey:typeNumber];
            if(expectedStyleRow != nil){
                break;
            }
        }
    }
    
    if (expectedStyleRow == nil) {
        for(NSNumber *typeNumber in geometryTypes){
            expectedStyleRow = [geometryTypeTableStyles objectForKey:typeNumber];
            if(expectedStyleRow != nil){
                break;
            }
        }
        
        if (expectedStyleRow == nil) {
            expectedStyleRow = tableStyleDefault;
        }
    }
    
    if (expectedStyleRow != nil) {
        [GPKGTestUtils assertEqualWithValue:[expectedStyleRow id] andValue2:[styleRow id]];
        [GPKGTestUtils assertNotNil:[styleRow table]];
        [GPKGTestUtils assertTrue:[styleRow idValue] >= 0];
        [styleRow name];
        [styleRow description];
        [styleRow color];
        [styleRow hexColor];
        [styleRow opacity];
        [styleRow width];
        [styleRow fillColor];
        [styleRow fillHexColor];
        [styleRow fillOpacity];
    } else {
        [GPKGTestUtils assertNil:styleRow];
    }
    
}

+(void) validateRowIcons: (GPKGFeatureTableStyles *) featureTableStyles andFeature: (GPKGFeatureRow *) featureRow andTableIconDefault: (GPKGIconRow *) tableIconDefault andTableIcons: (NSDictionary *) geometryTypeTableIcons andFeatureIcons: (NSDictionary *) featureResultsIcons{
    
    enum SFGeometryType geometryType = [featureRow getGeometryType];
    
    [self validateRowIcons:featureTableStyles andFeature:featureRow andGeometryType:SF_NONE andTableIconDefault:tableIconDefault andTableIcons:geometryTypeTableIcons andFeatureIcons:featureResultsIcons];
    
    if(geometryType != SF_NONE && geometryType >= 0){
        
        NSArray<NSNumber *> *geometryTypes = [SFGeometryUtils parentHierarchyOfType:geometryType];
        for(NSNumber *parentGeometryTypeNumber in geometryTypes){
            enum SFGeometryType parentGeometryType = (enum SFGeometryType) [parentGeometryTypeNumber intValue];
            [self validateRowIcons:featureTableStyles andFeature:featureRow andGeometryType:parentGeometryType andTableIconDefault:tableIconDefault andTableIcons:geometryTypeTableIcons andFeatureIcons:featureResultsIcons];
        }
        
        NSArray<NSNumber *> *childTypes = [self allChildTypes:geometryType];
        for(NSNumber *childGeometryTypeNumber in childTypes){
            enum SFGeometryType childGeometryType = (enum SFGeometryType) [childGeometryTypeNumber intValue];
            [self validateRowIcons:featureTableStyles andFeature:featureRow andGeometryType:childGeometryType andTableIconDefault:tableIconDefault andTableIcons:geometryTypeTableIcons andFeatureIcons:featureResultsIcons];
        }
    }
    
}

+(void) validateRowIcons: (GPKGFeatureTableStyles *) featureTableStyles andFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType andTableIconDefault: (GPKGIconRow *) tableIconDefault andTableIcons: (NSDictionary *) geometryTypeTableIcons andFeatureIcons: (NSDictionary *) featureResultsIcons{
    
    GPKGIconRow *iconRow = nil;
    if (geometryType == SF_NONE || geometryType < 0) {
        iconRow = [featureTableStyles iconWithFeature:featureRow];
        geometryType = [featureRow getGeometryType];
    } else {
        iconRow = [featureTableStyles iconWithFeature:featureRow andGeometryType:geometryType];
    }
    
    NSMutableArray<NSNumber *> *geometryTypes = [[NSMutableArray alloc] init];
    if(geometryType != SF_NONE && geometryType >= 0){
        [geometryTypes addObject:[NSNumber numberWithInt:geometryType]];
        [geometryTypes addObjectsFromArray:[SFGeometryUtils parentHierarchyOfType:geometryType]];
    }
    [geometryTypes addObject:[NSNumber numberWithInt:SF_NONE]];
    
    GPKGIconRow *expectedIconRow = nil;
    NSDictionary *geometryTypeRowIcons = [featureResultsIcons objectForKey:[featureRow id]];
    if(geometryTypeRowIcons != nil){
        for(NSNumber *typeNumber in geometryTypes){
            expectedIconRow = [geometryTypeRowIcons objectForKey:typeNumber];
            if(expectedIconRow != nil){
                break;
            }
        }
    }
    
    if (expectedIconRow == nil) {
        for(NSNumber *typeNumber in geometryTypes){
            expectedIconRow = [geometryTypeTableIcons objectForKey:typeNumber];
            if(expectedIconRow != nil){
                break;
            }
        }
        
        if (expectedIconRow == nil) {
            expectedIconRow = tableIconDefault;
        }
    }
    
    if (expectedIconRow != nil) {
        [GPKGTestUtils assertEqualWithValue:[expectedIconRow id] andValue2:[iconRow id]];
        [GPKGTestUtils assertNotNil:[iconRow table]];
        [GPKGTestUtils assertTrue:[iconRow idValue] >= 0];
        [iconRow name];
        [iconRow description];
        [iconRow width];
        [iconRow height];
        [iconRow anchorU];
        [iconRow anchorV];
    } else {
        [GPKGTestUtils assertNil:iconRow];
    }
    
}

+(GPKGStyleRow *) randomStyle{
    GPKGStyleRow *styleRow = [[GPKGStyleRow alloc] init];
    
    if ([GPKGTestUtils randomDouble] < .5) {
        [styleRow setName:@"Style Name"];
    }
    if ([GPKGTestUtils randomDouble] < .5) {
        [styleRow setDescription:@"Style Description"];
    }
    [styleRow setColor:[self randomColor]];
    if ([GPKGTestUtils randomDouble] < .5) {
        [styleRow setWidthValue:1.0 + [GPKGTestUtils randomDouble] * 3];
    }
    [styleRow setFillColor:[self randomColor]];
    
    return styleRow;
}

+(GPKGColor *) randomColor{
    
    GPKGColor *color = nil;
    
    if([GPKGTestUtils randomDouble] < .5){
        color = [[GPKGColor alloc] initWithRed:[GPKGTestUtils randomIntLessThan:256] andGreen:[GPKGTestUtils randomIntLessThan:256] andBlue:[GPKGTestUtils randomIntLessThan:256]];
        if([GPKGTestUtils randomDouble] < .5){
            [color setOpacity:(float)[GPKGTestUtils randomDouble]];
        }
    }
    
    return color;
}

+(GPKGIconRow *) randomIcon{
    GPKGIconRow *iconRow = [[GPKGIconRow alloc] init];
    
    NSString *iconImagePath  = [[[NSBundle bundleForClass:[GPKGFeatureStylesUtils class]] resourcePath] stringByAppendingPathComponent:GPKG_TEST_ICON_POINT_IMAGE];
    UIImage *iconImage = [UIImage imageWithContentsOfFile:iconImagePath];
    
    [iconRow setDataWithImage:iconImage andFormat:GPKG_CF_PNG];
    [iconRow setContentType:[[NSString alloc] initWithFormat:@"image/%@", GPKG_TEST_ICON_POINT_IMAGE_EXTENSION]];
    if ([GPKGTestUtils randomDouble] < .5) {
        [iconRow setName:@"Icon Name"];
    }
    if ([GPKGTestUtils randomDouble] < .5) {
        [iconRow setDescription:@"Icon Description"];
    }
    if ([GPKGTestUtils randomDouble] < .5) {
        [iconRow setWidthValue:[GPKGTestUtils randomDouble] * iconImage.size.width];
    }
    if ([GPKGTestUtils randomDouble] < .5) {
        [iconRow setHeightValue:[GPKGTestUtils randomDouble] * iconImage.size.height];
    }
    if ([GPKGTestUtils randomDouble] < .5) {
        [iconRow setAnchorUValue:[GPKGTestUtils randomDouble]];
    }
    if ([GPKGTestUtils randomDouble] < .5) {
        [iconRow setAnchorVValue:[GPKGTestUtils randomDouble]];
    }
    
    return iconRow;
}

+(NSMutableDictionary<NSNumber *, GPKGStyleRow *> *) randomStylesWithGeometryTypes: (NSDictionary *) geometryTypes{
    return [self randomStylesWithGeometryTypes:geometryTypes andRandomSyles:nil];
}

+(NSMutableDictionary<NSNumber *, GPKGIconRow *> *) randomIconsWithGeometryTypes: (NSDictionary *) geometryTypes{
    return [self randomIconsWithGeometryTypes:geometryTypes andRandomIcons:nil];
}

+(NSMutableDictionary<NSNumber *, GPKGStyleRow *> *) randomStylesWithGeometryTypes: (NSDictionary *) geometryTypes andRandomSyles: (NSArray *) randomStyles{
    NSMutableDictionary<NSNumber *, GPKGStyleRow *>  *rowMap = [[NSMutableDictionary alloc] init];
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            if ([GPKGTestUtils randomDouble] < .5) {
                [rowMap setObject:[self randomStyleWithRandomStyles:randomStyles] forKey:[NSNumber numberWithInt:type]];
            }
            NSMutableDictionary *childGeometryTypes = [geometryTypes objectForKey:typeNumber];
            NSMutableDictionary *childRowMap = [self randomStylesWithGeometryTypes:childGeometryTypes andRandomSyles:randomStyles];
            [rowMap setValuesForKeysWithDictionary:childRowMap];
        }
    }
    return rowMap;
}

+(NSMutableDictionary<NSNumber *, GPKGIconRow *> *) randomIconsWithGeometryTypes: (NSDictionary *) geometryTypes andRandomIcons: (NSArray *) randomIcons{
    NSMutableDictionary<NSNumber *, GPKGIconRow *> *rowMap = [[NSMutableDictionary alloc] init];
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            if ([GPKGTestUtils randomDouble] < .5) {
                [rowMap setObject:[self randomIconWithRandomIcons:randomIcons] forKey:[NSNumber numberWithInt:type]];
            }
            NSMutableDictionary *childGeometryTypes = [geometryTypes objectForKey:typeNumber];
            NSMutableDictionary *childRowMap = [self randomIconsWithGeometryTypes:childGeometryTypes andRandomIcons:randomIcons];
            [rowMap setValuesForKeysWithDictionary:childRowMap];
        }
    }
    return rowMap;
}

+(GPKGStyleRow *) randomStyleWithRandomStyles: (NSArray *) randomStyles{
    GPKGStyleRow *randomStyle = nil;
    if(randomStyles != nil){
        randomStyle = [randomStyles objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)randomStyles.count]];
    }else{
        randomStyle = [self randomStyle];
    }
    
    return randomStyle;
}

+(GPKGIconRow *) randomIconWithRandomIcons: (NSArray *) randomIcons{
    GPKGIconRow *randomIcon = nil;
    if(randomIcons != nil){
        randomIcon = [randomIcons objectAtIndex:[GPKGTestUtils randomIntLessThan:(int)randomIcons.count]];
    }else{
        randomIcon = [self randomIcon];
    }
    
    return randomIcon;
}

+(NSMutableArray<NSNumber *> *) allChildTypes: (enum SFGeometryType) geometryType{
    
    NSMutableArray<NSNumber *> *allChildTypes = [[NSMutableArray alloc] init];
    
    NSArray<NSNumber *> *childTypes = [SFGeometryUtils childTypesOfType:geometryType];
    [allChildTypes addObjectsFromArray:childTypes];
    
    for(NSNumber *childTypeNumber in childTypes){
        enum SFGeometryType childType = (enum SFGeometryType) [childTypeNumber intValue];
        [allChildTypes addObjectsFromArray:[self allChildTypes:childType]];
    }
    
    return allChildTypes;
}

@end
