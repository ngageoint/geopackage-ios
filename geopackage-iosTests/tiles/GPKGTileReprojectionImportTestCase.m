//
//  GPKGTileReprojectionImportTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/19/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionImportTestCase.h"
#import "GPKGTileReprojectionTestUtils.h"

@implementation GPKGTileReprojectionImportTestCase

-(void) testReproject{
    [GPKGTileReprojectionTestUtils testReprojectWithGeoPackage:self.geoPackage];
}

-(void) testReprojectReplace{
    [GPKGTileReprojectionTestUtils testReprojectReplaceWithGeoPackage:self.geoPackage];
}

@end
