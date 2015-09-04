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

/**
 *  Projection transformation between a from and to projection
 */
@interface GPKGProjectionTransform : NSObject

/**
 *  From projection
 */
@property (nonatomic, strong) GPKGProjection *fromProjection;

/**
 *  To projection
 */
@property (nonatomic, strong) GPKGProjection *toProjection;

/**
 *  Initialize
 *
 *  @param fromProjection from projection
 *  @param toProjection   to projection
 *
 *  @return new projection transform
 */
-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToProjection: (GPKGProjection *) toProjection;

/**
 *  Initialize
 *
 *  @param fromEpsg from epsg
 *  @param toEpsg   to epsg
 *
 *  @return new projection transform
 */
-(instancetype) initWithFromEpsg: (int) fromEpsg andToEpsg: (int) toEpsg;

/**
 *  Initialize
 *
 *  @param fromProjection from projection
 *  @param toEpsg         to epsg
 *
 *  @return new projection transform
 */
-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToEpsg: (int) toEpsg;

/**
 *  Initialize
 *
 *  @param fromEpsg     from epsg
 *  @param toProjection to projeciton
 *
 *  @return new projection transform
 */
-(instancetype) initWithFromEpsg: (int) fromEpsg andToProjection: (GPKGProjection *) toProjection;

/**
 *  Transform a point
 *
 *  @param from point to transform
 *
 *  @return transformed point
 */
-(WKBPoint *) transformWithPoint: (WKBPoint *) from;

/**
 *  Transform a bounding box
 *
 *  @param boundingBox bounding box to transform
 *
 *  @return transformed bounding box
 */
-(GPKGBoundingBox *) transformWithBoundingBox: (GPKGBoundingBox *) boundingBox;

/**
 *  Transform a x and y coordinate
 *
 *  @param x x coordinate
 *  @param y y coordinate
 *
 *  @return array containing x and y coordinate
 */
-(NSArray *) transformWithX: (double) x andY: (double) y;

@end
