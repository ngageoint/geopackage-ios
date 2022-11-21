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
#import "GPKGDateTimeUtils.h"

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
    NSDateFormatter *df = [GPKGDateTimeUtils createFormatterWithFormat:format];
    return [df dateFromString:value];
}

@end
