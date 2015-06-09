//
//  GPKGGeoPackageTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/9/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGGeoPackageTestCase.h"

@implementation GPKGGeoPackageTestCase

-(GPKGGeoPackage *) getGeoPackage{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)setUp {
    [super setUp];
    
    self.geoPackage = [self getGeoPackage];
}
    
- (void)tearDown {
    [super tearDown];
}

@end
