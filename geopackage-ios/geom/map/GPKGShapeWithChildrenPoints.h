//
//  GPKGShapeWithChildrenPoints.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGShapeWithChildrenPoints_h
#define geopackage_ios_GPKGShapeWithChildrenPoints_h

#import "GPKGShapePoints.h"

/**
 *  Shape with children protocol defining the interface for shapes with children points
 */
@protocol GPKGShapeWithChildrenPoints <NSObject>

/**
 *  Create a child shape points
 *
 *  @return shape points
 */
-(NSObject<GPKGShapePoints> *) createChild;

@end

#endif
