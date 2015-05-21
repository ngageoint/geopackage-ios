//
//  GPKGProjectionFactory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGProjection.h"

@interface GPKGProjectionFactory : NSObject

+(GPKGProjection *) getProjection: (NSNumber *) epsg;

@end
