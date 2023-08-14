//
//  GPKGDgiwgCoordinateReferenceSystemTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 11/22/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgCoordinateReferenceSystemTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "GPKGUTMZone.h"
#import "CRSWriter.h"
#import "PROJProjectionFactory.h"
#import "CRSReader.h"
#import "PROJProjectionConstants.h"
#import "CRSPrimeMeridians.h"
#import "GPKGDgiwgWellKnownText.h"

@implementation GPKGDgiwgCoordinateReferenceSystemTestCase

/**
 * Test the Coordinate Reference Systems
 */
-(void) testCRS{
    
    for(int i = 0; i <= GPKG_DGIWG_CRS_EPSG_32760; i++){
        GPKGDgiwgCoordinateReferenceSystems *crs = [GPKGDgiwgCoordinateReferenceSystems fromType:i];
        
        GPKGSpatialReferenceSystem *srs = [crs createSpatialReferenceSystem];
        
        [GPKGTestUtils assertEqualWithValue:[crs name] andValue2:srs.srsName];
        [GPKGTestUtils assertEqualIntWithValue:[crs code] andValue2:[srs.srsId intValue]];
        [GPKGTestUtils assertEqualWithValue:[crs authority] andValue2:srs.organization];
        [GPKGTestUtils assertEqualIntWithValue:[crs code] andValue2:[srs.organizationCoordsysId intValue]];
        [GPKGTestUtils assertEqualWithValue:[crs theDescription] andValue2:srs.theDescription];
        NSString *definition = [crs wkt];
        if([crs crsType] == CRS_TYPE_COMPOUND){
            definition = GPKG_UNDEFINED_DEFINITION;
        }
        [GPKGTestUtils assertEqualWithValue:definition andValue2:srs.definition];
        [GPKGTestUtils assertEqualWithValue:[crs wkt] andValue2:srs.definition_12_063];
        
        GPKGBoundingBox *bounds = [crs bounds];
        GPKGBoundingBox *wgs84Bounds = [crs wgs84Bounds];
        
        NSLog(@"%@", [crs authorityAndCode]);
        NSLog(@"Min Longitude: %@", bounds.minLongitude);
        NSLog(@"Min Latitude: %@", bounds.minLatitude);
        NSLog(@"Max Longitude: %@", bounds.maxLongitude);
        NSLog(@"Max Latitude: %@", bounds.maxLatitude);
        
        if(![bounds isEqual:wgs84Bounds]){
            NSLog(@"Min Longitude: %@", wgs84Bounds.minLongitude);
            NSLog(@"Min Latitude: %@", wgs84Bounds.minLatitude);
            NSLog(@"Max Longitude: %@", wgs84Bounds.maxLongitude);
            NSLog(@"Max Latitude: %@", wgs84Bounds.maxLatitude);
        }
        
        NSLog(@"%@", [CRSWriter writePrettyWithText:[crs wkt]]);
        
        PROJProjection *projection = [PROJProjectionFactory cachelessProjectionByDefinition:[crs wkt]];
        if([projection authority] != nil && [projection authority].length != 0){
            [GPKGTestUtils assertEqualWithValue:[crs authority] andValue2:[projection authority]];
        }
        if([projection code] != nil && [projection code].length != 0){
            [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%d", [crs code]] andValue2:[projection code]];
        }
        [GPKGTestUtils assertEqualWithValue:[crs wkt] andValue2:[projection definition]];
        [GPKGTestUtils assertEqualIntWithValue:[crs crsType] andValue2:[projection definitionCRS].type];
        
        NSString *authority = [crs authority];
        int code = [crs code];
        
        CRSObject *crsObject = [CRSReader read:[crs wkt]];
        if(crsObject.type == CRS_TYPE_COMPOUND){
            CRSCompoundCoordinateReferenceSystem *compound = (CRSCompoundCoordinateReferenceSystem *) crsObject;
            CRSSimpleCoordinateReferenceSystem *simple = [compound coordinateReferenceSystemAtIndex:0];
            CRSIdentifier *identifier = [simple identifierAtIndex:0];
            authority = identifier.name;
            code = [identifier.uniqueIdentifier intValue];
        }
        
    }
    
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

    int epsg = 9801;
    NSString *name = @"Lambert_Conformal_Conic (1SP)";
    enum CRSType crsType = CRS_TYPE_GEODETIC;
    CRSGeoDatums *datum = [CRSGeoDatums fromType:CRS_DATUM_NAD83];
    double latitudeOfOrigin = 25;
    double centralMeridian = -95;
    double scaleFactor = 1;
    double falseEasting = 0;
    double falseNorthing = 0;

    GPKGSpatialReferenceSystem *srs = [GPKGDgiwgCoordinateReferenceSystems createLambertConicConformal1SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    NSString *wkt = [GPKGDgiwgWellKnownText lambertConicConformal1SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    [self testLambertConicConformal1SPWithEPSG:epsg andName:name andDatum:datum andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing andWKT:wkt andDescription:[GPKGDgiwgWellKnownText lambertConicConformal1SPDescription] andSRS:srs];

    epsg = 0000;
    name = @"Unnamed Lambert_Conformal_Conic using 1SP";
    crsType = CRS_TYPE_GEOGRAPHIC;
    datum = [CRSGeoDatums fromType:CRS_DATUM_NAD83];
    latitudeOfOrigin = 49;
    centralMeridian = -95;
    scaleFactor = 1;
    falseEasting = 0;
    falseNorthing = 0;

    srs = [GPKGDgiwgCoordinateReferenceSystems createLambertConicConformal1SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    wkt = [GPKGDgiwgWellKnownText lambertConicConformal1SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    [self testLambertConicConformal1SPWithEPSG:epsg andName:name andDatum:datum andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing andWKT:wkt andDescription:[GPKGDgiwgWellKnownText lambertConicConformal1SPDescription] andSRS:srs];
    
}

/**
 * Test Lambert Conic Conformal 2SP
 */
-(void) testLambertConicConformal2SP{

    int epsg = 9802;
    NSString *name = @"Lambert Conic Conformal (2SP)";
    enum CRSType crsType = CRS_TYPE_GEODETIC;
    CRSGeoDatums *datum = [CRSGeoDatums fromType:CRS_DATUM_NAD83];
    double standardParallel1 = 30;
    double standardParallel2 = 60;
    double latitudeOfOrigin = 30;
    double centralMeridian = 126;
    double falseEasting = 0;
    double falseNorthing = 0;
    
    GPKGSpatialReferenceSystem *srs = [GPKGDgiwgCoordinateReferenceSystems createLambertConicConformal2SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    NSString *wkt = [GPKGDgiwgWellKnownText lambertConicConformal2SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    [self testLambertConicConformal2SPWithEPSG:epsg andName:name andDatum:datum andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing andWKT:wkt andDescription:[GPKGDgiwgWellKnownText lambertConicConformal2SPDescription] andSRS:srs];

    epsg = 3978;
    name = @"NAD83 / Canada Atlas Lambert";
    crsType = CRS_TYPE_GEOGRAPHIC;
    datum = [CRSGeoDatums fromType:CRS_DATUM_NAD83];
    standardParallel1 = 49;
    standardParallel2 = 77;
    latitudeOfOrigin = 49;
    centralMeridian = -95;
    falseEasting = 0;
    falseNorthing = 0;
    
    srs = [GPKGDgiwgCoordinateReferenceSystems createLambertConicConformal2SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    wkt = [GPKGDgiwgWellKnownText lambertConicConformal2SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:[datum type] andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];

    [self testLambertConicConformal2SPWithEPSG:epsg andName:name andDatum:datum andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing andWKT:wkt andDescription:[GPKGDgiwgWellKnownText lambertConicConformal2SPDescription] andSRS:srs];
    
}

/**
 * Test Lambert Conic Conformal 1SP
 *
 * @param epsg
 *            EPSG code
 * @param name
 *            name
 * @param datum
 *            geo datum
 * @param latitudeOfOrigin
 *            latitude of origin
 * @param centralMeridian
 *            central meridian
 * @param scaleFactor
 *            scale factor
 * @param falseEasting
 *            false easting
 * @param falseNorthing
 *            false northing
 * @param wkt
 *            well-known text
 * @param description
 *            description
 * @param srs
 *            spatial reference system
 */
-(void) testLambertConicConformal1SPWithEPSG: (int) epsg andName: (NSString *) name andDatum: (CRSGeoDatums *) datum andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andScaleFactor: (double) scaleFactor andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing andWKT: (NSString *) wkt andDescription: (NSString *) description andSRS: (GPKGSpatialReferenceSystem *) srs{
    
    CRSOperationMethod *method = [self testLambertConicConformalWithEPSG:epsg andName:name andDatum:datum andWKT:wkt andDescription:[GPKGDgiwgWellKnownText lambertConicConformal1SPDescription] andSRS:srs];

    [GPKGTestUtils assertEqualWithValue:@"Lambert_Conformal_Conic_1SP" andValue2:method.name];
    [GPKGTestUtils assertEqualWithValue:@"latitude_of_origin" andValue2:[method parameterAtIndex:0].name];
    [GPKGTestUtils assertEqualDoubleWithValue:latitudeOfOrigin andValue2:[method parameterAtIndex:0].value];
    [GPKGTestUtils assertEqualWithValue:@"central_meridian" andValue2:[method parameterAtIndex:1].name];
    [GPKGTestUtils assertEqualDoubleWithValue:centralMeridian andValue2:[method parameterAtIndex:1].value];
    [GPKGTestUtils assertEqualWithValue:@"scale_factor" andValue2:[method parameterAtIndex:2].name];
    [GPKGTestUtils assertEqualDoubleWithValue:scaleFactor andValue2:[method parameterAtIndex:2].value];
    [GPKGTestUtils assertEqualWithValue:@"false_easting" andValue2:[method parameterAtIndex:3].name];
    [GPKGTestUtils assertEqualDoubleWithValue:falseEasting andValue2:[method parameterAtIndex:3].value];
    [GPKGTestUtils assertEqualWithValue:@"false_northing" andValue2:[method parameterAtIndex:4].name];
    [GPKGTestUtils assertEqualDoubleWithValue:falseNorthing andValue2:[method parameterAtIndex:4].value];
    
}

/**
 * Test Lambert Conic Conformal 2SP
 *
 * @param epsg
 *            EPSG code
 * @param name
 *            name
 * @param datum
 *            geo datum
 * @param standardParallel1
 *            standard parallel 1
 * @param standardParallel2
 *            standard parallel 2
 * @param latitudeOfOrigin
 *            latitude of origin
 * @param centralMeridian
 *            central meridian
 * @param falseEasting
 *            false easting
 * @param falseNorthing
 *            false northing
 * @param wkt
 *            well-known text
 * @param description
 *            description
 * @param srs
 *            spatial reference system
 */
-(void) testLambertConicConformal2SPWithEPSG: (int) epsg andName: (NSString *) name andDatum: (CRSGeoDatums *) datum andStandardParallel1: (double) standardParallel1 andStandardParallel2: (double) standardParallel2 andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing andWKT: (NSString *) wkt andDescription: (NSString *) description andSRS: (GPKGSpatialReferenceSystem *) srs{

    CRSOperationMethod *method = [self testLambertConicConformalWithEPSG:epsg andName:name andDatum:datum andWKT:wkt andDescription:[GPKGDgiwgWellKnownText lambertConicConformal2SPDescription] andSRS:srs];

    [GPKGTestUtils assertEqualWithValue:@"Lambert_Conformal_Conic_2SP" andValue2:method.name];
    [GPKGTestUtils assertEqualWithValue:@"standard_parallel_1" andValue2:[method parameterAtIndex:0].name];
    [GPKGTestUtils assertEqualDoubleWithValue:standardParallel1 andValue2:[method parameterAtIndex:0].value];
    [GPKGTestUtils assertEqualWithValue:@"standard_parallel_2" andValue2:[method parameterAtIndex:1].name];
    [GPKGTestUtils assertEqualDoubleWithValue:standardParallel2 andValue2:[method parameterAtIndex:1].value];
    [GPKGTestUtils assertEqualWithValue:@"latitude_of_origin" andValue2:[method parameterAtIndex:2].name];
    [GPKGTestUtils assertEqualDoubleWithValue:latitudeOfOrigin andValue2:[method parameterAtIndex:2].value];
    [GPKGTestUtils assertEqualWithValue:@"central_meridian" andValue2:[method parameterAtIndex:3].name];
    [GPKGTestUtils assertEqualDoubleWithValue:centralMeridian andValue2:[method parameterAtIndex:3].value];
    [GPKGTestUtils assertEqualWithValue:@"false_easting" andValue2:[method parameterAtIndex:4].name];
    [GPKGTestUtils assertEqualDoubleWithValue:falseEasting andValue2:[method parameterAtIndex:4].value];
    [GPKGTestUtils assertEqualWithValue:@"false_northing" andValue2:[method parameterAtIndex:5].name];
    [GPKGTestUtils assertEqualDoubleWithValue:falseNorthing andValue2:[method parameterAtIndex:5].value];

}

/**
 * Test Lambert Conic Conformal
 *
 * @param epsg
 *            EPSG code
 * @param name
 *            name
 * @param datum
 *            geo datum
 * @param wkt
 *            well-known text
 * @param description
 *            description
 * @param srs
 *            spatial reference system
 * @return operation method
 */
-(CRSOperationMethod *) testLambertConicConformalWithEPSG: (int) epsg andName: (NSString *) name andDatum: (CRSGeoDatums *) datum andWKT: (NSString *) wkt andDescription: (NSString *) description andSRS: (GPKGSpatialReferenceSystem *) srs{
    
    [GPKGTestUtils assertEqualWithValue:name andValue2:srs.srsName];
    [GPKGTestUtils assertEqualIntWithValue:epsg andValue2:[srs.srsId intValue]];
    [GPKGTestUtils assertEqualWithValue:PROJ_AUTHORITY_EPSG andValue2:srs.organization];
    [GPKGTestUtils assertEqualIntWithValue:epsg andValue2:[srs.organizationCoordsysId intValue]];
    [GPKGTestUtils assertEqualWithValue:wkt andValue2:srs.definition];
    [GPKGTestUtils assertEqualWithValue:description andValue2:srs.theDescription];
    [GPKGTestUtils assertEqualWithValue:wkt andValue2:srs.definition_12_063];

    NSLog(@"%@:%d", PROJ_AUTHORITY_EPSG, epsg);
    NSLog(@"%@", [CRSWriter writePrettyWithText:wkt]);

    PROJProjection *projection = [PROJProjectionFactory cachelessProjectionByDefinition:wkt];
    if([projection authority] != nil && [projection authority].length != 0){
        [GPKGTestUtils assertEqualWithValue:PROJ_AUTHORITY_EPSG andValue2:[projection authority]];
    }
    if([projection code] != nil && [projection code].length != 0){
        [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%d", epsg] andValue2:[projection code]];
    }
    [GPKGTestUtils assertEqualWithValue:wkt andValue2:[projection definition]];

    CRSObject *crs = [projection definitionCRS];
    [GPKGTestUtils assertEqualIntWithValue:CRS_TYPE_PROJECTED andValue2:crs.type];

    CRSProjectedCoordinateReferenceSystem *projected = (CRSProjectedCoordinateReferenceSystem *) crs;
    [GPKGTestUtils assertEqualWithValue:name andValue2:projected.name];
    CRSGeoCoordinateReferenceSystem *geo = projected.base;
    [GPKGTestUtils assertEqualWithValue:[datum code] andValue2:geo.name];
    NSObject<CRSGeoDatum> *geoDatum = [geo geoDatum];
    [GPKGTestUtils assertEqualWithValue:[datum name] andValue2:[geoDatum name]];
    CRSEllipsoids *datumEllipsoid = [datum ellipsoid];
    CRSEllipsoid *ellipsoid = [geoDatum ellipsoid];
    [GPKGTestUtils assertEqualWithValue:[datumEllipsoid name] andValue2:ellipsoid.name];
    [GPKGTestUtils assertEqualDoubleWithValue:[datumEllipsoid equatorRadius] andValue2:ellipsoid.semiMajorAxis];
    [GPKGTestUtils assertEqualDoubleWithValue:[datumEllipsoid reciprocalFlattening] andValue2:ellipsoid.inverseFlattening andDelta:0.000001];
    CRSPrimeMeridian *primeMeridian = [geoDatum primeMeridian];
    [GPKGTestUtils assertEqualWithValue:[[CRSPrimeMeridians fromType:CRS_PM_GREENWICH] name] andValue2:primeMeridian.name];
    [GPKGTestUtils assertEqualDoubleWithValue:[[CRSPrimeMeridians fromType:CRS_PM_GREENWICH] offsetFromGreenwichDegrees] andValue2:primeMeridian.longitude];
    CRSOperationMethod *operationMethod = projected.mapProjection.method;
    [GPKGTestUtils assertEqualWithValue:PROJ_AUTHORITY_EPSG andValue2:[projected identifierAtIndex:0].name];
    [GPKGTestUtils assertEqualWithValue:[NSString stringWithFormat:@"%d", epsg] andValue2:[projected identifierAtIndex:0].uniqueIdentifier];

    return operationMethod;
}

@end
