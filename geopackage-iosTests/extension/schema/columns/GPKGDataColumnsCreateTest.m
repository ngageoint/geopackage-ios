//
//  GPKGDataColumnsCreateTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/24.
//  Copyright © 2024 NGA. All rights reserved.
//

#import "GPKGDataColumnsCreateTest.h"
#import "GPKGDataColumnsUtils.h"

@implementation GPKGDataColumnsCreateTest

-(void) testColumnTitles {
    [GPKGDataColumnsUtils testColumnTitles:self.geoPackage];
}

-(void) testSaveLoadSchema {
    [GPKGDataColumnsUtils testSaveLoadSchema:self.geoPackage];
}

@end
