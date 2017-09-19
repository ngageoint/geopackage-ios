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
    
    CGPoint topRightPoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
    CGPoint bottomLeftPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
    
    CLLocationCoordinate2D topRight = [mapView convertPoint:topRightPoint toCoordinateFromView:mapView];
    CLLocationCoordinate2D bottomLeft = [mapView convertPoint:bottomLeftPoint toCoordinateFromView:mapView];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:bottomLeft.longitude andMaxLongitudeDouble:topRight.longitude andMinLatitudeDouble:bottomLeft.latitude andMaxLatitudeDouble:topRight.latitude];
    
    return boundingBox;
}

@end
