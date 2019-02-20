//
//  GPKGPolyline.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGPolylineOptions.h"

/**
 * MapKit Polyline with Style Options
 */
@interface GPKGPolyline : MKPolyline

/**
 * Polyline Style Options
 */
@property (nonatomic, strong) GPKGPolylineOptions *options;

@end

