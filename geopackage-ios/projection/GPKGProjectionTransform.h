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
#import "WKBPoint.h"

@interface GPKGProjectionTransform : NSObject

@property (nonatomic, strong) GPKGProjection *fromProjection;
@property (nonatomic, strong) GPKGProjection *toProjection;

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToProjection: (GPKGProjection *) toProjection;

-(instancetype) initWithFromEpsg: (int) fromEpsg andToEpsg: (int) toEpsg;

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToEpsg: (int) toEpsg;

-(instancetype) initWithFromEpsg: (int) fromEpsg andToProjection: (GPKGProjection *) toProjection;

-(WKBPoint *) transformWithPoint: (WKBPoint *) from;

-(GPKGBoundingBox *) transformWithBoundingBox: (GPKGBoundingBox *) boundingBox;

-(NSArray *) transformWithX: (double) x andY: (double) y;

@end
