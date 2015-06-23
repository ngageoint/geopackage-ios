//
//  GPKGMapShapeConverter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShapeConverter.h"
#import "GPKGMapPoint.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"

@interface GPKGMapShapeConverter ()

@property (nonatomic, strong) GPKGProjectionTransform *toWebMercator;
@property (nonatomic, strong) GPKGProjectionTransform *toWgs84;
@property (nonatomic, strong) GPKGProjectionTransform *fromWgs84;
@property (nonatomic, strong) GPKGProjectionTransform *fromWebMercator;

@end

@implementation GPKGMapShapeConverter

-(instancetype) initWithProjection: (GPKGProjection *) projection{
    self = [super init];
    if(self != nil){
        self.projection = projection;
        if(projection != nil){
            self.toWebMercator = [[GPKGProjectionTransform alloc] initWithFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
            GPKGProjection * webMercator = self.toWebMercator.toProjection;
            self.toWgs84 =[[GPKGProjectionTransform alloc] initWithFromProjection:webMercator andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
            GPKGProjection * wgs84 = self.toWgs84.toProjection;
            self.fromWgs84 = [[GPKGProjectionTransform alloc] initWithFromProjection:wgs84 andToProjection:webMercator];
            self.fromWebMercator = [[GPKGProjectionTransform alloc] initWithFromProjection:webMercator andToProjection:projection];
        }
    }
    return self;
}

-(WKBPoint *) toWgs84WithPoint: (WKBPoint *) point{
    if(self.projection != nil){
        point = [self.toWebMercator transformWithPoint:point];
        point = [self.toWgs84 transformWithPoint:point];
    }
    return point;
}

-(WKBPoint *) toProjectionWithPoint: (WKBPoint *) point{
    if(self.projection != nil){
        point = [self.fromWgs84 transformWithPoint:point];
        point = [self.fromWebMercator transformWithPoint:point];
    }
    return point;
}

-(GPKGMapPoint *) toMapPointWithPoint: (WKBPoint *) point{
    point = [self toWgs84WithPoint:point];
    GPKGMapPoint * mapPoint = [[GPKGMapPoint alloc] initWithPoint:point];
    return mapPoint;
}

-(MKMapPoint) toMKMapPointWithPoint: (WKBPoint *) point{
    point = [self toWgs84WithPoint:point];
    MKMapPoint mapPoint = MKMapPointMake([point.x doubleValue], [point.y doubleValue]);
    return mapPoint;
}

-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint{
    return [self toPointWithMapPoint:mapPoint andHasZ:false andHasM:false];
}

-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    double y = mapPoint.coordinate.latitude;
    double x = mapPoint.coordinate.latitude;
    WKBPoint * point = [[WKBPoint alloc] initWithHasZ:hasZ andHasM:hasM andX:[[NSDecimalNumber alloc] initWithDouble:x] andY:[[NSDecimalNumber alloc] initWithDouble:y]];
    point = [self toProjectionWithPoint:point];
    return point;
}

-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint{
    return [self toPointWithMKMapPoint:mapPoint andHasZ:false andHasM:false];
}

-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    double y = mapPoint.y;
    double x = mapPoint.x;
    WKBPoint * point = [[WKBPoint alloc] initWithHasZ:hasZ andHasM:hasM andX:[[NSDecimalNumber alloc] initWithDouble:x] andY:[[NSDecimalNumber alloc] initWithDouble:y]];
    point = [self toProjectionWithPoint:point];
    return point;
}

-(MKPolyline *) toMapPolylineWithLineString: (WKBLineString *) lineString{
    
    int numPoints = [[lineString numPoints] intValue];
    MKMapPoint mapPoints[numPoints];
    
    for(int i = 0; i < numPoints; i++){
        WKBPoint * point = (WKBPoint *)[lineString.points objectAtIndex:i];
        MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
        mapPoints[i] = mapPoint;
    }
    
    MKPolyline * polyline = [MKPolyline polylineWithPoints:mapPoints count:numPoints];
    
    return polyline;
}

