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

@implementation GPKGFeatureStylesUtils

+(void) testFeatureStylesWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    // TODO
}

+(void) validateTableStyles: (GPKGFeatureTableStyles *) featureTableStyles andStyle: (GPKGStyleRow *) styleRow andStyles: (NSDictionary *) geometryTypeStyles andTypes: (NSDictionary *) geometryTypes{
    
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            GPKGStyleRow *typeStyleRow = styleRow;
            if([geometryTypeStyles objectForKey:typeNumber] != nil){
                typeStyleRow = [geometryTypeStyles objectForKey:typeNumber];
            }
            [GPKGTestUtils assertEqualWithValue:[typeStyleRow getId] andValue2:[[featureTableStyles tableStyleWithGeometryType:type] getId]];
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
                [GPKGTestUtils assertTrue:[[typeIconRow getId] intValue] >= 0];
                [GPKGTestUtils assertNotNil:[typeIconRow data]];
                [GPKGTestUtils assertEqualWithValue:[[NSString alloc] initWithFormat:@"image/%@", GPKG_TEST_ICON_POINT_IMAGE_EXTENSION] andValue2:[typeIconRow contentType]];
                UIImage *iconImage = [typeIconRow dataImage];
                [GPKGTestUtils assertNotNil:iconImage];
                [GPKGTestUtils assertTrue:iconImage.size.width > 0];
                [GPKGTestUtils assertTrue:iconImage.size.height > 0];
            }
            [GPKGTestUtils assertEqualWithValue:[typeIconRow getId] andValue2:[[featureTableStyles tableIconWithGeometryType:type] getId]];
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

+(NSDictionary *) randomStylesWithGeometryTypes: (NSDictionary *) geometryTypes{
    return [self randomStylesWithGeometryTypes:geometryTypes andRandomSyles:nil];
}

+(NSDictionary *) randomIconsWithGeometryTypes: (NSDictionary *) geometryTypes{
    return [self randomIconsWithGeometryTypes:geometryTypes andRandomIcons:nil];
}

+(NSDictionary *) randomStylesWithGeometryTypes: (NSDictionary *) geometryTypes andRandomSyles: (NSArray *) randomStyles{
    NSMutableDictionary *rowMap = [[NSMutableDictionary alloc] init];
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            if ([GPKGTestUtils randomDouble] < .5) {
                [rowMap setObject:[self randomStyleWithRandomStyles:randomStyles] forKey:[NSNumber numberWithInt:type]];
            }
            NSDictionary *childGeometryTypes = [geometryTypes objectForKey:typeNumber];
            NSDictionary *childRowMap = [self randomStylesWithGeometryTypes:childGeometryTypes andRandomSyles:randomStyles];
            [rowMap setValuesForKeysWithDictionary:childRowMap];
        }
    }
    return rowMap;
}

+(NSDictionary *) randomIconsWithGeometryTypes: (NSDictionary *) geometryTypes andRandomIcons: (NSArray *) randomIcons{
    NSMutableDictionary *rowMap = [[NSMutableDictionary alloc] init];
    if(geometryTypes != nil){
        for(NSNumber *typeNumber in [geometryTypes allKeys]){
            enum SFGeometryType type = (enum SFGeometryType) [typeNumber intValue];
            if ([GPKGTestUtils randomDouble] < .5) {
                [rowMap setObject:[self randomIconWithRandomIcons:randomIcons] forKey:[NSNumber numberWithInt:type]];
            }
            NSDictionary *childGeometryTypes = [geometryTypes objectForKey:typeNumber];
            NSDictionary *childRowMap = [self randomIconsWithGeometryTypes:childGeometryTypes andRandomIcons:randomIcons];
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

+(NSArray<NSNumber *> *) allChildTypes: (enum SFGeometryType) geometryType{
    
    NSMutableArray<NSNumber *> *allChildTypes = [[NSMutableArray alloc] init];
    
    NSArray<NSNumber *> *childTypes = [SFGeometryUtils childTypesOfType:geometryType];
    [allChildTypes addObjectsFromArray:childTypes];
    
    for(NSNumber *childTypeNumber in childTypes){
        enum SFGeometryType childType = (enum SFGeometryType) childTypeNumber;
        [allChildTypes addObjectsFromArray:[self allChildTypes:childType]];
    }
    
    return allChildTypes;
}


@end
