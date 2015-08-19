//
//  GPKGMapShapePoints.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShapePoints.h"
#import "GPKGUtils.h"

@implementation GPKGMapShapePoints

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.shapePoints = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void) addPoint: (GPKGMapPoint *) point withShape: (NSObject<GPKGShapePoints> *) shapePoints{
    [self addPointId:(int)point.id withShape:shapePoints];
}

-(void) addPointId: (int) pointId withShape: (NSObject<GPKGShapePoints> *) shapePoints{
    [GPKGUtils setObject:shapePoints forKey:[NSNumber numberWithInt:pointId] inDictionary:self.shapePoints];
}

-(void) addShapePoints: (NSObject<GPKGShapePoints> *) shapePoints{
    for(GPKGMapPoint * point in [shapePoints getPoints]){
        [self addPoint:point withShape:shapePoints];
    }
}

-(void) addPoint: (GPKGMapPoint *) point{
    [self addPoint:point withShape:nil];
}

-(void) addPoints: (NSArray *) points{
    for(GPKGMapPoint * point in points){
        [self addPoint:point];
    }
}

-(void) addMapShapePoints: (GPKGMapShapePoints *) mapShapePoints{
    [self.shapePoints addEntriesFromDictionary:mapShapePoints.shapePoints];
}

-(BOOL) containsPoint: (GPKGMapPoint *) point{
    return [self containsPointId:(int)point.id];
}

-(BOOL) containsPointId: (int) pointId{
    return [self.shapePoints objectForKey:[NSNumber numberWithInt:pointId]] != nil;
}

-(NSObject<GPKGShapePoints> *) getShapePointsForPoint: (GPKGMapPoint *) point{
    return [self getShapePointsForPointId:(int)point.id];
}

-(NSObject<GPKGShapePoints> *) getShapePointsForPointId: (int) pointId{
    return [GPKGUtils objectForKey:[NSNumber numberWithInt:pointId] inDictionary:self.shapePoints];
}

-(BOOL) deletePoint: (GPKGMapPoint *) point fromMapView: (MKMapView *) mapView{
    BOOL deleted = false;
    if([self containsPoint:point]){
        deleted = true;
        NSObject<GPKGShapePoints> * shapePoints = [self getShapePointsForPoint:point];
        [self.shapePoints removeObjectForKey:[NSNumber numberWithInteger:point.id]];
        if(shapePoints != nil){
            [shapePoints deletePoint:point fromMapView:mapView];
        }
        [mapView removeAnnotation:point];
    }
    return deleted;
}

-(void) removeFromMapView: (MKMapView *) mapView{
    if(self.shape != nil){
        [self.shape removeFromMapView:mapView];
    }
}

-(void) updateWithMapView: (MKMapView *) mapView{
    if(self.shape != nil){
        [self.shape updateWithMapView:mapView];
    }
}

-(BOOL) isValid{
    BOOL valid = true;
    if(self.shape != nil){
        valid = [self.shape isValid];
    }
    return valid;
}

+(void) addPointAsPolygon: (GPKGMapPoint *) point toPoints: (NSMutableArray *) points{
    
    CLLocationCoordinate2D position = point.coordinate;
    CLLocation * location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
    int pointCount = (int)[points count];
    int insertLocation = pointCount;
    if(pointCount > 2){
        double distances[pointCount];
        insertLocation = 0;
        for(int i = 0; i < pointCount; i++){
            CLLocationCoordinate2D aPoint = ((GPKGMapPoint *) [points objectAtIndex:i]).coordinate;
            CLLocation * aLocation = [[CLLocation alloc] initWithLatitude:aPoint.latitude longitude:aPoint.longitude];
            distances[i] = [location distanceFromLocation:aLocation];
            if(i > 0 && distances[i] < distances[insertLocation]){
                insertLocation = i;
            }
        }
        
        int beforeLocation = insertLocation > 0 ? insertLocation - 1 : pointCount - 1;
        int afterLocation = insertLocation < pointCount - 1 ? insertLocation + 1 : 0;
        
        if(distances[beforeLocation] > distances[afterLocation]){
            insertLocation = afterLocation;
        }
    }
    [points insertObject:point atIndex:insertLocation];
}

+(void) addPointAsPolyline: (GPKGMapPoint *) point toPoints: (NSMutableArray *) points{
    
    CLLocationCoordinate2D position = point.coordinate;
    CLLocation * location = [[CLLocation alloc] initWithLatitude:position.latitude longitude:position.longitude];
    int pointCount = (int)[points count];
    int insertLocation = pointCount;
    if(pointCount > 1){
        double distances[pointCount];
        insertLocation = 0;
        for(int i = 0; i < pointCount; i++){
            CLLocationCoordinate2D aPoint = ((GPKGMapPoint *) [points objectAtIndex:i]).coordinate;
            CLLocation * aLocation = [[CLLocation alloc] initWithLatitude:aPoint.latitude longitude:aPoint.longitude];
            distances[i] = [location distanceFromLocation:aLocation];
            if(i > 0 && distances[i] < distances[insertLocation]){
                insertLocation = i;
            }
        }
        
        NSNumber * beforeLocation = insertLocation > 0 ? [NSNumber numberWithInt:(insertLocation - 1)] : nil;
        NSNumber * afterLocation = insertLocation < pointCount - 1 ? [NSNumber numberWithInt:(insertLocation + 1)] : nil;
        
        if(beforeLocation != nil && afterLocation != nil){
            if(distances[[beforeLocation intValue]] > distances[[afterLocation intValue]]){
                insertLocation = [afterLocation intValue];
            }
        } else{
            
            CLLocationCoordinate2D insertPoint = ((GPKGMapPoint *) [points objectAtIndex:insertLocation]).coordinate;
            CLLocation * insertPointLocation = [[CLLocation alloc] initWithLatitude:insertPoint.latitude longitude:insertPoint.longitude];
            
            if(beforeLocation != nil){
                CLLocationCoordinate2D beforePoint = ((GPKGMapPoint *) [points objectAtIndex:[beforeLocation intValue]]).coordinate;
                CLLocation * beforePointLocation = [[CLLocation alloc] initWithLatitude:beforePoint.latitude longitude:beforePoint.longitude];
                if(distances[[beforeLocation intValue]] >= [insertPointLocation distanceFromLocation:beforePointLocation]){
                    insertLocation++;
                }
            }else{
                CLLocationCoordinate2D afterPoint = ((GPKGMapPoint *) [points objectAtIndex:[afterLocation intValue]]).coordinate;
                CLLocation * afterPointLocation = [[CLLocation alloc] initWithLatitude:afterPoint.latitude longitude:afterPoint.longitude];
                if(distances[[afterLocation intValue]] < [insertPointLocation distanceFromLocation:afterPointLocation]){
                    insertLocation++;
                }
            }
        }
    }
    [points insertObject:point atIndex:insertLocation];
}

@end
