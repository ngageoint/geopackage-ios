//
//  GPKGAttributesCreateTest.m
//  geopackage-ios
//
//  Created by Brian Osborn on 12/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesCreateTest.h"
#import "GPKGAttributesUtils.h"

@implementation GPKGAttributesCreateTest

-(void) testRead{
    [GPKGAttributesUtils testReadWithGeoPackage: self.geoPackage];
}

-(void) testUpdate{
    [GPKGAttributesUtils testUpdateWithGeoPackage: self.geoPackage];
}

-(void) testUpdateAddColumns{
    [GPKGAttributesUtils testUpdateAddColumnsWithGeoPackage: self.geoPackage];
}

-(void) testCreate{
    [GPKGAttributesUtils testCreateWithGeoPackage: self.geoPackage];
}

-(void) testDelete{
    [GPKGAttributesUtils testDeleteWithGeoPackage: self.geoPackage];
}

@end
