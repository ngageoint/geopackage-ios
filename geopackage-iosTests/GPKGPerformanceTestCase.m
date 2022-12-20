//
//  GPKGPerformanceTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGPerformanceTestCase.h"
#import "GPKGGeoPackageFactory.h"
#import "PROJProjectionConstants.h"
#import "GPKGTestUtils.h"

@implementation GPKGPerformanceTestCase

static NSString *GEOPACKAGE_NAME = @"performance";
static NSString *TABLE_NAME = @"features";
static NSString *COLUMN_NAME = @"geom";

/**
 * Test performance without transactions
 */
-(void) testPerformance{
    [self testPerformanceWithCreate:1000 andLog:100];
}

/**
 * Test performance when transaction commits
 */
-(void) testPerformanceTransactions{
    [self testPerformanceWithCreate:10000 andLog:1000 andCommit:1000];
}

/**
 * Test performance
 *
 * @param createCount rows to create
 * @param logChunk    log frequency
 */
-(void) testPerformanceWithCreate: (int) createCount andLog: (int) logChunk{
    [self testPerformanceWithCreate:createCount andLog:logChunk andCommit:-1];
}

/**
 * Test performance
 *
 * @param createCount rows to create
 * @param logChunk    log frequency
 * @param commitChunk commit chunk for transactions
 */
-(void) testPerformanceWithCreate: (int) createCount andLog: (int) logChunk andCommit: (int) commitChunk{
    
    BOOL transactions = commitChunk > 0;
    
    GPKGGeoPackageManager *manager = [GPKGGeoPackageFactory manager];
    
    [manager delete:GEOPACKAGE_NAME];
    
    NSLog(@"GeoPackage: %@", GEOPACKAGE_NAME);
    NSLog(@"Table Name: %@", TABLE_NAME);
    NSLog(@"Column Name: %@", COLUMN_NAME);
    NSLog(@"Features: %d", createCount);
    NSLog(@"Transactions: %d", transactions);
    if (transactions) {
        NSLog(@"Commit Chunk: %d", commitChunk);
    }
    if (logChunk > 0) {
        NSLog(@"Log Chunk: %d", logChunk);
    }
    
    [manager create:GEOPACKAGE_NAME];
    
    GPKGGeoPackage *geoPackage = [manager open:GEOPACKAGE_NAME];
    
    SFGeometry *geometry = [self createGeometry];
    
    GPKGSpatialReferenceSystem *srs = [[geoPackage spatialReferenceSystemDao] srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    
    GPKGGeometryColumns *geometryColumns = [[GPKGGeometryColumns alloc] init];
    [geometryColumns setTableName:TABLE_NAME];
    [geometryColumns setColumnName:COLUMN_NAME];
    [geometryColumns setGeometryType:geometry.geometryType];
    [geometryColumns setZ:[NSNumber numberWithInt:0]];
    [geometryColumns setM:[NSNumber numberWithInt:0]];
    [geometryColumns setSrs:srs];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithGeometry:geometry];
    
    [geoPackage createFeatureTableWithMetadata:[GPKGFeatureTableMetadata createWithGeometryColumns:geometryColumns andBoundingBox:boundingBox]];
    
    GPKGGeometryData *geometryData = [GPKGGeometryData createWithSrsId:srs.srsId andGeometry:geometry];
    
    GPKGFeatureDao *dao = [geoPackage featureDaoWithGeometryColumns:geometryColumns];
    
    if (transactions) {
        [dao beginTransaction];
    }
    
    @try {
        
        NSDate *startTime = [NSDate date];
        NSDate *logTime = [NSDate date];
        
        for (int count = 1; count <= createCount; count++) {
            
            GPKGFeatureRow *newRow = [dao newRow];
            [newRow setGeometry:geometryData];
            
            [dao create:newRow];
            
            if (transactions && count % commitChunk == 0) {
                [dao commitTransaction];
                [dao beginTransaction];
            }
            
            if (logChunk > 0 && count % logChunk == 0) {
                NSDate *time = [NSDate date];
                NSLog(@"Total Count: %d", count);
                NSTimeInterval duration = [time timeIntervalSinceDate:logTime];
                double durationMs = duration * 1000;
                NSLog(@"Chunk Time: %f ms", durationMs);
                NSLog(@"Chunk Average: %f ms", durationMs / logChunk);
                NSTimeInterval totalDuration = [time timeIntervalSinceDate:startTime];
                double totalDurationMs = totalDuration * 1000;
                NSLog(@"Total Time: %f ms", totalDurationMs);
                NSLog(@"Feature Average: %f ms", totalDurationMs / count);
                logTime = time;
            }
            
        }
        
        if (transactions) {
            [dao commitTransaction];
        }
        
    } @catch (NSException *exception) {
        if (transactions) {
            [dao rollbackTransaction];
        }
        [exception raise];
    }
    
    [geoPackage close];
    
    geoPackage = [manager open:GEOPACKAGE_NAME];
    dao = [geoPackage featureDaoWithTableName:TABLE_NAME];
    int finalCount = [dao count];
    NSLog(@"Final Count: %d", finalCount);
    [geoPackage close];
    
    [GPKGTestUtils assertEqualIntWithValue:createCount andValue2:finalCount];
}

-(SFGeometry *) createGeometry{
    
    SFPolygon *polygon = [SFPolygon polygon];
    SFLineString *ring = [SFLineString lineString];
    [ring addPoint:[SFPoint pointWithXValue:-104.802246 andYValue:39.720343]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802246 andYValue:39.719753]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802183 andYValue:39.719754]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802184 andYValue:39.719719]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802138 andYValue:39.719694]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802097 andYValue:39.719691]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802096 andYValue:39.719648]];
    [ring addPoint:[SFPoint pointWithXValue:-104.801646 andYValue:39.719648]];
    [ring addPoint:[SFPoint pointWithXValue:-104.801644 andYValue:39.719722]];
    [ring addPoint:[SFPoint pointWithXValue:-104.801550 andYValue:39.719723]];
    [ring addPoint:[SFPoint pointWithXValue:-104.801549 andYValue:39.720207]];
    [ring addPoint:[SFPoint pointWithXValue:-104.801648 andYValue:39.720207]];
    [ring addPoint:[SFPoint pointWithXValue:-104.801648 andYValue:39.720341]];
    [ring addPoint:[SFPoint pointWithXValue:-104.802246 andYValue:39.720343]];
    [polygon addRing:ring];
    
    return polygon;
}

@end
