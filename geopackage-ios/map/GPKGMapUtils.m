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
    
    float viewWidth = mapViewSize.width;
    float viewHeight = mapViewSize.height;
    
    double meters = 0;
    
    if(viewWidth > 0 && viewHeight > 0) {
    
        double widthMeters = size.width / viewWidth;
        double heightMeters = size.height / viewHeight;
    
        meters = MIN(widthMeters, heightMeters);
    }
    
    return meters;
}

+(GPKGBoundingBox *) boundingBoxOfMapView: (MKMapView *) mapView{
    
    CGPoint topRightPoint = CGPointMake(mapView.bounds.origin.x + mapView.bounds.size.width, mapView.bounds.origin.y);
    CGPoint bottomLeftPoint = CGPointMake((mapView.bounds.origin.x), (mapView.bounds.origin.y + mapView.bounds.size.height));
    
    CLLocationCoordinate2D topRight = [mapView convertPoint:topRightPoint toCoordinateFromView:mapView];
    CLLocationCoordinate2D bottomLeft = [mapView convertPoint:bottomLeftPoint toCoordinateFromView:mapView];
    
    double minLatitude = bottomLeft.latitude;
    double maxLatitude = topRight.latitude;
    
    double minLongitude = bottomLeft.longitude;
    double maxLongitude = topRight.longitude;
    if(maxLongitude < minLongitude){
        maxLongitude += (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
    }
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMaxLongitudeDouble:maxLongitude andMinLatitudeDouble:minLatitude andMaxLatitudeDouble:maxLatitude];
    
    return boundingBox;
}

+(GPKGLocationBoundingBox *) buildClickLocationBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    
    // Get the screen width and height a click occurs from a feature
    CGSize mapViewSize = mapView.frame.size;
    int width = (int) roundf(mapViewSize.width * screenClickPercentage);
    int height = (int) roundf(mapViewSize.height * screenClickPercentage);
    
    // Get the screen click locations in each width or height direction
    CGPoint left = CGPointMake(point.x - width, point.y);
    CGPoint up = CGPointMake(point.x, point.y - height);
    CGPoint right = CGPointMake(point.x + width, point.y);
    CGPoint down = CGPointMake(point.x, point.y + height);
    
    // Get the coordinates of the bounding box points
    CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:left toCoordinateFromView:mapView];
    CLLocationCoordinate2D upCoordinate = [mapView convertPoint:up toCoordinateFromView:mapView];
    CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:right toCoordinateFromView:mapView];
    CLLocationCoordinate2D downCoordinate = [mapView convertPoint:down toCoordinateFromView:mapView];
    
    GPKGLocationBoundingBox *locationBoundingBox = [[GPKGLocationBoundingBox alloc] initWithLeft:leftCoordinate
                                                                                           andUp:upCoordinate
                                                                                        andRight:rightCoordinate
                                                                                         andDown:downCoordinate];

    return locationBoundingBox;
}

+(GPKGBoundingBox *) buildClickBoundingBoxWithMapPoint: (GPKGMapPoint *) mapPoint andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    return [self buildClickBoundingBoxWithLocationCoordinate:mapPoint.coordinate andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(GPKGBoundingBox *) buildClickBoundingBoxWithMKMapPoint: (MKMapPoint) mapPoint andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CLLocationCoordinate2D locationCoordinate = MKCoordinateForMapPoint(mapPoint);
    return [self buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(GPKGBoundingBox *) buildClickBoundingBoxWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    return [self buildClickBoundingBoxWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CGPoint point = [mapView convertCoordinate:location toPointToView:mapView];
    return [self buildClickBoundingBoxWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(GPKGBoundingBox *) buildClickBoundingBoxWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    
    GPKGLocationBoundingBox *locationBoundingBox = [self buildClickLocationBoundingBoxWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
    
    GPKGBoundingBox *boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:locationBoundingBox.leftCoordinate.longitude
                                                                 andMaxLongitudeDouble:locationBoundingBox.rightCoordinate.longitude
                                                                  andMinLatitudeDouble:locationBoundingBox.downCoordinate.latitude
                                                                  andMaxLatitudeDouble:locationBoundingBox.upCoordinate.latitude];
    
    return boundingBox;
}

+(GPKGBoundingBox *) buildClickBoundingBoxWithLocationCoordinate: (CLLocationCoordinate2D) location andMapBounds: (GPKGBoundingBox *) mapBounds andScreenPercentage: (float) screenClickPercentage{
    
    // Get the screen width and height a click occurs from a feature
    struct GPKGBoundingBoxSize size = [mapBounds sizeInMeters];
    double width = size.width * screenClickPercentage;
    double height = size.height * screenClickPercentage;
    
    CLLocationCoordinate2D leftCoordinate = [GPKGTileBoundingBoxUtils locationWithBearing:270 andDistance:width fromLocation:location];
    CLLocationCoordinate2D upCoordinate = [GPKGTileBoundingBoxUtils locationWithBearing:0 andDistance:height fromLocation:location];
    CLLocationCoordinate2D rightCoordinate = [GPKGTileBoundingBoxUtils locationWithBearing:90 andDistance:width fromLocation:location];
    CLLocationCoordinate2D downCoordinate = [GPKGTileBoundingBoxUtils locationWithBearing:180 andDistance:height fromLocation:location];
    
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:leftCoordinate.longitude
                                                                  andMaxLongitudeDouble:rightCoordinate.longitude
                                                                   andMinLatitudeDouble:downCoordinate.latitude
                                                                   andMaxLatitudeDouble:upCoordinate.latitude];
    
    return boundingBox;
}

+(double) getToleranceDistanceWithPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    
    GPKGLocationBoundingBox *boundingBox = [self buildClickLocationBoundingBoxWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
    
    double longitudeDistance = [GPKGTileBoundingBoxUtils distanceBetweenLocation:boundingBox.leftCoordinate andLocation:boundingBox.rightCoordinate];
    double latitudeDistance = [GPKGTileBoundingBoxUtils distanceBetweenLocation:boundingBox.downCoordinate andLocation:boundingBox.upCoordinate];
    
    double distance = MAX(longitudeDistance, latitudeDistance);
    
    return distance;
}

@end
