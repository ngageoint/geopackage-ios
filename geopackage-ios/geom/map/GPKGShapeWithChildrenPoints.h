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

@protocol GPKGShapeWithChildrenPoints <NSObject>

-(NSObject<GPKGShapePoints> *) createChild;

@end

#endif
