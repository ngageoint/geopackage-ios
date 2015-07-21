//
//  GPKGProjection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "proj_api.h"

@interface GPKGProjection : NSObject

@property (nonatomic, strong) NSNumber *epsg;
@property (nonatomic) projPJ crs;
@property (nonatomic, strong) NSDecimalNumber *toMeters;
@property (nonatomic) BOOL isLatLong;

-(instancetype) initWithEpsg: (NSNumber *) epsg andCrs: (projPJ) crs andToMeters: (NSDecimalNumber *) toMeters;

-(double) toMeters: (double) value;

@end
