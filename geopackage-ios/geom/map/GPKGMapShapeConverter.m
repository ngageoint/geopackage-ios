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
#import "GPKGUtils.h"

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
    MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]));
    return mapPoint;
}

-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint{
    return [self toPointWithMapPoint:mapPoint andHasZ:false andHasM:false];
}

-(WKBPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    double y = mapPoint.coordinate.latitude;
    double x = mapPoint.coordinate.longitude;
    WKBPoint * point = [[WKBPoint alloc] initWithHasZ:hasZ andHasM:hasM andX:[[NSDecimalNumber alloc] initWithDouble:x] andY:[[NSDecimalNumber alloc] initWithDouble:y]];
    point = [self toProjectionWithPoint:point];
    return point;
}

-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint{
    return [self toPointWithMKMapPoint:mapPoint andHasZ:false andHasM:false];
}

-(WKBPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    double y = coord.latitude;
    double x = coord.longitude;
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
            int numHolePoints = [[hole numPoints] intValue];
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
    
    WKBMultiPolygon * multiPolygon = [[WKBMultiPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(WKBPolygon * polygon in polygons){
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon{
    return [self toMultiPolygonWithMapMultiPolygon:mapMultiPolygon andHasZ:false andHasM:false];
}

-(WKBMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBMultiPolygon * multiPolygon = [[WKBMultiPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
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
    
    GPKGMultiPolygon * mapMultiPolygon = [[GPKGMultiPolygon alloc] init];
    
    for(WKBPolygon * polygon in polyhedralSurface.polygons){
        MKPolygon * mapPolygon = [self toMapPolygonWithPolygon:polygon];
        [mapMultiPolygon addPolygon:mapPolygon];
    }
    
    return mapMultiPolygon;
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons{
    return [self toPolyhedralSurfaceWithMapPolygons:mapPolygons andHasZ:false andHasM:false];
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBPolyhedralSurface * polyhedralSurface = [[WKBPolyhedralSurface alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for (MKPolygon * mapPolygon in mapPolygons) {
        WKBPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [polyhedralSurface addPolygon:polygon];
    }
    
    return polyhedralSurface;
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon{
    return [self toPolyhedralSurfaceWithMapMultiPolygon:mapMultiPolygon andHasZ:false andHasM:false];
}

-(WKBPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    WKBPolyhedralSurface * polyhedralSurface = [[WKBPolyhedralSurface alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for (MKPolygon * mapPolygon in mapMultiPolygon.polygons) {
        WKBPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [polyhedralSurface addPolygon:polygon];
    }
    
    return polyhedralSurface;
}

-(GPKGMapShape *) toShapeWithGeometry: (WKBGeometry *) geometry{
    
    GPKGMapShape * shape = nil;
    
    enum WKBGeometryType geometryType = geometry.geometryType;
    switch (geometryType) {
        case WKB_POINT:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POINT andShape:[self toMapPointWithPoint:(WKBPoint *) geometry]];
            break;
        case WKB_LINESTRING:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[self toMapPolylineWithLineString:(WKBLineString *) geometry]];
            break;
        case WKB_POLYGON:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[self toMapPolygonWithPolygon:(WKBPolygon *) geometry]];
            break;
        case WKB_MULTIPOINT:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POINT andShape:[self toMapMultiPointWithMultiPoint:(WKBMultiPoint *) geometry]];
            break;
        case WKB_MULTILINESTRING:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[self toMapMultiPolylineWithMultiLineString:(WKBMultiLineString *) geometry]];
            break;
        case WKB_MULTIPOLYGON:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self toMapMultiPolygonWithMultiPolygon:(WKBMultiPolygon *) geometry]];
            break;
        case WKB_CIRCULARSTRING:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[self toMapPolylineWithLineString:(WKBCircularString *) geometry]];
            break;
        case WKB_COMPOUNDCURVE:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[self toMapMultiPolylineWithCompoundCurve:(WKBCompoundCurve *) geometry]];
            break;
        case WKB_POLYHEDRALSURFACE:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self toMapMultiPolygonWithPolyhedralSurface:(WKBPolyhedralSurface *) geometry]];
            break;
        case WKB_TIN:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self toMapMultiPolygonWithPolyhedralSurface:(WKBTIN *) geometry]];
            break;
        case WKB_TRIANGLE:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[self toMapPolygonWithPolygon:(WKBTriangle *) geometry]];
            break;
        case WKB_GEOMETRYCOLLECTION:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_COLLECTION andShape:[self toShapesWithGeometryCollection:(WKBGeometryCollection *) geometry]];
            break;
        default:
            [NSException raise:@"Unsupported Geometry" format:@"Unsupported Geometry Type: %@", [WKBGeometryTypes name:geometryType]];
    }
    
    return shape;
}

