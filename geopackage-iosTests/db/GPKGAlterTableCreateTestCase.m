//
//  GPKGAlterTableCreateTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAlterTableCreateTestCase.h"
#import "GPKGAlterTableUtils.h"

@implementation GPKGAlterTableCreateTestCase

/**
 * Test column alters
 */
-(void) testColumns{
    [GPKGAlterTableUtils testColumns:self.geoPackage];
}

/**
 * Test copy feature table
 */
-(void) testCopyFeatureTable{
    [GPKGAlterTableUtils testCopyFeatureTable:self.geoPackage];
}

/**
 * Test copy tile table
 */
-(void) testCopyTileTable{
    [GPKGAlterTableUtils testCopyTileTable:self.geoPackage];
}

/**
 * Test copy attributes table
 */
-(void) testCopyAttributesTable{
    [GPKGAlterTableUtils testCopyAttributesTable:self.geoPackage];
}

/**
 * Test copy user table
 */
-(void) testCopyUserTable{
    [GPKGAlterTableUtils testCopyUserTable:self.geoPackage];
}

@end
