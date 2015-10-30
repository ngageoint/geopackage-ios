//
//  GPKGFeatureTableIndexUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/19/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTableIndexUtils.h"
#import "GPKGFeatureTableIndex.h"
#import "GPKGTestUtils.h"
#import "GPKGTestGeoPackageProgress.h"

@implementation GPKGFeatureTableIndexUtils

+(void) testIndexerWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    // Test indexing each feature table
    NSArray * featureTables = [geoPackage getFeatureTables];
    for(NSString * featureTable in featureTables){
        
        GPKGFeatureDao * featureDao = [geoPackage getFeatureDaoWithTableName:featureTable];
        GPKGFeatureTableIndex * featureTableIndex = [[GPKGFeatureTableIndex alloc] initWithGeoPackage:geoPackage andFeatureDao:featureDao];
        
        // Determine how many features have geometry envelopes or geometries
        int expectedCount = 0;
        GPKGFeatureRow * testFeatureRow = nil;
        GPKGResultSet * featureResultSet = [featureDao queryForAll];
        while([featureResultSet moveToNext]){
            GPKGFeatureRow * featureRow = [featureDao getFeatureRow:featureResultSet];
            GPKGGeometryData * geometryData = [featureRow getGeometry];
            if(geometryData != nil
               && (geometryData.envelope != nil || geometryData.geometry != nil)){
                expectedCount++;
                // Randomly choose a feature row with Geometry for testing
                // queries later
                if(testFeatureRow == nil){
                    testFeatureRow = featureRow;
                }else if((rand() / RAND_MAX) < (1.0 / featureResultSet.count)){
                    testFeatureRow = featureRow;
                }
            }
        }
        [featureResultSet close];
        
        [GPKGTestUtils assertFalse:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertNil:[featureTableIndex getLastIndexed]];
        NSDate * currentDate = [NSDate date];
        
        [NSThread sleepForTimeInterval:1];
        
        // Test indexing
        GPKGTestGeoPackageProgress * progress = [[GPKGTestGeoPackageProgress alloc] init];
        [featureTableIndex setProgress:progress];
        int indexCount = [featureTableIndex index];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:indexCount];
        [GPKGTestUtils assertEqualIntWithValue:featureDao.count andValue2:progress.progress];
        [GPKGTestUtils assertNotNil:[featureTableIndex getLastIndexed]];
        NSDate * lastIndexed = [featureTableIndex getLastIndexed];
        NSComparisonResult result = [lastIndexed compare:currentDate];
        [GPKGTestUtils assertTrue:([lastIndexed compare:currentDate] == NSOrderedDescending)];
        
        [GPKGTestUtils assertTrue:[featureTableIndex isIndexed]];
        [GPKGTestUtils assertEqualIntWithValue:expectedCount andValue2:featureTableIndex.count];
        
        // TODO
    }
}

@end
