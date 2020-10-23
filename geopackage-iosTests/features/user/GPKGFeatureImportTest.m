//
//  GPKGFeatureImportTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/27/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGFeatureImportTest.h"
#import "GPKGFeatureUtils.h"

@implementation GPKGFeatureImportTest

-(void) testCreate{
    [GPKGFeatureUtils testCreateWithGeoPackage: self.geoPackage];
}

-(void) testDelete{
    [GPKGFeatureUtils testDeleteWithGeoPackage: self.geoPackage];
}

-(void) testPkModifiableAndValueValidation{
    [GPKGFeatureUtils testPkModifiableAndValueValidationWithGeoPackage:self.geoPackage];
}

@end
