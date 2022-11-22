//
//  GPKGDgiwgCoordinateReferenceSystemTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/22/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgCoordinateReferenceSystemTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "GPKGUTMZone.h"

@implementation GPKGDgiwgCoordinateReferenceSystemTestCase

/**
 * Test the Coordinate Reference Systems
 */
-(void) testCRS{
    // TODO
}

/**
 * Test Tiles 2D
 */
-(void) testTiles2D{
    
    NSArray<GPKGDgiwgCoordinateReferenceSystems *> *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemsForType:GPKG_DGIWG_DT_TILES_2D];

    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:3395]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:3857]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:5041]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:5042]]];

    for(NSInteger code = GPKG_UTM_NORTH_MIN; code <= GPKG_UTM_NORTH_MAX; code++){
        [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:(int)code]]];
    }
    for(NSInteger code = GPKG_UTM_SOUTH_MIN; code <= GPKG_UTM_SOUTH_MAX; code++){
        [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:(int)code]]];
    }
    
}

/**
 * Test Tiles 3D
 */
-(void) testTiles3D{

    NSArray<GPKGDgiwgCoordinateReferenceSystems *> *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemsForType:GPKG_DGIWG_DT_TILES_3D];

    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:3395]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:4326]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:4979]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:5041]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:5042]]];
    
}

/**
 * Test Features 2D
 */
-(void) testFeatures2D{

    NSArray<GPKGDgiwgCoordinateReferenceSystems *> *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemsForType:GPKG_DGIWG_DT_FEATURES_2D];

    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:4326]]];
    
}

/**
 * Test Features 3D
 */
-(void) testFeatures3D{
    
    NSArray<GPKGDgiwgCoordinateReferenceSystems *> *crs = [GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemsForType:GPKG_DGIWG_DT_FEATURES_3D];

    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:4979]]];
    [GPKGTestUtils assertTrue:[crs containsObject:[GPKGDgiwgCoordinateReferenceSystems coordinateReferenceSystemWithEPSG:9518]]];
    
}

/**
 * Test Lambert Conic Conformal 1SP
 */
-(void) testLambertConicConformal1SP{
    // TODO
}

/**
 * Test Lambert Conic Conformal 2SP
 */
-(void) testLambertConicConformal2SP{
    // TODO
}

@end
