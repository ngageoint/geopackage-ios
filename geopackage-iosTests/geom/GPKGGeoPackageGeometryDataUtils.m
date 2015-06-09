//
//  GPKGGeoPackageGeometryDataUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageGeometryDataUtils.h"
#import "GPKGGeometryColumnsDao.h"

@implementation GPKGGeoPackageGeometryDataUtils

+(void) testReadWriteBytesWithTestCase: (GPKGBaseTestCase *) testCase andGeoPackage: (GPKGGeoPackage *) geoPackage{
    
    GPKGGeometryColumnsDao * geometryColumnsDao = [geoPackage getGeometryColumnsDao];
    
    if([geometryColumnsDao tableExists]){
        GPKGResultSet * results = [geometryColumnsDao queryForAll];
        
        while([results moveToNext]){
            
            GPKGGeometryColumns * geometryColumns = (GPKGGeometryColumns *)[geometryColumnsDao getObject:results];
            
            GPKGFeatureDao * dao = [geoPackage getFeatureDaoWithGeometryColumns:geometryColumns];
            [testCase assertNotNil:dao];

            GPKGResultSet * featureResults = [dao queryForAll];
            
            while([featureResults moveToNext]){
                
                GPKGFeatureRow * featureRow = [dao getFeatureRow:featureResults];
                GPKGGeometryData * geometryData = [featureRow getGeometry];
                
                if(geometryData != nil){
                    
                    NSData * geometryDataToBytes = geometryData.bytes;
                    
                    // TODO
                }
            }
            
            [featureResults close];
        }
        
        [results close];
    }
}

@end