-(NSArray *) toShapesWithGeometryCollection: (WKBGeometryCollection *) geometryCollection{
    
    NSMutableArray * shapes = [[NSMutableArray alloc] init];
    
    for(WKBGeometry * geometry in geometryCollection.geometries){
        GPKGMapShape * shape = [self toShapeWithGeometry:geometry];
        [GPKGUtils addObject:shape toArray:shapes];
    }
    
    return shapes;
}

-(GPKGMapShape *) addGeometry: (WKBGeometry *) geometry toMapView: (MKMapView *) mapView{
    
    GPKGMapShape * addedShape = nil;
    
    enum WKBGeometryType geometryType = geometry.geometryType;
    switch (geometryType) {
        case WKB_POINT:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POINT andShape:[GPKGMapShapeConverter addMapPoint:[self toMapPointWithPoint:(WKBPoint *) geometry] toMapView:mapView]];
            break;
        case WKB_LINESTRING:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[GPKGMapShapeConverter addMapPolyline:[self toMapPolylineWithLineString:(WKBLineString *) geometry] toMapView:mapView]];
            break;
        case WKB_POLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[GPKGMapShapeConverter addMapPolygon:[self toMapPolygonWithPolygon:(WKBPolygon *) geometry] toMapView:mapView]];
            break;
        case WKB_MULTIPOINT:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POINT andShape:[GPKGMapShapeConverter addMapMultiPoint:[self toMapMultiPointWithMultiPoint:(WKBMultiPoint *) geometry]toMapView:mapView]];
            break;
        case WKB_MULTILINESTRING:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[GPKGMapShapeConverter addMapMultiPolyline:[self toMapMultiPolylineWithMultiLineString:(WKBMultiLineString *) geometry]toMapView:mapView]];
            break;
        case WKB_MULTIPOLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[GPKGMapShapeConverter addMapMultiPolygon:[self toMapMultiPolygonWithMultiPolygon:(WKBMultiPolygon *) geometry]toMapView:mapView]];
            break;
        case WKB_CIRCULARSTRING:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[GPKGMapShapeConverter addMapPolyline:[self toMapPolylineWithLineString:(WKBCircularString *) geometry]toMapView:mapView]];
            break;
        case WKB_COMPOUNDCURVE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[GPKGMapShapeConverter addMapMultiPolyline:[self toMapMultiPolylineWithCompoundCurve:(WKBCompoundCurve *) geometry]toMapView:mapView]];
            break;
        case WKB_POLYHEDRALSURFACE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[GPKGMapShapeConverter addMapMultiPolygon:[self toMapMultiPolygonWithPolyhedralSurface:(WKBPolyhedralSurface *) geometry]toMapView:mapView]];
            break;
        case WKB_TIN:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[GPKGMapShapeConverter addMapMultiPolygon:[self toMapMultiPolygonWithPolyhedralSurface:(WKBTIN *) geometry]toMapView:mapView]];
            break;
        case WKB_TRIANGLE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[GPKGMapShapeConverter addMapPolygon:[self toMapPolygonWithPolygon:(WKBTriangle *) geometry]toMapView:mapView]];
            break;
        case WKB_GEOMETRYCOLLECTION:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_COLLECTION andShape:[self addGeometryCollection:(WKBGeometryCollection *) geometry toMapView:mapView]];
            break;
        default:
            [NSException raise:@"Unsupported Geometry" format:@"Unsupported Geometry Type: %@", [WKBGeometryTypes name:geometryType]];
    }
    
    return addedShape;
}

