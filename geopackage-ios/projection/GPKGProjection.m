//
//  GPKGProjection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjection.h"

@implementation GPKGProjection

-(instancetype) initWithEpsg: (NSNumber *) epsg andCrs: (projPJ) crs andToMeters: (NSDecimalNumber *) toMeters{
    self = [super init];
    if(self != nil){
        self.epsg = epsg;
        self.crs = crs;
        self.toMeters = toMeters;
        self.isLatLong = pj_is_latlong(crs);
    }
    return self;
}

-(double) toMeters: (double) value{
    if(self.toMeters != nil){
        NSDecimalNumber * valueDecimalNumber = [[NSDecimalNumber alloc] initWithDouble:value];
        NSDecimalNumber * metersValue = [self.toMeters decimalNumberByMultiplyingBy:valueDecimalNumber];
        value = [metersValue doubleValue];
    }
    return value;
}

@end
