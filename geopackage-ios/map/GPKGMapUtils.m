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
#import "GPKGTileBoundingBoxUtils.h"

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

+(double) toleranceDistanceInMapView: (MKMapView *) mapView{
    
    CGSize mapViewSize = mapView.frame.size;
    
    GPKGBoundingBox * boundingBox = [self boundingBoxOfMapView:mapView];
    struct GPKGBoundingBoxSize size = [boundingBox sizeInMeters];
    
    double widthMeters = size.width / mapViewSize.width;
    double heightMeters = size.height / mapViewSize.height;
    
    double meters = MIN(widthMeters, heightMeters);
    
    return meters;
}

+(GPKGBoundingBox *) boundingBoxOfMapView: (MKMapView *) mapView{

    CLLocationCoordinate2D center = mapView.region.center;
    MKCoordinateSpan span = mapView.region.span;
    double latitudeFromCenter = span.latitudeDelta * .5;
    double longitudeFromCenter = span.longitudeDelta * .5;
    double minLongitude = center.longitude - longitudeFromCenter;
    double maxLongitude = center.longitude + longitudeFromCenter;
    double minLatitude = MAX(center.latitude - latitudeFromCenter, -90.0);
    double maxLatitude = MIN(center.latitude + latitudeFromCenter, 90.0);
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
    
    return boundingBox;
}

@end