+(GPKGMapShape *) addMapShape: (GPKGMapShape *) mapShape toMapView: (MKMapView *) mapView{
    
    GPKGMapShape * addedShape = nil;
    
    switch (mapShape.shapeType) {
            
        case GPKG_MST_POINT:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POINT andShape:[self addMapPoint:(GPKGMapPoint *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_POLYLINE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYLINE andShape:[self addMapPolyline:(MKPolyline *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_POLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYGON andShape:[self addMapPolygon:(MKPolygon *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_MULTI_POINT:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POINT andShape:[self addMapMultiPoint:(GPKGMultiPoint *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_MULTI_POLYLINE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[self addMapMultiPolyline:(GPKGMultiPolyline *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_MULTI_POLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self addMapMultiPolygon:(GPKGMultiPolygon *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_COLLECTION:
            {
                NSMutableArray * addedShapeArray = [[NSMutableArray alloc] init];
                NSArray * shapeArray = (NSArray *) mapShape.shape;
                for(GPKGMapShape * shapeArrayItem in shapeArray){
                    [GPKGUtils addObject:[self addMapShape:shapeArrayItem toMapView:mapView] toArray:addedShapeArray];
                }
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_COLLECTION andShape:addedShapeArray];
            }
            break;
        default:
            [NSException raise:@"Unsupported Shape" format:@"Unsupported Shape Type: %@", [GPKGMapShapeTypes name:mapShape.shapeType]];
    }
    
    return addedShape;
}

+(GPKGMapPoint *) addMapPoint: (GPKGMapPoint *) mapPoint toMapView: (MKMapView *) mapView{
    return [self addMapPoint:mapPoint toMapView:mapView withPointOptions:nil];
}

+(GPKGMapPoint *) addMapPoint: (GPKGMapPoint *) mapPoint toMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions{
    if(pointOptions != nil){
        mapPoint.options = pointOptions;
        if(pointOptions.initializer != nil){
            [pointOptions.initializer initializeAnnotation:mapPoint];
        }
    }
    [mapView addAnnotation:mapPoint];
    return mapPoint;
}

+(GPKGMapPoint *) addMKMapPoint: (MKMapPoint) mkMapPoint toMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions{
    GPKGMapPoint * mapPoint = [[GPKGMapPoint alloc] initWithMKMapPoint:mkMapPoint];
    return [self addMapPoint:mapPoint toMapView:mapView withPointOptions:pointOptions];
}

+(MKPolyline *) addMapPolyline: (MKPolyline *) mapPolyline toMapView: (MKMapView *) mapView{
    [mapView addOverlay:mapPolyline];
    return mapPolyline;
}

+(MKPolygon *) addMapPolygon: (MKPolygon *) mapPolylgon toMapView: (MKMapView *) mapView{
    [mapView addOverlay:mapPolylgon];
    return mapPolylgon;
}

+(GPKGMultiPoint *) addMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint toMapView: (MKMapView *) mapView{
    return [self addMapMultiPoint:mapMultiPoint toMapView:mapView withPointOptions:nil];
}

+(GPKGMultiPoint *) addMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint toMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions{
    for(GPKGMapPoint * point in mapMultiPoint.points){
        [self addMapPoint:point toMapView:mapView withPointOptions:pointOptions];
    }
    return mapMultiPoint;
}

+(GPKGMultiPolyline *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline toMapView: (MKMapView *) mapView{
    for(MKPolyline * polyline in mapMultiPolyline.polylines){
        [self addMapPolyline:polyline toMapView:mapView];
    }
    return mapMultiPolyline;
}

+(GPKGMultiPolygon *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon toMapView: (MKMapView *) mapView{
    for(MKPolygon * polygon in mapMultiPolygon.polygons){
        [self addMapPolygon:polygon toMapView:mapView];
    }
    return mapMultiPolygon;
}

-(NSArray *) addGeometryCollection: (WKBGeometryCollection *) geometryCollection toMapView: (MKMapView *) mapView{
    
    NSMutableArray * shapes = [[NSMutableArray alloc] init];
    
    for(WKBGeometry * geometry in geometryCollection.geometries){
        GPKGMapShape * shape = [self addGeometry:geometry toMapView:mapView];
        [GPKGUtils addObject:shape toArray:shapes];
    }
    
    return shapes;
}

-(GPKGMapShapePoints *) addMapShape: (GPKGMapShape *) mapShape asPointsToMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions andPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions andPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions{
    
    GPKGMapShapePoints * shapePoints = [[GPKGMapShapePoints alloc] init];
    GPKGMapShape * addedShape = nil;
    
    switch(mapShape.shapeType){
            
        case GPKG_MST_POINT:
            {
                GPKGMapPoint * point = (GPKGMapPoint *) mapShape.shape;
                GPKGMapPoint * mapPoint = [GPKGMapShapeConverter addMapPoint:point toMapView:mapView withPointOptions:pointOptions];
                [shapePoints addPoint:mapPoint];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POINT andShape:mapPoint];
            }
            break;
        case GPKG_MST_POLYLINE:
            {
                GPKGPolylinePoints * polylinePoints = [self addMapPolyline:(MKPolyline *) mapShape.shape asPointsToMapView:mapView withPolylinePointOptions:polylinePointOptions];
                [shapePoints addShapePoints:polylinePoints];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYLINE_POINTS andShape:polylinePoints];
            }
            break;
        case GPKG_MST_POLYGON:
            {
                GPKGPolygonPoints * polygonPoints = [self addMapPolygon:(MKPolygon *) mapShape.shape asPointsToMapView:mapView withShapePoints:shapePoints withPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions];
                [shapePoints addShapePoints:polygonPoints];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYGON_POINTS andShape:polygonPoints];
            }
            break;
        case GPKG_MST_MULTI_POINT:
            {
                GPKGMultiPoint * multiPoint = [GPKGMapShapeConverter addMapMultiPoint:(GPKGMultiPoint *) mapShape.shape toMapView:mapView withPointOptions:pointOptions];
                [shapePoints addShapePoints:multiPoint];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POINT andShape:multiPoint];
            }
            break;
        case GPKG_MST_MULTI_POLYLINE:
            {
                GPKGMultiPolylinePoints * multiPolylinePoints = [self addMapMultiPolyline:(GPKGMultiPolyline *)mapShape.shape asPointsToMapView:mapView withShapePoints:shapePoints withPolylinePointOptions:polylinePointOptions];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POLYLINE_POINTS andShape:multiPolylinePoints];
            }
            break;
        case GPKG_MST_MULTI_POLYGON:
            {
                GPKGMultiPolygonPoints * multiPolygonPoints = [self addMapMultiPolygon:(GPKGMultiPolygon *)mapShape.shape asPointsToMapView:mapView withShapePoints:shapePoints withPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POLYGON_POINTS andShape:multiPolygonPoints];
            }
            break;
        case GPKG_MST_COLLECTION:
            {
                NSMutableArray * addedShapeArray = [[NSMutableArray alloc] init];
                NSArray * shapeArray = (NSArray *) mapShape.shape;
                for(GPKGMapShape * shapeArrayItem in shapeArray){
                    GPKGMapShapePoints * shapeArrayItemPoints = [self addMapShape:shapeArrayItem asPointsToMapView:mapView withPointOptions:pointOptions andPolylinePointOptions:polylinePointOptions andPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions];
                    [shapePoints addMapShapePoints:shapeArrayItemPoints];
                    [GPKGUtils addObject:shapeArrayItemPoints.shape toArray:addedShapeArray];
                }
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_COLLECTION andShape:addedShapeArray];
            }
            break;
        default:
            [NSException raise:@"Unsupported Shape" format:@"Unsupported Shape Type: %@", [GPKGMapShapeTypes name:mapShape.shapeType]];
    }
    [shapePoints setShape:addedShape];
    
    return shapePoints;
}

-(NSMutableArray *) addMKMapPoints: (MKMapPoint *) mapPoints withPointCount: (NSUInteger) pointCount asPointsToMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions andIgnoreIdenticalEnds: (BOOL) ignoreIdenticalEnds{
    
    NSMutableArray * points = [[NSMutableArray alloc] init];
    for(int i = 0; i < pointCount; i++){
        MKMapPoint point = mapPoints[i];
        
        if(i + 1 == pointCount && ignoreIdenticalEnds){
            MKMapPoint firstPoint = mapPoints[0];
            if(point.y == firstPoint.y && point.x == firstPoint.x){
                break;
            }
        }
        
        GPKGMapPoint * mapPoint = [GPKGMapShapeConverter addMKMapPoint:point toMapView:mapView withPointOptions:pointOptions];
        [GPKGUtils addObject:mapPoint toArray:points];
    }
    return points;
}

-(GPKGPolylinePoints *) addMapPolyline: (MKPolyline *) mapPolyline asPointsToMapView: (MKMapView *) mapView withPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions{
    
    GPKGPolylinePoints * polylinePoints = [[GPKGPolylinePoints alloc] init];
    
    MKPolyline * polyline = [GPKGMapShapeConverter addMapPolyline:mapPolyline toMapView:mapView];
    [polylinePoints setPolyline:polyline];
    
    NSMutableArray * points = [self addMKMapPoints:polyline.points withPointCount:polyline.pointCount asPointsToMapView:mapView withPointOptions:polylinePointOptions andIgnoreIdenticalEnds:false];
    [polylinePoints setPoints:points];
    
    return polylinePoints;
}

-(GPKGPolygonPoints *) addMapPolygon: (MKPolygon *) mapPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions{
    
    GPKGPolygonPoints * polygonPoints = [[GPKGPolygonPoints alloc] init];
    
    MKPolygon * polygon = [GPKGMapShapeConverter addMapPolygon:mapPolygon toMapView:mapView];
    [polygonPoints setPolygon:polygon];
    
    NSMutableArray * points = [self addMKMapPoints:polygon.points withPointCount:polygon.pointCount asPointsToMapView:mapView withPointOptions:polygonPointOptions andIgnoreIdenticalEnds:true];
    [polygonPoints setPoints:points];
    
    for(MKPolygon * hole in polygon.interiorPolygons){
        NSMutableArray * holePoints = [self addMKMapPoints:hole.points withPointCount:hole.pointCount asPointsToMapView:mapView withPointOptions:polygonHolePointOptions andIgnoreIdenticalEnds:true];
        GPKGPolygonHolePoints * polygonHolePoints = [[GPKGPolygonHolePoints alloc] initWithPolygonPoints:polygonPoints];
        [polygonHolePoints setPoints:holePoints];
        [shapePoints addShapePoints:polygonHolePoints];
        [polygonPoints addHole:polygonHolePoints];
    }
    
    return polygonPoints;
}

-(GPKGMultiPolylinePoints *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions{
    
    GPKGMultiPolylinePoints * multiPolylinePoints = [[GPKGMultiPolylinePoints alloc] init];
    for(MKPolyline * polyline in mapMultiPolyline.polylines){
        GPKGPolylinePoints * polylinePoints = [self addMapPolyline:polyline asPointsToMapView:mapView withPolylinePointOptions:polylinePointOptions];
        [shapePoints addShapePoints:polylinePoints];
        [multiPolylinePoints addPolylinePoints:polylinePoints];
    }
    return multiPolylinePoints;
}

-(GPKGMultiPolygonPoints *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions{

    GPKGMultiPolygonPoints * multiPolygonPoints = [[GPKGMultiPolygonPoints alloc] init];
    for(MKPolygon * polygon in mapMultiPolygon.polygons){
        GPKGPolygonPoints * polygonPoints = [self addMapPolygon:polygon asPointsToMapView:mapView withShapePoints:shapePoints withPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions];
        [shapePoints addShapePoints:polygonPoints];
        [multiPolygonPoints addPolygonPoints:polygonPoints];
    }
    return multiPolygonPoints;
}

+(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points{
    CLLocationCoordinate2D *coordinates = calloc([points count], sizeof(CLLocationCoordinate2D));
    int index = 0;
    for(GPKGMapPoint * point in points){
        coordinates[index++] = point.coordinate;
    }
    return coordinates;
}

+(CLLocationCoordinate2D *) getLocationCoordinatesFromLocations: (NSArray *) locations{
    CLLocationCoordinate2D *coordinates = calloc([locations count], sizeof(CLLocationCoordinate2D));
    int index = 0;
    for(CLLocation * location in locations){
        coordinates[index++] = location.coordinate;
    }
    return coordinates;
}

-(NSArray *) toMapPointsFromMKMapPoints: (MKMapPoint *) mkMapPoints andPointCount: (NSUInteger) pointCount{
    
    NSMutableArray * mapPoints = [[NSMutableArray alloc] initWithCapacity:pointCount];
    for(int i = 0; i < pointCount; i++){
        MKMapPoint mkMapPoint = mkMapPoints[i];
        GPKGMapPoint * mapPoint = [[GPKGMapPoint alloc] initWithMKMapPoint:mkMapPoint];
        [GPKGUtils addObject:mapPoint toArray:mapPoints];
    }
    
    return mapPoints;
}

-(WKBGeometry *) toGeometryFromMapShape: (GPKGMapShape *) mapShape{
    
    WKBGeometry * geometry = nil;
    NSObject * shapeObject = mapShape.shape;
    
    switch(mapShape.geometryType){

        case WKB_POINT:
            {
                GPKGMapPoint * point = nil;
                switch(mapShape.shapeType){
                    case GPKG_MST_POINT:
                        point = (GPKGMapPoint *) shapeObject;
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [WKBGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(point != nil){
                    geometry = [self toPointWithMapPoint:point];
                }
                
            }
            break;
        case WKB_LINESTRING:
        case WKB_CIRCULARSTRING:
            {
                NSArray * lineStringPoints = nil;
                
                switch(mapShape.shapeType){
                    case GPKG_MST_POLYLINE:
                        {
                            MKPolyline * polyline = (MKPolyline *) shapeObject;
                            lineStringPoints = [self toMapPointsFromMKMapPoints:polyline.points andPointCount:polyline.pointCount];
                        }
                        break;
                    case GPKG_MST_POLYLINE_POINTS:
                        {
                            GPKGPolylinePoints * polylinePoints = (GPKGPolylinePoints *) shapeObject;
                            if(![polylinePoints isValid]){
                                [NSException raise:@"Not Valid" format:@"Polyline Points is not valid to create %@", [WKBGeometryTypes name:mapShape.geometryType]];
                            }
                            if(![polylinePoints isDeleted]){
                                lineStringPoints = polylinePoints.points;
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [WKBGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(lineStringPoints != nil){
                    switch(mapShape.geometryType){
                        case WKB_LINESTRING:
                            geometry = [self toLineStringWithMapPoints:lineStringPoints];
                            break;
                        case WKB_CIRCULARSTRING:
                            geometry = [self toCircularStringWithMapPoints:lineStringPoints];
                            break;
                        default:
                            [NSException raise:@"Unhandled Geometry" format:@"Unhandled Geometry Type %@", [WKBGeometryTypes name:mapShape.geometryType]];
                    }
                }
            }
            break;
        case WKB_POLYGON:
            {
                NSArray * polygonPoints = nil;
                NSMutableArray * holePointArray = nil;
                switch(mapShape.shapeType){
                    case GPKG_MST_POLYGON:
                        {
                            MKPolygon * polygon = (MKPolygon *) shapeObject;
                            polygonPoints = [self toMapPointsFromMKMapPoints:polygon.points andPointCount:polygon.pointCount];
                            if(polygon.interiorPolygons != nil){
                                holePointArray = [[NSMutableArray alloc] init];
                                for(MKPolygon * holePolygon in polygon.interiorPolygons){
                                    NSArray * holePolygonPoints = [self toMapPointsFromMKMapPoints:holePolygon.points andPointCount:holePolygon.pointCount];
                                    [GPKGUtils addObject:holePolygonPoints toArray:holePointArray];
                                }
                            }
                        }
                        break;
                    case GPKG_MST_POLYGON_POINTS:
                        {
                            GPKGPolygonPoints * thePolygonPoints = (GPKGPolygonPoints *) shapeObject;
                            if(![thePolygonPoints isValid]){
                                [NSException raise:@"Not Valid" format:@"Polygon Points is not valid to create %@", [WKBGeometryTypes name:mapShape.geometryType]];
                            }
                            if(![thePolygonPoints isDeleted]){
                                polygonPoints = thePolygonPoints.points;
                                holePointArray = [[NSMutableArray alloc] init];
                                for(GPKGPolygonHolePoints * holePoints in thePolygonPoints.holes){
                                    if(![holePoints isDeleted]){
                                        [GPKGUtils addObject:holePoints.points toArray:holePointArray];
                                    }
                                }
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [WKBGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(polygonPoints != nil){
                    geometry = [self toPolygonWithMapPoints:polygonPoints andHolePoints:holePointArray];
                }
            }
            break;
        case WKB_MULTIPOINT:
            {
                NSArray * multiPoints = nil;
                switch(mapShape.shapeType){
                    case GPKG_MST_MULTI_POINT:
                        {
                            GPKGMultiPoint * multiPoint = (GPKGMultiPoint *) shapeObject;
                            multiPoints = multiPoint.points;
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [WKBGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(multiPoints != nil){
                    geometry = [self toMultiPointWithMapPoints:multiPoints];
                }
            }
            break;
        case WKB_MULTILINESTRING:
        case WKB_COMPOUNDCURVE:
            {
                switch(mapShape.shapeType){
                    case GPKG_MST_MULTI_POLYLINE:
                        {
                            GPKGMultiPolyline * multiPolyline = (GPKGMultiPolyline *) shapeObject;
                            switch(mapShape.geometryType){
                                case WKB_MULTILINESTRING:
                                    geometry = [self toMultiLineStringWithMapMultiPolyline:multiPolyline];
                                    break;
                                case WKB_COMPOUNDCURVE:
                                    geometry = [self toCompoundCurveWithMapMultiPolyline:multiPolyline];
                                    break;
                                default:
                                    [NSException raise:@"Unhandled Geometry" format:@"Unhandled Geometry Type %@", [WKBGeometryTypes name:mapShape.geometryType]];
                            }
                        }
                        break;
                    case GPKG_MST_MULTI_POLYLINE_POINTS:
                        {
                            GPKGMultiPolylinePoints * multiPolylinePoints = (GPKGMultiPolylinePoints *) shapeObject;
                            if(![multiPolylinePoints isValid]){
                                [NSException raise:@"Not Valid" format:@"Multi Polyline Points is not valid to create %@", [WKBGeometryTypes name:mapShape.geometryType]];
                            }
                            if(![multiPolylinePoints isDeleted]){
                                NSMutableArray * multiPolylinePointsArray = [[NSMutableArray alloc] init];
                                for(GPKGPolylinePoints * polylinePoints in multiPolylinePoints.polylinePoints){
                                    if(![polylinePoints isDeleted]){
                                        [GPKGUtils addObject:polylinePoints.points toArray:multiPolylinePointsArray];
                                    }
                                }
                                switch(mapShape.geometryType){
                                    case WKB_MULTILINESTRING:
                                        geometry = [self toMultiLineStringWithMapPolylinesArray:multiPolylinePointsArray];
                                        break;
                                    case WKB_COMPOUNDCURVE:
                                        geometry = [self toCompoundCurveWithMapPolylinesArray:multiPolylinePointsArray];
                                        break;
                                    default:
                                        [NSException raise:@"Unhandled Geometry" format:@"Unhandled Geometry Type %@", [WKBGeometryTypes name:mapShape.geometryType]];
                                }
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [WKBGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
            }
            break;
        case WKB_MULTIPOLYGON:
            {
                switch(mapShape.shapeType){
                    case GPKG_MST_MULTI_POLYGON:
                        {
                            GPKGMultiPolygon * multiPolygon = (GPKGMultiPolygon *) shapeObject;
                            geometry = [self toMultiPolygonWithMapMultiPolygon:multiPolygon];
                        }
                        break;
                    case GPKG_MST_MULTI_POLYGON_POINTS:
                        {
                            GPKGMultiPolygonPoints * multiPolygonPoints = (GPKGMultiPolygonPoints *) shapeObject;
                            if(![multiPolygonPoints isValid]){
                                [NSException raise:@"Not Valid" format:@"Multi Polygon Points is not valid to create %@", [WKBGeometryTypes name:mapShape.geometryType]];
                            }
                            if(![multiPolygonPoints isDeleted]){
                                NSMutableArray * multiPolygonPointsArray = [[NSMutableArray alloc] init];
                                for(GPKGPolygonPoints * polygonPoints in multiPolygonPoints.polygonPoints){
                                    if(![polygonPoints isDeleted]){
                                        
                                        NSArray * multiPolygonPoints = polygonPoints.points;
                                        NSMutableArray * multiPolygonHolePoints = [[NSMutableArray alloc] init];
                                        for(GPKGPolygonHolePoints * hole in polygonPoints.holes){
                                            if(![hole isDeleted]){
                                                [GPKGUtils addObject:hole.points toArray:multiPolygonHolePoints];
                                            }
                                        }
                                        
                                        WKBPolygon * polygon = [self toPolygonWithMapPoints:multiPolygonPoints andHolePoints:multiPolygonHolePoints];
                                        [GPKGUtils addObject:polygon toArray:multiPolygonPointsArray];
                                    }
                                }
                                geometry = [self createMultiPolygonWithPolygons:multiPolygonPointsArray];
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [WKBGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
            }
            break;
        case WKB_POLYHEDRALSURFACE:
        case WKB_TIN:
        case WKB_TRIANGLE:
            [NSException raise:@"Unsupported GeoPackage Type" format:@"Unsupported GeoPackage type: %@", [WKBGeometryTypes name:mapShape.geometryType]];
            break;
        case WKB_GEOMETRYCOLLECTION:
            {
                NSArray * shapeArray = (NSArray *) mapShape.shape;
                WKBGeometryCollection * geometryCollection = [[WKBGeometryCollection alloc] initWithHasZ:false andHasM:false];
                for(GPKGMapShape * shapeArrayItem in shapeArray){
                    WKBGeometry * subGeometry = [self toGeometryFromMapShape:shapeArrayItem];
                    if(subGeometry != nil){
                        [geometryCollection addGeometry:subGeometry];
                    }
                }
                if(geometryCollection.numGeometries > 0){
                    geometry = geometryCollection;
                }
            }
            break;
        default:
            break;
    }
    
    return geometry;
}

@end
