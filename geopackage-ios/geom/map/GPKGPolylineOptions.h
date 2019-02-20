//
//  GPKGPolylineOptions.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <MapKit/MapKit.h>

/**
 * Polyline Style Options
 */
@interface GPKGPolylineOptions : NSObject

/**
 * The stroke color to use for the path
 */
@property (nonatomic, strong) UIColor *strokeColor;

/**
 * The stroke width to use for the path
 */
@property (nonatomic) double lineWidth;

@end

