//
//  GPKGDataColumnsImportTest.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/7/24.
//  Copyright © 2024 NGA. All rights reserved.
//

#import "GPKGDataColumnsImportTest.h"
#import "GPKGDataColumnsUtils.h"

@implementation GPKGDataColumnsImportTest

-(void) testColumnTitles {
    [GPKGDataColumnsUtils testColumnTitles:self.geoPackage];
}

-(void) testSaveLoadSchema {
    [GPKGDataColumnsUtils testSaveLoadSchema:self.geoPackage];
}

@end
