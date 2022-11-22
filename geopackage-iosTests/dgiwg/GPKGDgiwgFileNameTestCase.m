//
//  GPKGDgiwgFileNameTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/21/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgFileNameTestCase.h"
#import "GPKGDgiwgFileName.h"
#import "GPKGTestUtils.h"
#import "GPKGDateConverter.h"

@implementation GPKGDgiwgFileNameTestCase

/**
 * Test file name example 1
 */
-(void) testExample1{
    
    NSString *name = @"AGC_BUCK_Ft-Bliss_14-20_v1-0_29AUG2016.gpkg";
    
    GPKGDgiwgFileName *fileName = [[GPKGDgiwgFileName alloc] initWithName:name];
    
    [self testName:name withFileName:fileName];
    
    [GPKGTestUtils assertTrue:[fileName isInformative]];
    
    [GPKGTestUtils assertEqualWithValue:@"AGC" andValue2:fileName.producer];
    [GPKGTestUtils assertEqualWithValue:@"BUCK" andValue2:fileName.dataProduct];
    [GPKGTestUtils assertEqualWithValue:@"Ft Bliss" andValue2:fileName.geographicCoverageArea];
    [GPKGTestUtils assertEqualWithValue:@"14-20" andValue2:fileName.zoomLevels];
    [GPKGTestUtils assertEqualIntWithValue:14 andValue2:[[fileName zoomLevel1] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:20 andValue2:[[fileName zoomLevel2] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"1.0" andValue2:fileName.version];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[[fileName majorVersion] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[[fileName minorVersion] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"29AUG2016" andValue2:fileName.creationDateText];
    [GPKGTestUtils assertEqualWithValue:[self dateValue:@"29AUG2016" withFormat:@"ddMMMyyyy"] andValue2:fileName.creationDate];
    [GPKGTestUtils assertNil:fileName.additional];
    
    [GPKGTestUtils assertEqualWithValue:[name stringByDeletingPathExtension] andValue2:[fileName name]];
    
}

/**
 * Test file name example 2
 */
-(void) testExample2{
    
    NSString *name = @"OGL_BOUND_UK_1-10000_v1-0_09APR2020.gpkg";
    
    GPKGDgiwgFileName *fileName = [[GPKGDgiwgFileName alloc] initWithName:name];
    
    [self testName:name withFileName:fileName];
    
    [GPKGTestUtils assertTrue:[fileName isInformative]];
    
    [GPKGTestUtils assertEqualWithValue:@"OGL" andValue2:fileName.producer];
    [GPKGTestUtils assertEqualWithValue:@"BOUND" andValue2:fileName.dataProduct];
    [GPKGTestUtils assertEqualWithValue:@"UK" andValue2:fileName.geographicCoverageArea];
    [GPKGTestUtils assertEqualWithValue:@"1:10000" andValue2:fileName.zoomLevels];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[[fileName zoomLevel1] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:10000 andValue2:[[fileName zoomLevel2] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"1.0" andValue2:fileName.version];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[[fileName majorVersion] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:0 andValue2:[[fileName minorVersion] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"09APR2020" andValue2:fileName.creationDateText];
    [GPKGTestUtils assertEqualWithValue:[self dateValue:@"09APR2020" withFormat:@"ddMMMyyyy"] andValue2:fileName.creationDate];
    [GPKGTestUtils assertNil:fileName.additional];
    
    [GPKGTestUtils assertEqualWithValue:[name stringByDeletingPathExtension] andValue2:[fileName name]];
    
}

/**
 * Test file name additional elements
 */
-(void) testAdditionalElements{
    
    NSString *name = @"Producer_Data-Product_Geographic-Coverage-Area_1-12_v3-2_2021-11-16_Additional_Additional-Two.gpkg";
    
    GPKGDgiwgFileName *fileName = [[GPKGDgiwgFileName alloc] initWithName:name];
    
    [self testName:name withFileName:fileName];
    
    [GPKGTestUtils assertTrue:[fileName isInformative]];
    
    [GPKGTestUtils assertEqualWithValue:@"Producer" andValue2:fileName.producer];
    [GPKGTestUtils assertEqualWithValue:@"Data Product" andValue2:fileName.dataProduct];
    [GPKGTestUtils assertEqualWithValue:@"Geographic Coverage Area" andValue2:fileName.geographicCoverageArea];
    [GPKGTestUtils assertEqualWithValue:@"1-12" andValue2:fileName.zoomLevels];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[[fileName zoomLevel1] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:12 andValue2:[[fileName zoomLevel2] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"3.2" andValue2:fileName.version];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[[fileName majorVersion] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[[fileName minorVersion] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"2021-11-16" andValue2:fileName.creationDateText];
    [GPKGTestUtils assertEqualWithValue:[self dateValue:@"2021-11-16" withFormat:@"yyyy-MM-dd"] andValue2:fileName.creationDate];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:(int)fileName.additional.count];
    [GPKGTestUtils assertEqualWithValue:@"Additional" andValue2:[fileName.additional objectAtIndex:0]];
    [GPKGTestUtils assertEqualWithValue:@"Additional Two" andValue2:[fileName.additional objectAtIndex:1]];
    
    [GPKGTestUtils assertEqualWithValue:[name stringByDeletingPathExtension] andValue2:[fileName name]];
    
}

/**
 * Test file name unknown elements
 */
-(void) testUnknownElements{
    
    NSString *name = @"Producer_Data-Product_Geographic-Coverage-Area_Zoom-Levels_Version_20211116.gpkg";
    
    GPKGDgiwgFileName *fileName = [[GPKGDgiwgFileName alloc] initWithName:name];
    
    [self testName:name withFileName:fileName];
    
    [GPKGTestUtils assertTrue:[fileName isInformative]];
    
    [GPKGTestUtils assertEqualWithValue:@"Producer" andValue2:fileName.producer];
    [GPKGTestUtils assertEqualWithValue:@"Data Product" andValue2:fileName.dataProduct];
    [GPKGTestUtils assertEqualWithValue:@"Geographic Coverage Area" andValue2:fileName.geographicCoverageArea];
    [GPKGTestUtils assertEqualWithValue:@"Zoom Levels" andValue2:fileName.zoomLevels];
    [GPKGTestUtils assertNil:[fileName zoomLevel1]];
    [GPKGTestUtils assertNil:[fileName zoomLevel2]];
    [GPKGTestUtils assertEqualWithValue:@"Version" andValue2:fileName.version];
    [GPKGTestUtils assertNil:[fileName majorVersion]];
    [GPKGTestUtils assertNil:[fileName minorVersion]];
    [GPKGTestUtils assertEqualWithValue:@"20211116" andValue2:fileName.creationDateText];
    [GPKGTestUtils assertNil:fileName.creationDate];
    [GPKGTestUtils assertNil:fileName.additional];
    
    [GPKGTestUtils assertEqualWithValue:[name stringByDeletingPathExtension] andValue2:[fileName name]];
    
}

/**
 * Test invalid file name
 */
-(void) testInvalid{

    NSString *name = @"Producer_Data-Product_Geographic-Coverage-Area_1-12_v3-2.gpkg";

    GPKGDgiwgFileName *fileName = [[GPKGDgiwgFileName alloc] initWithName:name];
    
    [self testName:name withFileName:fileName];
    
    [GPKGTestUtils assertFalse:[fileName isInformative]];

    [GPKGTestUtils assertEqualWithValue:@"Producer" andValue2:fileName.producer];
    [GPKGTestUtils assertEqualWithValue:@"Data Product" andValue2:fileName.dataProduct];
    [GPKGTestUtils assertEqualWithValue:@"Geographic Coverage Area" andValue2:fileName.geographicCoverageArea];
    [GPKGTestUtils assertEqualWithValue:@"1-12" andValue2:fileName.zoomLevels];
    [GPKGTestUtils assertEqualIntWithValue:1 andValue2:[[fileName zoomLevel1] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:12 andValue2:[[fileName zoomLevel2] intValue]];
    [GPKGTestUtils assertEqualWithValue:@"3.2" andValue2:fileName.version];
    [GPKGTestUtils assertEqualIntWithValue:3 andValue2:[[fileName majorVersion] intValue]];
    [GPKGTestUtils assertEqualIntWithValue:2 andValue2:[[fileName minorVersion] intValue]];
    [GPKGTestUtils assertNil:fileName.creationDateText];
    [GPKGTestUtils assertNil:fileName.creationDate];
    [GPKGTestUtils assertNil:fileName.additional];

    [GPKGTestUtils assertEqualWithValue:[name stringByDeletingPathExtension] andValue2:[fileName name]];

}

/**
 * Test other file name creation options
 *
 * @param name
 *            name
 * @param fileName
 *            DGIWG file name
 */
-(void) testName: (NSString *) name withFileName: (GPKGDgiwgFileName *) fileName{

    [GPKGTestUtils assertEqualWithValue:fileName andValue2:[[GPKGDgiwgFileName alloc] initWithName:name]];
    [GPKGTestUtils assertEqualWithValue:fileName andValue2:[[GPKGDgiwgFileName alloc] initWithName:[name stringByDeletingPathExtension]]];
     [GPKGTestUtils assertEqualWithValue:fileName andValue2:[[GPKGDgiwgFileName alloc] initWithName:[NSString stringWithFormat:@"/base/directory/%@", name]]];
     [GPKGTestUtils assertEqualWithValue:fileName andValue2:[[GPKGDgiwgFileName alloc] initWithName:[[NSString stringWithFormat:@"/base/directory/%@", name] stringByDeletingPathExtension]]];

}

/**
 * Get the date value
 *
 * @param value
 *            date value
 * @param format
 *            date format
 * @return date
 */
-(NSDate *) dateValue: (NSString *) value withFormat: (NSString *) format{
    NSDateFormatter *df = [GPKGDateConverter createFormatterWithFormat:format];
    return [df dateFromString:value];
}

@end
