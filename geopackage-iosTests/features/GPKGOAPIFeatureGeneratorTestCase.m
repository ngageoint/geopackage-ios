//
//  GPKGOAPIFeatureGeneratorTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGOAPIFeatureGeneratorTestCase.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGOAPIFeatureGenerator.h"
#import "GPKGTestUtils.h"
#import "GPKGFeatureIndexManager.h"

@implementation GPKGOAPIFeatureGeneratorTestCase

/**
 * Test opendata_1h
 *
 * @throws SQLException upon failure
 */
-(void) testOpenData1h{
    
    [self testServer:@"http://beta.fmi.fi/data/3/wfs/sofp" withCollection:@"opendata_1h" andLimit:[NSNumber numberWithInt:30] andTotalLimit:[NSNumber numberWithInt:15] andBoundingBox:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:20.0 andMinLatitudeDouble:60.0 andMaxLongitudeDouble:22.0 andMaxLatitudeDouble:62.0] andTime:@"20190519T140000" andPeriod:@"20190619T140000"];
    
}

/**
 * Test lakes
 *
 * @throws SQLException upon failure
 */
-(void) testLakes{
    
    [self testServer:@"https://demo.pygeoapi.io/master" withCollection:@"lakes" andLimit:[NSNumber numberWithInt:30] andTotalLimit:[NSNumber numberWithInt:25] andBoundingBox:nil andTime:nil andPeriod:nil];
    
}

/**
 * Test flurstueck
 *
 * @throws SQLException upon failure
 */
-(void) testFlurstueck{
    
        [self testServer:@"https://www.ldproxy.nrw.de/kataster" withCollection:@"flurstueck" andLimit:[NSNumber numberWithInt:15] andTotalLimit:[NSNumber numberWithInt:1000] andBoundingBox:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:8.683250427246094 andMinLatitudeDouble:51.47780990600586 andMaxLongitudeDouble:9.093862533569336 andMaxLatitudeDouble:51.520809173583984] andTime:nil andPeriod:nil];
    
}

/**
 * Test rakennus
 *
 * @throws SQLException upon failure
 */
-(void) testRakennus{
    
    [self testServer:@"https://beta-paikkatieto.maanmittauslaitos.fi/maastotiedot/wfs3/v1" withCollection:@"rakennus" andLimit:[NSNumber numberWithInt:1000] andTotalLimit:[NSNumber numberWithInt:10000] andBoundingBox:nil andTime:nil andPeriod:nil];
    
}

/**
 * Test MAGE
 *
 * @throws SQLException upon failure
 */
-(void) testMAGE{
    
    [self testServer:@"https://mageogc.geointservices.io/api/ogc/features" withCollection:@"event:1:observations" andName:@"mage" andLimit:nil andTotalLimit:nil andBoundingBox:nil andTime:nil andPeriod:nil];
    
}

/**
 * Test a WFS server and create a GeoPackage
 *
 * @param server
 *            server url
 * @param collection
 *            collection name
 * @param limit
 *            request limit
 * @param totalLimit
 *            total limit
 * @param boundingBox
 *            bounding box
 * @param time
 *            time
 * @param period
 *            period or end time
 */
-(void) testServer: (NSString *) server withCollection: (NSString *) collection andLimit: (NSNumber *) limit andTotalLimit: (NSNumber *) totalLimit andBoundingBox: (GPKGBoundingBox *) boundingBox andTime: (NSString *) time andPeriod: (NSString *) period{
    [self testServer:server withCollection:collection andName:collection andLimit:limit andTotalLimit:totalLimit andBoundingBox:boundingBox andTime:time andPeriod:period];
}

/**
 * Test a WFS server and create a GeoPackage
 *
 * @param server
 *            server url
 * @param collection
 *            collection name
 * @param name
 *            geoPackage and table name
 * @param limit
 *            request limit
 * @param totalLimit
 *            total limit
 * @param boundingBox
 *            bounding box
 * @param time
 *            time
 * @param period
 *            period or end time
 */
-(void) testServer: (NSString *) server withCollection: (NSString *) collection andName: (NSString *) name andLimit: (NSNumber *) limit andTotalLimit: (NSNumber *) totalLimit andBoundingBox: (GPKGBoundingBox *) boundingBox andTime: (NSString *) time andPeriod: (NSString *) period{
    
    GPKGGeoPackageManager *geoPackageManager = [GPKGGeoPackageFactory manager];
    
    [geoPackageManager delete:collection];
    
    [geoPackageManager create:collection];
    
    GPKGGeoPackage *geoPackage = [geoPackageManager open:collection];
    
    GPKGOAPIFeatureGenerator *generator = [[GPKGOAPIFeatureGenerator alloc] initWithGeoPackage:geoPackage andTable:name andServer:server andId:collection];
    [generator setLimit:limit];
    [generator setTotalLimit:totalLimit];
    [generator setBoundingBox:boundingBox];
    [generator setTime:time];
    [generator setPeriod:period];
    [generator setDownloadAttempts:3];
    
    int count = [generator generateFeatures];
    if(totalLimit != nil){
        [GPKGTestUtils assertEqualIntWithValue:[totalLimit intValue] andValue2:count];
    }
    
    GPKGFeatureDao *featureDao = [generator featureDao];
    if (totalLimit != nil) {
        [GPKGTestUtils assertEqualIntWithValue:[totalLimit intValue] andValue2:[featureDao count]];
    }
    
    GPKGFeatureIndexManager *indexer = [[GPKGFeatureIndexManager alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
    [indexer setIndexLocation:GPKG_FIT_RTREE];
    [indexer index];
    [indexer close];
    
    GPKGBoundingBox *dataBounds = [geoPackage boundingBoxOfTable:featureDao.tableName];
    GPKGContents *contents = [featureDao contents];
    [contents setBoundingBox:dataBounds];
    [[geoPackage contentsDao] update:contents];
    
    [geoPackage close];
    
}

@end
