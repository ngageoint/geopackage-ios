//
//  GPKGProjection.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGProjection : NSObject

@property (nonatomic, strong) NSNumber *epsg;

-(instancetype) initWithEpsg: (NSNumber *) epsg;

-(double) toMeters: (double) value;

@end
