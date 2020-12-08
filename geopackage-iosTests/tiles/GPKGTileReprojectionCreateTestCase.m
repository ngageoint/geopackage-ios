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

-(void) testReprojectZoomLevels{
    [GPKGTileReprojectionTestUtils testReprojectZoomLevelsWithGeoPackage:self.geoPackage];
}

-(void) testReprojectZoomOverwrite{
    [GPKGTileReprojectionTestUtils testReprojectZoomOverwriteWithGeoPackage:self.geoPackage];
}

-(void) testReprojectOverwrite{
    [GPKGTileReprojectionTestUtils testReprojectOverwriteWithGeoPackage:self.geoPackage];
}

-(void) testReprojectToZoom{
    [GPKGTileReprojectionTestUtils testReprojectToZoomWithGeoPackage:self.geoPackage];
}

-(void) testReprojectMatrixAndTileLengths{
    [GPKGTileReprojectionTestUtils testReprojectMatrixAndTileLengthsWithGeoPackage:self.geoPackage];
}

-(void) testReprojectOptimize{
    [GPKGTileReprojectionTestUtils testReprojectOptimizeWithGeoPackage:self.geoPackage];
}

@end
