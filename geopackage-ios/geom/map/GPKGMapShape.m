//
//  GPKGMapShape.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShape.h"
#import "GPKGMultiPoint.h"
#import "GPKGMultiPolyline.h"
#import "GPKGMultiPolygon.h"
#import "GPKGPolylinePoints.h"
#import "GPKGPolygonPoints.h"
#import "GPKGMultiPolylinePoints.h"
#import "GPKGMultiPolygonPoints.h"
#import "GPKGMapPoint.h"

@implementation GPKGMapShape

-(instancetype) initWithGeometryType: (enum WKBGeometryType) geometryType andShapeType: (enum GPKGMapShapeType) shapeType andShape: (NSObject *) shape{
    self = [super init];
    if(self != nil){
        self.geometryType = geometryType;
        self.shapeType = shapeType;
        self.shape = shape;
    }
    return self;
}

-(void) removeFromMapView: (MKMapView *) mapView{
    
    switch(self.shapeType){
        case GPKG_MST_POINT:
            [mapView removeAnnotation:(GPKGMapPoint *)self.shape];
            break;
        case GPKG_MST_POLYGON:
            [mapView removeOverlay:(MKPolygon *)self.shape];
            break;
        case GPKG_MST_POLYLINE:
            [mapView removeOverlay:(MKPolyline *)self.shape];
            break;
        case GPKG_MST_MULTI_POINT:
            [(GPKGMultiPoint *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_MULTI_POLYLINE:
            [(GPKGMultiPolyline *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_MULTI_POLYGON:
            [(GPKGMultiPolygon *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_POLYLINE_POINTS:
            [(GPKGPolylinePoints *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_POLYGON_POINTS:
            [(GPKGPolygonPoints *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_MULTI_POLYLINE_POINTS:
            [(GPKGMultiPolylinePoints *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_MULTI_POLYGON_POINTS:
            [(GPKGMultiPolygonPoints *)self.shape removeFromMapView:mapView];
            break;
        case GPKG_MST_COLLECTION:{
            NSArray * shapeCollection = (NSArray *) self.shape;
            for(GPKGMapShape * collectionShape in shapeCollection){
                [collectionShape removeFromMapView:mapView];
            }
            break;
        }
        default:
            break;
    }
}

-(void) updateWithMapView: (MKMapView *) mapView{
    
    switch(self.shapeType){
        case GPKG_MST_POLYLINE_POINTS:
            [(GPKGPolylinePoints *)self.shape updateWithMapView:mapView];
            break;
        case GPKG_MST_POLYGON_POINTS:
            [(GPKGPolygonPoints *)self.shape updateWithMapView:mapView];
            break;
        case GPKG_MST_MULTI_POLYLINE_POINTS:
            [(GPKGMultiPolylinePoints *)self.shape updateWithMapView:mapView];
            break;
        case GPKG_MST_MULTI_POLYGON_POINTS:
            [(GPKGMultiPolygonPoints *)self.shape updateWithMapView:mapView];
            break;
        case GPKG_MST_COLLECTION:{
            NSArray * shapeCollection = (NSArray *) self.shape;
            for(GPKGMapShape * collectionShape in shapeCollection){
                [collectionShape updateWithMapView:mapView];
            }
            break;
        }
        default:
            break;
    }
}

-(BOOL) isValid{
    
    BOOL valid = true;
    
    switch(self.shapeType){
        case GPKG_MST_POLYLINE_POINTS:
            valid = [(GPKGPolylinePoints *)self.shape isValid];
            break;
        case GPKG_MST_POLYGON_POINTS:
            valid = [(GPKGPolygonPoints *)self.shape isValid];
            break;
        case GPKG_MST_MULTI_POLYLINE_POINTS:
            valid = [(GPKGMultiPolylinePoints *)self.shape isValid];
            break;
        case GPKG_MST_MULTI_POLYGON_POINTS:
            valid = [(GPKGMultiPolygonPoints *)self.shape isValid];
            break;
        case GPKG_MST_COLLECTION:{
            NSArray * shapeCollection = (NSArray *) self.shape;
            for(GPKGMapShape * collectionShape in shapeCollection){
                valid = [collectionShape isValid];
                if(!valid){
                    break;
                }
            }
            break;
        }
        default:
            break;
    }
    
    return valid;
}

-(GPKGBoundingBox *) boundingBox{
    GPKGBoundingBox * boundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:180.0 andMaxLongitudeDouble:-180.0 andMinLatitudeDouble:90.0 andMaxLatitudeDouble:-90.0];
    [self expandBoundingBox:boundingBox];
    return boundingBox;
}

-(void) expandBoundingBox: (GPKGBoundingBox *) boundingBox{

    switch(self.shapeType){
        case GPKG_MST_POINT:
            [self expandBoundingBox:boundingBox withPoint:(GPKGMapPoint *)self.shape];
            break;
        case GPKG_MST_POLYGON:
            {
                MKPolygon * polygon = (MKPolygon *) self.shape;
                [self expandBoundingBox:boundingBox withMapPoints:[polygon points] andCount:(int)[polygon pointCount]];
            }
            break;
        case GPKG_MST_POLYLINE:
            {
                MKPolyline * polyline = (MKPolyline *) self.shape;
                [self expandBoundingBox:boundingBox withMapPoints:[polyline points] andCount:(int)[polyline pointCount]];
            }
            break;
        case GPKG_MST_MULTI_POINT:
            [self expandBoundingBox:boundingBox withPoints:[(GPKGMultiPoint *)self.shape points]];
            break;
        case GPKG_MST_MULTI_POLYLINE:
            {
                GPKGMultiPolyline * multiPolyline = (GPKGMultiPolyline *) self.shape;
                for(MKPolyline * polyline in multiPolyline.polylines){
                    [self expandBoundingBox:boundingBox withMapPoints:[polyline points] andCount:(int)[polyline pointCount]];
                }
            }
            break;
        case GPKG_MST_MULTI_POLYGON:
            {
                GPKGMultiPolygon * multiPolygon = (GPKGMultiPolygon *) self.shape;
                for(MKPolygon * polygon in multiPolygon.polygons){
                    [self expandBoundingBox:boundingBox withMapPoints:[polygon points] andCount:(int)[polygon pointCount]];
                }
            }
            break;
        case GPKG_MST_POLYLINE_POINTS:
            [self expandBoundingBox:boundingBox withPoints:[(GPKGPolylinePoints *)self.shape points]];
            break;
        case GPKG_MST_POLYGON_POINTS:
            [self expandBoundingBox:boundingBox withPoints:[(GPKGPolygonPoints *)self.shape points]];
            break;
        case GPKG_MST_MULTI_POLYLINE_POINTS:
            {
                GPKGMultiPolylinePoints * multiPolylinePoints = (GPKGMultiPolylinePoints *) self.shape;
                for(GPKGPolylinePoints * polylinePoints in multiPolylinePoints.polylinePoints){
                    [self expandBoundingBox:boundingBox withPoints:[polylinePoints points]];
                }
            }
            break;
        case GPKG_MST_MULTI_POLYGON_POINTS:
            {
                GPKGMultiPolygonPoints * multiPolygonPoints = (GPKGMultiPolygonPoints *) self.shape;
                for(GPKGPolygonPoints * polygonPoints in multiPolygonPoints.polygonPoints){
                    [self expandBoundingBox:boundingBox withPoints:[polygonPoints points]];
                }
            }
            break;
        case GPKG_MST_COLLECTION:{
            NSArray * shapeCollection = (NSArray *) self.shape;
            for(GPKGMapShape * collectionShape in shapeCollection){
                [collectionShape expandBoundingBox:boundingBox];
            }
            break;
        }
        default:
            break;
    }
    
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withLatitude: (double) latitude andLongitude: (double) longitude{
    
    if(latitude < [boundingBox.minLatitude doubleValue]){
        boundingBox.minLatitude = [[NSDecimalNumber alloc] initWithDouble:latitude];
    }
    if(latitude > [boundingBox.maxLatitude doubleValue]){
        boundingBox.maxLatitude = [[NSDecimalNumber alloc] initWithDouble:latitude];
    }
    if(longitude < [boundingBox.minLongitude doubleValue]){
        boundingBox.minLongitude = [[NSDecimalNumber alloc] initWithDouble:longitude];
    }
    if(longitude > [boundingBox.maxLongitude doubleValue]){
        boundingBox.maxLongitude = [[NSDecimalNumber alloc] initWithDouble:longitude];
    }
    
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withPoint: (GPKGMapPoint *) point{
    [self expandBoundingBox:boundingBox withLatitude:point.coordinate.latitude andLongitude:point.coordinate.longitude];
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withPoints: (NSArray *) points{
    for(GPKGMapPoint * point in points){
        [self expandBoundingBox:boundingBox withPoint:point];
    }
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withMapPoint: (MKMapPoint) point{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(point);
    [self expandBoundingBox:boundingBox withLatitude:coord.latitude andLongitude:coord.longitude];
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withMapPoints: (MKMapPoint *) points andCount: (int) count{
    for(int i = 0; i < count; i++){
        [self expandBoundingBox:boundingBox withMapPoint:points[i]];
    }
}

@end
