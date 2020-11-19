//
//  GPKGTileReprojectionCreateTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/19/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTileReprojectionCreateTestCase.h"
#import "GPKGTileReprojectionTestUtils.h"

@implementation GPKGTileReprojectionCreateTestCase

-(void) testReproject{
    [GPKGTileReprojectionTestUtils testReprojectWithGeoPackage:self.geoPackage];
}

-(void) testReprojectReplace{
    [GPKGTileReprojectionTestUtils testReprojectReplaceWithGeoPackage:self.geoPackage];
}

@end
