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

-(void) testReprojectZoomLevels{
    [GPKGTileReprojectionTestUtils testReprojectZoomLevelsWithGeoPackage:self.geoPackage];
}

-(void) testReprojectZoomOverwrite{
    [GPKGTileReprojectionTestUtils testReprojectZoomOverwriteWithGeoPackage:self.geoPackage];
}

-(void) testReprojectOverwrite{
    [GPKGTileReprojectionTestUtils testReprojectOverwriteWithGeoPackage:self.geoPackage];
}

@end
