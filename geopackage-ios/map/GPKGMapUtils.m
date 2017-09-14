//
//  GPKGMapUtils.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGMapUtils.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGProjectionConstants.h"

@implementation GPKGMapUtils

+(double) currentZoomWithMapView: (MKMapView *) mapView{

    int maxZoom = [[GPKGProperties getNumberValueOfProperty:GPKG_PROP_MAX_ZOOM_LEVEL] intValue];
    CLLocationDegrees longitudeDelta = mapView.region.span.longitudeDelta;
    CGFloat width = mapView.bounds.size.width;
    double scale = longitudeDelta * PROJ_MERCATOR_RADIUS * M_PI / (PROJ_WGS84_HALF_WORLD_LON_WIDTH * width);
    double zoom = maxZoom - round(log2(scale));
    if (maxZoom < 0){
        zoom = 0;
    }

    return zoom;
}

+(GPKGBoundingBox *) boundingBoxOfMapView: (MKMapView *) mapView{

    CLLocationCoordinate2D center = mapView.region.center;
    MKCoordinateSpan span = mapView.region.span;
    double latitudeFromCenter = span.latitudeDelta * .5;
    double longitudeFromCenter = span.longitudeDelta * .5;
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:center.longitude - longitudeFromCenter andMaxLongitudeDouble:center.longitude + longitudeFromCenter andMinLatitudeDouble:center.latitude - latitudeFromCenter andMaxLatitudeDouble:center.latitude + latitudeFromCenter];
    
    return boundingBox;
}

@end
