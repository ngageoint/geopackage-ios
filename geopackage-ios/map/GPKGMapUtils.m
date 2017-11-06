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

+(GPKGMapTolerance *) toleranceWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    return [self toleranceWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(GPKGMapTolerance *) toleranceWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CGPoint point = [mapView convertCoordinate:location toPointToView:mapView];
    return [self toleranceWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(GPKGMapTolerance *) toleranceWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    
    double distance = [self toleranceDistanceWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
    double screen = [self toleranceScreenWithMapView:mapView andScreenPercentage:screenClickPercentage];
    
    GPKGMapTolerance *tolerance = [[GPKGMapTolerance alloc] initWithDistance:distance andScreen:screen];
    
    return tolerance;
}

+(double) toleranceDistanceWithPoint: (WKBPoint *) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    return [self toleranceDistanceWithLocationCoordinate:locationCoordinate andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(double) toleranceDistanceWithLocationCoordinate: (CLLocationCoordinate2D) location andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    CGPoint point = [mapView convertCoordinate:location toPointToView:mapView];
    return [self toleranceDistanceWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
}

+(double) toleranceDistanceWithCGPoint: (CGPoint) point andMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{
    
    GPKGLocationBoundingBox *boundingBox = [self buildClickLocationBoundingBoxWithCGPoint:point andMapView:mapView andScreenPercentage:screenClickPercentage];
    
    double longitudeDistance = [GPKGTileBoundingBoxUtils distanceBetweenLocation:boundingBox.leftCoordinate andLocation:boundingBox.rightCoordinate];
    double latitudeDistance = [GPKGTileBoundingBoxUtils distanceBetweenLocation:boundingBox.downCoordinate andLocation:boundingBox.upCoordinate];
    
    double distance = MAX(longitudeDistance, latitudeDistance);
    
    return distance;
}

+(double) toleranceScreenWithMapView: (MKMapView *) mapView andScreenPercentage: (float) screenClickPercentage{

    MKMapSize mapSize = mapView.visibleMapRect.size;
    double length = MAX(mapSize.width, mapSize.height);
    double tolerance = length * screenClickPercentage;
    
    return tolerance;
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

+(BOOL) isLocation: (CLLocationCoordinate2D) location onShape: (GPKGMapShape *) mapShape withTolerance: (GPKGMapTolerance *) tolerance{
    
    BOOL onShape = false;
    
    switch(mapShape.shapeType){
            
        case GPKG_MST_POINT:
            onShape = [self isLocation:location nearMapPoint:(GPKGMapPoint *) mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_POLYLINE:
            onShape = [self isLocation:location onPolyline:(MKPolyline *) mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_POLYGON:
            onShape = [self isLocation:location onPolygon:(MKPolygon *) mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_MULTI_POINT:
            onShape = [self isLocation:location nearMultiPoint:(GPKGMultiPoint *) mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_MULTI_POLYLINE:
            onShape = [self isLocation:location onMultiPolyline:(GPKGMultiPolyline *)mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_MULTI_POLYGON:
            onShape = [self isLocation:location onMultiPolygon:(GPKGMultiPolygon *)mapShape.shape withTolerance:tolerance];
            break;
        case GPKG_MST_COLLECTION:
        {
            NSArray * shapeArray = (NSArray *) mapShape.shape;
            for(GPKGMapShape * shapeArrayItem in shapeArray){
                onShape = [self isLocation:location onShape:shapeArrayItem withTolerance:tolerance];
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

+(BOOL) isLocation: (CLLocationCoordinate2D) location nearMapPoint: (GPKGMapPoint *) mapPoint withTolerance: (GPKGMapTolerance *) tolerance{
    return [self isLocation:location nearLocation:mapPoint.coordinate withTolerance:tolerance];
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location1 nearLocation: (CLLocationCoordinate2D) location2 withTolerance: (GPKGMapTolerance *) tolerance{
    return [GPKGTileBoundingBoxUtils distanceBetweenLocation:location1 andLocation:location2] <= tolerance.distance;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location nearMultiPoint: (GPKGMultiPoint *) multiPoint withTolerance: (GPKGMapTolerance *) tolerance{
    BOOL near = false;
    for(GPKGMapPoint *mapPoint in multiPoint.points){
        near = [self isLocation:location nearMapPoint:mapPoint withTolerance:tolerance];
        if(near){
            break;
        }
    }
    return near;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolyline: (MKPolyline *) polyline withTolerance: (GPKGMapTolerance *) tolerance{
    
    MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:polyline];
    BOOL onShape = [self isLocation:location onRendererPath:polylineRenderer withTolerance:tolerance];

    // If not on the line, check the complementary line path in case it crosses -180 / 180 longitude
    if(!onShape){
        CGPathRef complementaryPath = [self complementaryWorldPathOfPolyline:polyline];
        if(complementaryPath != nil){
            onShape = [self isLocation:location onPath:complementaryPath withRenderer:polylineRenderer andTolerance:tolerance];
        }
        CGPathRelease(complementaryPath);
    }
    
    [polylineRenderer invalidatePath];
    
    return onShape;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolyline: (GPKGMultiPolyline *) multiPolyline withTolerance: (GPKGMapTolerance *) tolerance{
    BOOL near = false;
    for(MKPolyline *polyline in multiPolyline.polylines){
        near = [self isLocation:location onPolyline:polyline withTolerance:tolerance];
        if(near){
            break;
        }
    }
    return near;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolygon: (MKPolygon *) polygon withTolerance: (GPKGMapTolerance *) tolerance{
    
    MKPolygonRenderer *polygonRenderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
    BOOL onShape = [self isLocation:location containedInRendererPath:polygonRenderer withTolerance:tolerance] ||
        [self isLocation:location onRendererPath:polygonRenderer withTolerance:tolerance];

    if(onShape){
        // Verify not in a hole
        onShape = ![self isLocation:location onPolygonHoles:polygon withComplementary:false];
    }else{
        // Check the complementary polygon path in case it crosses -180 / 180 longitude
        
        CGPathRef complementaryPath = [self complementaryWorldPathOfPolygon:polygon];
        if(complementaryPath != nil){
            onShape = [self isLocation:location containedInPath:complementaryPath withRenderer:polygonRenderer andTolerance:tolerance] ||
                [self isLocation:location onPath:complementaryPath withRenderer:polygonRenderer andTolerance:tolerance];
        }
        CGPathRelease(complementaryPath);
        
        if(onShape){
            // Verify not in a hole
            onShape = ![self isLocation:location onPolygonHoles:polygon withComplementary:true];
        }
    }
    
    [polygonRenderer invalidatePath];
    
    return onShape;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onPolygonHoles: (MKPolygon *) polygon withComplementary: (BOOL) complementary{
    
    BOOL onHole = false;
    
    for(MKPolygon *hole in polygon.interiorPolygons){
        
        MKPolygonRenderer *holeRenderer = [[MKPolygonRenderer alloc] initWithPolygon:hole];
        MKMapPoint mapPoint = MKMapPointForCoordinate(location);
        CGPoint point = [holeRenderer pointForMapPoint:mapPoint];
        
        CGPathRef holePath;
        if(complementary){
            holePath = [self complementaryWorldPathOfPolygon:hole];
        }else{
            holePath = holeRenderer.path;
        }
        
        onHole = CGPathContainsPoint(holePath, NULL, point, NO);
        
        if(complementary){
            CGPathRelease(holePath);
        }
        [holeRenderer invalidatePath];
        
        if(onHole){
            break;
        }
    }
    
    return onHole;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onMultiPolygon: (GPKGMultiPolygon *) multiPolygon withTolerance: (GPKGMapTolerance *) tolerance{
    BOOL near = false;
    for(MKPolygon *polygon in multiPolygon.polygons){
        near = [self isLocation:location onPolygon:polygon withTolerance:tolerance];
        if(near){
            break;
        }
    }
    return near;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onRendererPath: (MKOverlayPathRenderer *) renderer withTolerance: (GPKGMapTolerance *) tolerance{
    return [self isLocation:location onPath:renderer.path withRenderer:renderer andTolerance:tolerance];
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location onPath: (CGPathRef) path withRenderer: (MKOverlayPathRenderer *) renderer andTolerance: (GPKGMapTolerance *) tolerance{
    MKMapPoint mapPoint = MKMapPointForCoordinate(location);
    CGPoint point = [renderer pointForMapPoint:mapPoint];
    CGPathRef strokedPath = CGPathCreateCopyByStrokingPath(path, NULL, 2 * tolerance.screen, kCGLineCapRound, kCGLineJoinRound, 1);
    BOOL onShape = CGPathContainsPoint(strokedPath, NULL, point, NO);
    CGPathRelease(strokedPath);
    return onShape;
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location containedInRendererPath: (MKOverlayPathRenderer *) renderer withTolerance: (GPKGMapTolerance *) tolerance{
    return [self isLocation:location containedInPath:renderer.path withRenderer:renderer andTolerance:tolerance];
}

+(BOOL) isLocation: (CLLocationCoordinate2D) location containedInPath: (CGPathRef) path withRenderer: (MKOverlayPathRenderer *) renderer andTolerance: (GPKGMapTolerance *) tolerance{
    MKMapPoint mapPoint = MKMapPointForCoordinate(location);
    CGPoint point = [renderer pointForMapPoint:mapPoint];
    BOOL onShape = CGPathContainsPoint(path, NULL, point, NO);
    return onShape;
}

@end
