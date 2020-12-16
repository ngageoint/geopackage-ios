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

-(void) testReprojectToZoom{
    [GPKGTileReprojectionTestUtils testReprojectToZoomWithGeoPackage:self.geoPackage];
}

-(void) testReprojectMatrixAndTileLengths{
    [GPKGTileReprojectionTestUtils testReprojectMatrixAndTileLengthsWithGeoPackage:self.geoPackage];
}

-(void) testReprojectOptimize{
    [GPKGTileReprojectionTestUtils testReprojectOptimizeWithGeoPackage:self.geoPackage andWorld:NO];
}

-(void) testReprojectOptimizeWorld{
    [GPKGTileReprojectionTestUtils testReprojectOptimizeWithGeoPackage:self.geoPackage andWorld:YES];
}

-(void) testReprojectWebMercator{
    [GPKGTileReprojectionTestUtils testReprojectWebMercatorWithGeoPackage:self.geoPackage andWorld:NO];
}

-(void) testReprojectWebMercatorWorld{
    [GPKGTileReprojectionTestUtils testReprojectWebMercatorWithGeoPackage:self.geoPackage andWorld:YES];
}

-(void) testReprojectPlatteCarre{
    [GPKGTileReprojectionTestUtils testReprojectPlatteCarreWithGeoPackage:self.geoPackage andWorld:NO];
}

-(void) testReprojectPlatteCarreWorld{
    [GPKGTileReprojectionTestUtils testReprojectPlatteCarreWithGeoPackage:self.geoPackage andWorld:YES];
}

-(void) testReprojectCancel{
    [GPKGTileReprojectionTestUtils testReprojectCancelWithGeoPackage:self.geoPackage];
}

@end
