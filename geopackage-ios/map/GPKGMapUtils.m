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

+(CGPathRef) complementaryWorldPathOfPolyline: (MKPolyline *) polyline{
    return [self complementaryWorldPathOfMultiPoint:polyline];
}

+(CGPathRef) complementaryWorldPathOfPolygon: (MKPolygon *) polygon{
    return [self complementaryWorldPathOfMultiPoint:polygon];
}

+(CGPathRef) complementaryWorldPathOfMultiPoint: (MKMultiPoint *) multiPoint{
    return [self complementaryWorldPathOfPoints:[multiPoint points] andPointCount:multiPoint.pointCount];
}

+(CGPathRef) complementaryWorldPathOfPoints: (MKMapPoint *) points andPointCount: (NSUInteger) pointCount{
    
    CGMutablePathRef path = nil;
    
    // Determine if the shape is drawn over the -180 / 180 longitude boundary and the direction
    int worldOverlap = 0;
    for(int i = 0; i < pointCount; i++){
        MKMapPoint mapPoint = points[i];
        if(mapPoint.x < 0){
            worldOverlap = -1;
            break;
        }else if(mapPoint.x > MKMapSizeWorld.width){
            worldOverlap = 1;
            break;
        }
    }
    
    // Shape crosses the -180 / 180 longitude boundary
    if(worldOverlap != 0){
        
        // Build the complementary points in the opposite world width direction
        MKMapPoint complementaryPoints[pointCount];
        for(int i = 0; i < pointCount; i++){
            MKMapPoint mapPoint = points[i];
            double x = mapPoint.x;
            if(worldOverlap < 0){
                x += MKMapSizeWorld.width;
            }else{
                x -= MKMapSizeWorld.width;
            }
            MKMapPoint complementaryPoint = MKMapPointMake(x, mapPoint.y);
            complementaryPoints[i] = complementaryPoint;
        }
        
        // Build the path
        path = CGPathCreateMutable();
        for(int i = 0; i < pointCount; i++){
            MKMapPoint complementaryPoint = complementaryPoints[i];
            if(i == 0){
                CGPathMoveToPoint(path, NULL, complementaryPoint.x, complementaryPoint.y);
            }else{
                CGPathAddLineToPoint(path, NULL, complementaryPoint.x, complementaryPoint.y);
            }
        }
        
    }
    
    return path;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onShape: (GPKGMapShape *) mapShape withMapView: (MKMapView *) mapView andTolerance: (double) tolerance{
    
    BOOL onShape = false;
    
    switch(mapShape.shapeType){
            
        case GPKG_MST_POINT:
            onShape = [self isLocation:location nearMapPoint:(GPKGMapPoint *) mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_POLYLINE:
            onShape = [self isLocation:location onPolyline:(MKPolyline *) mapShape.shape withMapView:mapView andTolerance:tolerance];
            break;
        case GPKG_MST_POLYGON:
            onShape = [self isLocation:location onPolygon:(MKPolygon *) mapShape.shape withMapView:mapView];
            break;
        case GPKG_MST_MULTI_POINT:
            onShape = [self isLocation:location nearMultiPoint:(GPKGMultiPoint *) mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_MULTI_POLYLINE:
            onShape = [self isLocation:location onMultiPolyline:(GPKGMultiPolyline *)mapShape.shape withMapView:mapView withTolerance:tolerance];
            break;
        case GPKG_MST_MULTI_POLYGON:
            onShape = [self isLocation:location onMultiPolygon:(GPKGMultiPolygon *)mapShape.shape withMapView:mapView];
            break;
        case GPKG_MST_COLLECTION:
        {
            NSArray * shapeArray = (NSArray *) mapShape.shape;
            for(GPKGMapShape * shapeArrayItem in shapeArray){
                onShape = [self isLocation:location onShape:shapeArrayItem withMapView:mapView andTolerance:tolerance];
                if(onShape){
                    break;
                }
            }
        }
            break;
        default:
            [NSException raise:@"Unsupported Shape" format:@"Unsupported Shape Type: %@", [GPKGMapShapeTypes name:mapShape.shapeType]];
    }
    
    return onShape;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location nearMapPoint: (GPKGMapPoint *) mapPoint withTolerance: (double) tolerance{
    return [self isLocation:location nearLocation:mapPoint.coordinate withTolerance:tolerance];
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location1 nearLocation: (CLLocationCoordinate2D) location2 withTolerance: (double) tolerance{
    return [GPKGTileBoundingBoxUtils distanceBetweenLocation:location1 andLocation:location2] <= tolerance;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location nearMultiPoint: (GPKGMultiPoint *) multiPoint withTolerance: (double) tolerance{
    BOOL near = false;
    for(GPKGMapPoint *mapPoint in multiPoint.points){
        near = [self isLocation:location nearMapPoint:mapPoint withTolerance:tolerance];
        if(near){
            break;
        }
    }
    return near;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolyline: (MKPolyline *) polyline withMapView: (MKMapView *) mapView andTolerance: (double) tolerance{
    
    MKPolylineRenderer *polylineRenderer = (MKPolylineRenderer *)[mapView rendererForOverlay:polyline];
    MKMapPoint mapPoint = MKMapPointForCoordinate(location);
    CGPoint point = [polylineRenderer pointForMapPoint:mapPoint];
    CGPathRef strokedPath = CGPathCreateCopyByStrokingPath(polylineRenderer.path, NULL, tolerance, kCGLineCapRound, kCGLineJoinRound, 1);
    BOOL onShape = CGPathContainsPoint(strokedPath, NULL, point, NO);
    CGPathRelease(strokedPath);
    
    // If not on the line, check the complementary line path in case it crosses -180 / 180 longitude
    if(!onShape){
        CGPathRef complementaryPath = [self complementaryWorldPathOfPolyline:polyline];
        if(complementaryPath != nil){
            CGPathRef complementaryStrokedPath = CGPathCreateCopyByStrokingPath(complementaryPath, NULL, tolerance, kCGLineCapRound, kCGLineJoinRound, 1);
            onShape = CGPathContainsPoint(complementaryStrokedPath, NULL, CGPointMake(mapPoint.x, mapPoint.y), NO);
            CGPathRelease(complementaryStrokedPath);
        }
        CGPathRelease(complementaryPath);
    }
    
    return onShape;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolyline: (GPKGMultiPolyline *) multiPolyline withMapView: (MKMapView *) mapView withTolerance: (double) tolerance{
    BOOL near = false;
    for(MKPolyline *polyline in multiPolyline.polylines){
        near = [self isLocation:location onPolyline:polyline withMapView:mapView andTolerance:tolerance];
        if(near){
            break;
        }
    }
    return near;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolygon: (MKPolygon *) polygon withMapView: (MKMapView *) mapView{
    
    MKPolygonRenderer *polygonRenderer = (MKPolygonRenderer *)[mapView rendererForOverlay:polygon];
    MKMapPoint mapPoint = MKMapPointForCoordinate(location);
    CGPoint point = [polygonRenderer pointForMapPoint:mapPoint];
    BOOL onShape = CGPathContainsPoint(polygonRenderer.path, NULL, point, NO);
    
    // If not on the polygon, check the complementary polygon path in case it crosses -180 / 180 longitude
    if(!onShape){
        CGPathRef complementaryPath = [self complementaryWorldPathOfPolygon:polygon];
        onShape = CGPathContainsPoint(complementaryPath, NULL, CGPointMake(mapPoint.x, mapPoint.y), NO);
        CGPathRelease(complementaryPath);
    }
    
    return onShape;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolygon: (GPKGMultiPolygon *) multiPolygon withMapView: (MKMapView *) mapView{
    BOOL near = false;
    for(MKPolygon *polygon in multiPolygon.polygons){
        near = [self isLocation:location onPolygon:polygon withMapView:mapView];
        if(near){
            break;
        }
    }
    return near;
}

@end
