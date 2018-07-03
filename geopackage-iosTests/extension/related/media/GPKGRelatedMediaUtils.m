//
//  GPKGRelatedMediaUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedMediaUtils.h"
#import "GPKGMediaTable.h"
#import "GPKGTestUtils.h"
#import "GPKGMediaRow.h"
#import "GPKGRelatedTablesUtils.h"

@implementation GPKGRelatedMediaUtils

+(void) testMedia: (GPKGGeoPackage *) geoPackage{
    // TODO
}

/**
 * Validate contents
 *
 * @param contents
 *            contents
 * @param mediaTable
 *            media table
 */
+(void) validateContents: (GPKGContents *) contents withTable: (GPKGMediaTable *) mediaTable{
    [GPKGTestUtils assertNotNil:contents];
    [GPKGTestUtils assertEqualIntWithValue:-1 andValue2:(int)[contents getContentsDataType]];
    [GPKGTestUtils assertEqualWithValue:[GPKGRelationTypes name:[GPKGMediaTable relationType]] andValue2:contents.dataType];
    [GPKGTestUtils assertEqualWithValue:mediaTable.tableName andValue2:contents.tableName];
    [GPKGTestUtils assertNotNil:contents.lastChange];
}

/**
 * Validate a media row for expected Dublin Core Columns
 *
 * @param mediaRow
 *            media row
 */
+(void) validateDublinCoreColumnsInRow: (GPKGMediaRow *) mediaRow{
    
    [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:mediaRow andType:GPKG_DCM_IDENTIFIER];
    [GPKGRelatedTablesUtils validateDublinCoreColumnsWithRow:mediaRow andType:GPKG_DCM_FORMAT];
    
}

@end
