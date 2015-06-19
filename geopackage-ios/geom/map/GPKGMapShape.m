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
            [mapView removeAnnotation:(MKPointAnnotation *)self.shape];
            break;
        case GPKG_MST_POLYGON:
            [mapView removeAnnotation:(MKPolygon *)self.shape];
            break;
        case GPKG_MST_POLYLINE:
            [mapView removeAnnotation:(MKPolyline *)self.shape];
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
    // TODO
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

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withPointAnnotation: (MKPointAnnotation *) point{
    [self expandBoundingBox:boundingBox withLatitude:point.coordinate.latitude andLongitude:point.coordinate.longitude];
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withPointAnnotations: (NSArray *) points{
    for(MKPointAnnotation * point in points){
        [self expandBoundingBox:boundingBox withPointAnnotation:point];
    }
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withMapPoint: (MKMapPoint) point{
    [self expandBoundingBox:boundingBox withLatitude:point.y andLongitude:point.x];
}

-(void) expandBoundingBox:(GPKGBoundingBox *)boundingBox withMapPoints: (MKMapPoint *) points andCount: (int) count{
    for(int i = 0; i < count; i++){
        [self expandBoundingBox:boundingBox withMapPoint:points[i]];
    }
}

@end