-(WKBLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline{
    return [self toLineStringWithMapPolyline:mapPolyline andHasZ:false andHasM:false];
}

-(WKBLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return [self toLineStringWithMKMapPoints:mapPolyline.points andPointCount:mapPolyline.pointCount andHasZ:hasZ andHasM:hasM];
}

-(WKBLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount{
    return [self toLineStringWithMKMapPoints:mapPoints andPointCount:pointCount andHasZ:false andHasM:false];
}

-(WKBLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    WKBLineString * lineString = [[WKBLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    [self populateLineString:lineString withMKMapPoints:mapPoints andPointCount:pointCount];
    return lineString;
}

-(WKBLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints{
    return [self toLineStringWithMapPoints:mapPoints andHasZ:false andHasM:false];
}

-(WKBLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    WKBLineString * lineString = [[WKBLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    [self populateLineString:lineString withMapPoints:mapPoints];
    return lineString;
}

-(WKBCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints{
    return [self toCircularStringWithMapPoints:mapPoints andHasZ:false andHasM:false];
}

-(WKBCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    WKBCircularString * circularString = [[WKBCircularString alloc] initWithHasZ:hasZ andHasM:hasM];
    [self populateLineString:circularString withMapPoints:mapPoints];
    return circularString;
}

-(void) populateLineString: (WKBLineString *) lineString withMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount{
    for(int i = 0; i < pointCount; i++){
        WKBPoint * point = [self toPointWithMKMapPoint:mapPoints[i] andHasZ:lineString.hasZ andHasM:lineString.hasM];
        [lineString addPoint:point];
    }
}
     
-(void) populateLineString: (WKBLineString *) lineString withMapPoints: (NSArray *) mapPoints{
    for(GPKGMapPoint * mapPoint in mapPoints){
        WKBPoint * point = [self toPointWithMapPoint:mapPoint andHasZ:lineString.hasZ andHasM:lineString.hasM];
        [lineString addPoint:point];
    }
}

-(MKPolygon *) toMapPolygonWithPolygon: (WKBPolygon *) polygon{
    
    MKPolygon * mapPolygon = nil;
    
    NSArray * rings = polygon.rings;
    
    if([rings count] > 0){
        
        // Create the polygon points
        WKBLineString * polygonLineString = (WKBLineString *)[rings objectAtIndex:0];
        int numPoints = [[polygonLineString numPoints] intValue];
        MKMapPoint polygonPoints[numPoints];
        for(int i = 0; i < numPoints; i++){
            WKBPoint * point = (WKBPoint *)[polygonLineString.points objectAtIndex:i];
            MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
            polygonPoints[i] = mapPoint;
        }
        
        // Add the holes
        NSUInteger ringCount = [rings count];
        NSMutableArray * holes = [[NSMutableArray alloc] initWithCapacity:ringCount-1];
        for(int i = 1; i < ringCount; i++){
            WKBLineString * hole = (WKBLineString *)[rings objectAtIndex:i];
            int numHolePoints = [[polygonLineString numPoints] intValue];
            MKMapPoint holePoints[numHolePoints];
            for(int j = 0; j < numHolePoints; j++){
                WKBPoint * point = (WKBPoint *)[hole.points objectAtIndex:j];
                MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
                holePoints[j] = mapPoint;
            }
            MKPolygon * holePolygon = [MKPolygon polygonWithPoints:holePoints count:numHolePoints];
            [holes addObject:holePolygon];
        }
        
        mapPolygon = [MKPolygon polygonWithPoints:polygonPoints count:numPoints interiorPolygons:holes];
    }
    return mapPolygon;
}

-(WKBPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon{
    return [self toPolygonWithMapPolygon:mapPolygon andHasZ:false andHasM:false];
}

-(WKBPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return [self toPolygonWithMKMapPoints:mapPolygon.points andPointCount:mapPolygon.pointCount andHolePolygons:mapPolygon.interiorPolygons andHasZ:hasZ andHasM:hasM];
}

-(WKBPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes{
    return [self toPolygonWithMKMapPoints:mapPoints andPointCount:pointCount andHolePolygons:holes andHasZ:false andHasM:false];
}

-(WKBPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBPolygon * polygon = [[WKBPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    // Add the polygon points
    WKBLineString * polygonLineString = [[WKBLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    for(int i = 0; i < pointCount; i++){
        MKMapPoint mapPoint = mapPoints[i];
        WKBPoint * point = [self toPointWithMKMapPoint:mapPoint];
        [polygonLineString addPoint:point];
    }
    [polygon addRing:polygonLineString];
    
    // Add the holes
    if(holes != nil){
        for(MKPolygon * hole in holes){
            
            WKBLineString * holeLineString = [[WKBLineString alloc] initWithHasZ:hasZ andHasM:hasM];
            for(int i = 0; i < hole.pointCount; i++){
                MKMapPoint mapPoint = hole.points[i];
                WKBPoint * point = [self toPointWithMKMapPoint:mapPoint];
                [holeLineString addPoint:point];
            }
            [polygon addRing:holeLineString];
        }
    }
    
    return polygon;
}

-(WKBPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes{
    return [self toPolygonWithMapPoints:mapPoints andHolePoints:holes andHasZ:false andHasM:false];
}

-(WKBPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{

    WKBPolygon * polygon = [[WKBPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    // Add the polygon points
    WKBLineString * polygonLineString = [[WKBLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    for(GPKGMapPoint * mapPoint in mapPoints){
        WKBPoint * point = [self toPointWithMapPoint:mapPoint];
        [polygonLineString addPoint:point];
    }
    [polygon addRing:polygonLineString];
    
    // Add the holes
    if(holes != nil){
        for(NSArray * hole in holes){
            
            WKBLineString * holeLineString = [[WKBLineString alloc] initWithHasZ:hasZ andHasM:hasM];
            for(GPKGMapPoint * mapPoint in hole){
                WKBPoint * point = [self toPointWithMapPoint:mapPoint];
                [holeLineString addPoint:point];
            }
            [polygon addRing:holeLineString];
        }
    }
    
    return polygon;
}

-(GPKGMultiPoint *) toMapMultiPointWithMultiPoint: (WKBMultiPoint *) multiPoint{
    
    GPKGMultiPoint * mapMultiPoint = [[GPKGMultiPoint alloc] init];
    
    for(WKBPoint * point in [multiPoint getPoints]){
        GPKGMapPoint * mapPoint = [self toMapPointWithPoint:point];
        [mapMultiPoint addPoint:mapPoint];
    }
    
    return mapMultiPoint;
}

-(WKBMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint{
    return [self toMultiPointWithMapMultiPoint:mapMultiPoint andHasZ:false andHasM:false];
}

-(WKBMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return [self toMultiPointWithMapPoints:mapMultiPoint.points andHasZ:hasZ andHasM:hasM];
}

-(WKBMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints{
    return [self toMultiPointWithMapPoints:mapPoints andHasZ:false andHasM:false];
}

-(WKBMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiPoint * multiPoint = [[WKBMultiPoint alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(GPKGMapPoint * mapPoint in mapPoints){
        WKBPoint * point = [self toPointWithMapPoint:mapPoint];
        [multiPoint addPoint:point];
    }
    
    return multiPoint;
}

-(GPKGMultiPolyline *) toMapMultiPolylineWithMultiLineString: (WKBMultiLineString *) multiLineString{
    
    GPKGMultiPolyline * mapMultiPoyline = [[GPKGMultiPolyline alloc] init];
    
    for(WKBLineString * lineString in [multiLineString getLineStrings]){
        MKPolyline * polyline = [self toMapPolylineWithLineString:lineString];
        [mapMultiPoyline addPolyline:polyline];
    }
    
    return mapMultiPoyline;
}

-(WKBMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines{
    return [self toMultiLineStringWithMapPolylines:mapPolylines andHasZ:false andHasM:false];
}

-(WKBMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiLineString * multiLineString = [[WKBMultiLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in mapPolylines){
        WKBLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [multiLineString addLineString:lineString];
    }
    
    return multiLineString;
}

-(WKBMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray{
    return [self toMultiLineStringWithMapPolylinesArray:mapPolylinesArray andHasZ:false andHasM:false];
}

-(WKBMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{

    WKBMultiLineString * multiLineString = [[WKBMultiLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(NSArray * polyline in mapPolylinesArray){
        WKBLineString * lineString = [self toLineStringWithMapPoints:polyline];
        [multiLineString addLineString:lineString];
    }
    
    return multiLineString;
}

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray{
    return [self toCompoundCurveWithMapPolylinesArray:mapPolylinesArray andHasZ:false andHasM:false];
}

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{

    WKBCompoundCurve * compoundCurve = [[WKBCompoundCurve alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(NSArray * polyline in mapPolylinesArray){
        WKBLineString * lineString = [self toLineStringWithMapPoints:polyline];
        [compoundCurve addLineString:lineString];
    }
    
    return compoundCurve;
}

-(WKBMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline{
    return [self toMultiLineStringWithMapMultiPolyline:multiPolyline andHasZ:false andHasM:false];
}

-(WKBMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiLineString * multiLineString = [[WKBMultiLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in multiPolyline.polylines){
        WKBLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [multiLineString addLineString:lineString];
    }
    
    return multiLineString;
}

-(WKBCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline{
    return [self toCompoundCurveWithMapMultiPolyline:multiPolyline andHasZ:false andHasM:false];
}

-(WKBCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBCompoundCurve * compoundCurve = [[WKBCompoundCurve alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in multiPolyline.polylines){
        WKBLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [compoundCurve addLineString:lineString];
    }
    
    return compoundCurve;
}

-(GPKGMultiPolygon *) toMapMultiPolygonWithMultiPolygon: (WKBMultiPolygon *) multiPolygon{
    
    GPKGMultiPolygon * mapMultiPolygon = [[GPKGMultiPolygon alloc] init];
    
    for(WKBPolygon * polygon in [multiPolygon getPolygons]){
        MKPolygon * mapPolygon = [self toMapPolygonWithPolygon:polygon];
        [mapMultiPolygon addPolygon:mapPolygon];
    }
    
    return mapMultiPolygon;
}

-(WKBMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons{
    return [self toMultiPolygonWithMapPolygons:mapPolygons andHasZ:false andHasM:false];
}

-(WKBMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiPolygon * multiPolygon = [[WKBMultiPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolygon * mapPolygon in mapPolygons){
        WKBPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(WKBMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons{
    return [self createMultiPolygonWithPolygons:polygons andHasZ:false andHasM:false];
}

-(WKBMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiPolygon * multiPolygon = [[WKBMultiPolygon alloc] init];
    
    for(WKBPolygon * polygon in polygons){
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon{
    return [self toMultiPolygonWithMapMultiPolygon:mapMultiPolygon andHasZ:false andHasM:false];
}

-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiPolygon * multiPolygon = [[WKBMultiPolygon alloc] init];
    
    for(MKPolygon * mapPolygon in mapMultiPolygon.polygons){
        WKBPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(GPKGMultiPolyline *) toMapMultiPolylineWithCompoundCurve: (WKBCompoundCurve *) compoundCurve{
    
    GPKGMultiPolyline * mapMultiPolyline = [[GPKGMultiPolyline alloc] init];
    
    for(WKBLineString * lineString in compoundCurve.lineStrings){
        MKPolyline * mapPolyline = [self toMapPolylineWithLineString:lineString];
        [mapMultiPolyline addPolyline:mapPolyline];
    }
    
    return mapMultiPolyline;
}

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines{
    return [self toCompoundCurveWithMapPolylines:mapPolylines andHasZ:false andHasM:false];
}

-(WKBCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBCompoundCurve * compoundCurve = [[WKBCompoundCurve alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in mapPolylines){
        WKBLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [compoundCurve addLineString:lineString];
    }
    
    return compoundCurve;
}

-(GPKGMultiPolygon *) toMapMultiPolygonWithPolyhedralSurface: (WKBPolyhedralSurface *) polyhedralSurface{
    return nil; //TODO
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons{
    return nil; //TODO
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return nil; //TODO
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon{
    return nil; //TODO
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return nil; //TODO
}

-(GPKGMapShape *) toShapeWithGeometry: (WKBGeometry *) geometry{
    return nil; //TODO
}

-(NSArray *) toShapesWithGeometryCollection: (WKBGeometryCollection *) geometryCollection{
    return nil; //TODO
}

-(GPKGMapShape *) addGeometry: (WKBGeometry *) geometry toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(GPKGMapShape *) addMapShape: (GPKGMapShape *) mapShape toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(GPKGMapPoint *) addMapPoint: (GPKGMapPoint *) mapPoint toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(MKPolyline *) addMapPolyline: (MKPolyline *) mapPolyline toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(MKPolygon *) addMapPolygon: (MKPolygon *) mapPolylgon toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(GPKGMultiPoint *) addMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(GPKGMultiPolyline *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

+(GPKGMultiPolygon *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

-(GPKGMapShape *) addGeometryCollection: (WKBGeometryCollection *) geometryCollection toMapView: (MKMapView *) mapView{
    return nil; //TODO
}

-(GPKGMapShapePoints *) addMapShape: (GPKGMapShape *) mapShape asPointsToMapView: (MKMapView *) mapView{
    return nil; //TODO
}

-(NSArray *) addMapPoints: (NSArray *) mapPoints withPointCount: (NSUInteger) pointCount asPointsToMapView: (MKMapView *) mapView withIgnoreIdenticalEnds: (BOOL) ignoreIdenticalEnds{
    return nil; //TODO
}

-(GPKGPolylinePoints *) addMapPolyline: (MKPolyline *) mapPolyline asPointsToMapView: (MKMapView *) mapView{
    return nil; //TODO
}

-(GPKGPolygonPoints *) addMapPolygon: (MKPolygon *) mapPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints{
    return nil; //TODO
}

-(GPKGMultiPolylinePoints *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints{
    return nil; //TODO
}

-(GPKGMultiPolygonPoints *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints{
    return nil; //TODO
}

-(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points{
    CLLocationCoordinate2D *coordinates = calloc([points count], sizeof(CLLocationCoordinate2D));
    int index = 0;
    for(GPKGMapPoint * point in points){
        coordinates[index++] = point.coordinate;
    }
    return coordinates;
}

-(WKBGeometry *) toGeometryFromMapShape: (GPKGMapShape *) mapShape{
    return nil; //TODO
}

@end
