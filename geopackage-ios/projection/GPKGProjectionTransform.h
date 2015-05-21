//
//  GPKGProjectionTransform.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGProjection.h"
#import "GPKGBoundingBox.h"

@interface GPKGProjectionTransform : NSObject

@property (nonatomic, strong) GPKGProjection *fromProjection;
@property (nonatomic, strong) GPKGProjection *toProjection;

-(instancetype) initWithFrom: (GPKGProjection *) fromProjection andTo: (GPKGProjection *) toProjection;

// TODO
//-(WKBPoint *) transformWithPoint: (WKBPoint *) from;

-(GPKGBoundingBox *) transformWithBoundingBox: (GPKGBoundingBox *) boundingBox;

-(NSArray *) transformWithX: (double) x andY: (double) y;

@end
