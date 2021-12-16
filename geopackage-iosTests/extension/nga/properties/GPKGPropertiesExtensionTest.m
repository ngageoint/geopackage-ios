//
//  GPKGPropertiesExtensionTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 7/24/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGPropertiesExtensionTest.h"
#import "GPKGPropertiesExtension.h"
#import "GPKGTestUtils.h"
#import "GPKGPropertyNames.h"

@implementation GPKGPropertiesExtensionTest

/**
 * Test properties extension
 */
- (void)testPropertiesExtension {
    
    GPKGPropertiesExtension *extension = [[GPKGPropertiesExtension alloc] initWithGeoPackage:self.geoPackage];
    [GPKGTestUtils assertFalse:[extension has]];
    [GPKGTestUtils assertFalse:[self.geoPackage isTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]];
    
    NSString *name = @"My GeoPackage";
    
    // Test before the extension exists
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[extension properties].count];
    [GPKGTestUtils assertFalse:[extension hasProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numValues]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[extension hasSingleValueWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[extension hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertNil:[extension valueOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertFalse:[extension hasValue:name withProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension deleteProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension deleteValue:name withProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension deleteAll]];
    [extension removeExtension];
    
    GPKGExtensions *extensions = [extension extensionCreate];
    [GPKGTestUtils assertNotNil:extensions];
    [GPKGTestUtils assertTrue:[extension has]];
    [GPKGTestUtils assertTrue:[self.geoPackage isTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]];

    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[extension properties].count];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numValues]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertFalse:[extension hasSingleValueWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertFalse:[extension hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numValuesOfProperty:GPKG_PE_TITLE]];
    
    [GPKGTestUtils assertTrue:[extension addValue:name withProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[extension properties].count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension numValues]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TITLE].count];
    [GPKGTestUtils assertTrue:[extension hasSingleValueWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertTrue:[extension hasValuesWithProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension numValuesOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertEqualWithValue:name andValue2:[extension valueOfProperty:GPKG_PE_TITLE]];
    [GPKGTestUtils assertTrue:[extension hasValue:name withProperty:GPKG_PE_TITLE]];
    
    NSString *tag = @"TAG";
    [GPKGTestUtils assertTrue:[extension addValue:[NSString stringWithFormat:@"%@%d", tag, 1] withProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:(int)[extension properties].count];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[extension numValues]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertTrue:[extension hasSingleValueWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[extension hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[extension hasValue:[NSString stringWithFormat:@"%@%d", tag, 1] withProperty:GPKG_PE_TAG]];
    
    [GPKGTestUtils assertTrue:[extension addValue:[NSString stringWithFormat:@"%@%d", tag, 2] withProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:(int)[extension properties].count];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[extension numValues]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertFalse:[extension hasSingleValueWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[extension hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[extension numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[extension hasValue:[NSString stringWithFormat:@"%@%d", tag, 2] withProperty:GPKG_PE_TAG]];
    
    [GPKGTestUtils assertTrue:[extension addValue:[NSString stringWithFormat:@"%@%d", tag, 3] withProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertTrue:[extension addValue:[NSString stringWithFormat:@"%@%d", tag, 4] withProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertFalse:[extension addValue:[NSString stringWithFormat:@"%@%d", tag, 4] withProperty:GPKG_PE_TAG]];
    
    NSSet<NSString *> *values = [NSSet setWithArray:[extension valuesOfProperty:GPKG_PE_TAG]];
    for (int i = 1; i <= 4; i++) {
        [GPKGTestUtils assertTrue:[values containsObject:[NSString stringWithFormat:@"%@%d", tag, i]]];
        [GPKGTestUtils assertTrue:[extension hasValue:[NSString stringWithFormat:@"%@%d", tag, i] withProperty:GPKG_PE_TAG]];
    }
    
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension deleteValue:[NSString stringWithFormat:@"%@%d", tag, 3] withProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[extension numValuesOfProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertFalse:[extension hasValue:[NSString stringWithFormat:@"%@%d", tag, 3] withProperty:GPKG_PE_TAG]];
    
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[extension deleteProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:(int)[extension properties].count];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[extension numValues]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:(int)[extension valuesOfProperty:GPKG_PE_TAG].count];
    [GPKGTestUtils assertFalse:[extension hasSingleValueWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertFalse:[extension hasValuesWithProperty:GPKG_PE_TAG]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numValuesOfProperty:GPKG_PE_TAG]];
    
    [extension removeExtension];
    [GPKGTestUtils assertFalse:[extension has]];
    [GPKGTestUtils assertFalse:[self.geoPackage isTable:GPKG_EXTENSION_PROPERTIES_TABLE_NAME]];
    
}

/**
 * Test property names
 */
- (void)testPropertyNames {
    
    GPKGPropertiesExtension *extension = [[GPKGPropertiesExtension alloc] initWithGeoPackage:self.geoPackage];
    
    int count = 0;
    
    count += [self testPropertyName:GPKG_PE_CONTRIBUTOR forExtension:extension];
    count += [self testPropertyName:GPKG_PE_COVERAGE forExtension:extension];
    count += [self testPropertyName:GPKG_PE_CREATED forExtension:extension];
    count += [self testPropertyName:GPKG_PE_CREATOR forExtension:extension];
    count += [self testPropertyName:GPKG_PE_DATE forExtension:extension];
    count += [self testPropertyName:GPKG_PE_DESCRIPTION forExtension:extension];
    count += [self testPropertyName:GPKG_PE_IDENTIFIER forExtension:extension];
    count += [self testPropertyName:GPKG_PE_LICENSE forExtension:extension];
    count += [self testPropertyName:GPKG_PE_MODIFIED forExtension:extension];
    count += [self testPropertyName:GPKG_PE_PUBLISHER forExtension:extension];
    count += [self testPropertyName:GPKG_PE_REFERENCES forExtension:extension];
    count += [self testPropertyName:GPKG_PE_RELATION forExtension:extension];
    count += [self testPropertyName:GPKG_PE_SOURCE forExtension:extension];
    count += [self testPropertyName:GPKG_PE_SPATIAL forExtension:extension];
    count += [self testPropertyName:GPKG_PE_SUBJECT forExtension:extension];
    count += [self testPropertyName:GPKG_PE_TAG forExtension:extension];
    count += [self testPropertyName:GPKG_PE_TEMPORAL forExtension:extension];
    count += [self testPropertyName:GPKG_PE_TITLE forExtension:extension];
    count += [self testPropertyName:GPKG_PE_TYPE forExtension:extension];
    count += [self testPropertyName:GPKG_PE_URI forExtension:extension];
    count += [self testPropertyName:GPKG_PE_VALID forExtension:extension];
    count += [self testPropertyName:GPKG_PE_VERSION forExtension:extension];

    [GPKGTestUtils assertEqualIntWithValue:22 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:[extension numValues]];
    
    int deleted = [extension deleteAll];
    [GPKGTestUtils assertTrue:deleted >= count && deleted <= count + 1];
    
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numProperties]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[extension numValues]];
    
    [extension removeExtension];
    [GPKGTestUtils assertFalse:[extension has]];
}

-(int)testPropertyName: (NSString *) property forExtension: (GPKGPropertiesExtension *) extension{
    
    [GPKGTestUtils assertFalse:[extension hasProperty:property]];
    
    int count = 1;
    if([GPKGTestUtils randomDouble] < .5){
        count = 1 + [GPKGTestUtils randomIntLessThan:10];
    }
    
    NSMutableSet<NSString *> *values = [NSMutableSet set];
    for (int i = 0; i < count; i++) {
        NSString *value = [[NSProcessInfo processInfo] globallyUniqueString];
        [values addObject:value];
        [extension addValue:value withProperty:property];
    }
    
    [GPKGTestUtils assertTrue:[extension hasProperty:property]];
    [GPKGTestUtils assertEqualIntWithValue:count andValue2:[extension numValuesOfProperty:property]];
    [GPKGTestUtils assertEqualBoolWithValue:count == 1 andValue2:[extension hasSingleValueWithProperty:property]];
    [GPKGTestUtils assertTrue:[extension hasValuesWithProperty:property]];
    
    NSArray<NSString *> *propertyValues = [extension valuesOfProperty:property];
    [GPKGTestUtils assertEqualIntWithValue:(int)values.count andValue2:(int)propertyValues.count];
    for(NSString *value in propertyValues){
        [GPKGTestUtils assertTrue:[values containsObject:value]];
        [GPKGTestUtils assertTrue:[extension hasValue:value withProperty:property]];
    }
    
    return count;
}

@end
