//
//  GPKGMapShapeConverter.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGMapShapeConverter.h"
#import "GPKGMapPoint.h"
#import "SFPProjectionTransform.h"
#import "SFPProjectionConstants.h"
#import "GPKGUtils.h"
#import "GPKGPolygonOrientations.h"
#import "GPKGGeometryUtils.h"
#import "SFGeometryUtils.h"

@interface GPKGMapShapeConverter ()

@property (nonatomic, strong) SFPProjectionTransform *toWebMercator;
@property (nonatomic, strong) SFPProjectionTransform *toWgs84;
@property (nonatomic, strong) SFPProjectionTransform *fromWgs84;
@property (nonatomic, strong) SFPProjectionTransform *fromWebMercator;

@end

@implementation GPKGMapShapeConverter

-(instancetype) init{
    return [self initWithProjection:nil];
}

-(instancetype) initWithProjection: (SFPProjection *) projection{
    self = [super init];
    if(self != nil){
        self.projection = projection;
        if(projection != nil){
            self.toWebMercator = [[SFPProjectionTransform alloc] initWithFromProjection:projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
            SFPProjection * webMercator = self.toWebMercator.toProjection;
            self.toWgs84 =[[SFPProjectionTransform alloc] initWithFromProjection:webMercator andToEpsg:PROJ_EPSG_WORLD_GEODETIC_SYSTEM];
            SFPProjection * wgs84 = self.toWgs84.toProjection;
            self.fromWgs84 = [[SFPProjectionTransform alloc] initWithFromProjection:wgs84 andToProjection:webMercator];
            self.fromWebMercator = [[SFPProjectionTransform alloc] initWithFromProjection:webMercator andToProjection:projection];
        }
        self.exteriorOrientation = GPKG_PO_COUNTERCLOCKWISE;
        self.holeOrientation = GPKG_PO_CLOCKWISE;
        [self setDrawShortestDirection:YES];
    }
    return self;
}

-(void) setSimplifyToleranceAsDouble: (double) simplifyTolerance{
    self.simplifyTolerance = [[NSDecimalNumber alloc] initWithDouble:simplifyTolerance];
}

-(SFPoint *) toWgs84WithPoint: (SFPoint *) point{
    if(self.projection != nil){
        point = [self.toWebMercator transformWithPoint:point];
        point = [self.toWgs84 transformWithPoint:point];
    }
    return point;
}

-(SFPoint *) toProjectionWithPoint: (SFPoint *) point{
    if(self.projection != nil){
        point = [self.fromWgs84 transformWithPoint:point];
        point = [self.fromWebMercator transformWithPoint:point];
    }
    return point;
}

-(GPKGMapPoint *) toMapPointWithPoint: (SFPoint *) point{
    point = [self toWgs84WithPoint:point];
    GPKGMapPoint * mapPoint = [[GPKGMapPoint alloc] initWithPoint:point];
    return mapPoint;
}

-(MKMapPoint) toMKMapPointWithPoint: (SFPoint *) point{
    point = [self toWgs84WithPoint:point];
    
    double xValue = [point.x doubleValue];
    double adjustment = 0;
    if(xValue < -PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        adjustment = -MKMapSizeWorld.width;
        while(xValue < -PROJ_WGS84_HALF_WORLD_LON_WIDTH){
            xValue += (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
        }
    } else if(xValue > PROJ_WGS84_HALF_WORLD_LON_WIDTH){
        adjustment = MKMapSizeWorld.width;
        while(xValue > PROJ_WGS84_HALF_WORLD_LON_WIDTH){
            xValue -= (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
        }
    }
    
    MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake([point.y doubleValue], xValue));
    mapPoint.x += adjustment;
    
    return mapPoint;
}

-(SFPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint{
    return [self toPointWithMapPoint:mapPoint andHasZ:NO andHasM:NO];
}

-(SFPoint *) toPointWithMapPoint: (GPKGMapPoint *) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    double y = mapPoint.coordinate.latitude;
    double x = mapPoint.coordinate.longitude;
    SFPoint * point = [[SFPoint alloc] initWithHasZ:hasZ andHasM:hasM andX:[[NSDecimalNumber alloc] initWithDouble:x] andY:[[NSDecimalNumber alloc] initWithDouble:y]];
    point = [self toProjectionWithPoint:point];
    return point;
}

-(SFPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint{
    return [self toPointWithMKMapPoint:mapPoint andHasZ:NO andHasM:NO];
}

-(SFPoint *) toPointWithMKMapPoint: (MKMapPoint) mapPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
    double y = coord.latitude;
    double x = coord.longitude;
    SFPoint * point = [[SFPoint alloc] initWithHasZ:hasZ andHasM:hasM andX:[[NSDecimalNumber alloc] initWithDouble:x] andY:[[NSDecimalNumber alloc] initWithDouble:y]];
    point = [self toProjectionWithPoint:point];
    return point;
}

-(GPKGPolyline *) toMapPolylineWithLineString: (SFLineString *) lineString{
    
    lineString = [self shortestDirectionWithLineString:lineString];
    
    // Try to simplify the number of points in the line string
    NSArray *points = [self simplifyPoints:lineString.points];
    int numPoints = (int) points.count;
    
    MKMapPoint * mapPoints = malloc(sizeof(MKMapPoint)*numPoints);
    
    for(int i = 0; i < numPoints; i++){
        SFPoint * point = (SFPoint *)[points objectAtIndex:i];
        MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
        mapPoints[i] = mapPoint;
    }
    
    GPKGPolyline * polyline = [GPKGPolyline polylineWithPoints:mapPoints count:numPoints];
    
    return polyline;
}

-(SFLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline{
    return [self toLineStringWithMapPolyline:mapPolyline andHasZ:NO andHasM:NO];
}

-(SFLineString *) toLineStringWithMapPolyline: (MKPolyline *) mapPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return [self toLineStringWithMKMapPoints:mapPolyline.points andPointCount:mapPolyline.pointCount andHasZ:hasZ andHasM:hasM];
}

-(SFLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount{
    return [self toLineStringWithMKMapPoints:mapPoints andPointCount:pointCount andHasZ:NO andHasM:NO];
}

-(SFLineString *) toLineStringWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    SFLineString * lineString = [[SFLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    [self populateLineString:lineString withMKMapPoints:mapPoints andPointCount:pointCount];
    return lineString;
}

-(SFLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints{
    return [self toLineStringWithMapPoints:mapPoints andHasZ:NO andHasM:NO];
}

-(SFLineString *) toLineStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    SFLineString * lineString = [[SFLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    [self populateLineString:lineString withMapPoints:mapPoints];
    return lineString;
}

-(SFCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints{
    return [self toCircularStringWithMapPoints:mapPoints andHasZ:NO andHasM:NO];
}

-(SFCircularString *) toCircularStringWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    SFCircularString * circularString = [[SFCircularString alloc] initWithHasZ:hasZ andHasM:hasM];
    [self populateLineString:circularString withMapPoints:mapPoints];
    return circularString;
}

-(void) populateLineString: (SFLineString *) lineString withMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount{
    for(int i = 0; i < pointCount; i++){
        SFPoint * point = [self toPointWithMKMapPoint:mapPoints[i] andHasZ:lineString.hasZ andHasM:lineString.hasM];
        [lineString addPoint:point];
    }
}
     
-(void) populateLineString: (SFLineString *) lineString withMapPoints: (NSArray *) mapPoints{
    for(GPKGMapPoint * mapPoint in mapPoints){
        SFPoint * point = [self toPointWithMapPoint:mapPoint andHasZ:lineString.hasZ andHasM:lineString.hasM];
        [lineString addPoint:point];
    }
}

-(GPKGPolygon *) toMapPolygonWithPolygon: (SFPolygon *) polygon{
    
    GPKGPolygon * mapPolygon = nil;
    
    NSArray * rings = polygon.rings;
    
    if([rings count] > 0){
        
        // Create the polygon points
        SFLineString * polygonLineString = (SFLineString *)[rings objectAtIndex:0];
        polygonLineString = [self shortestDirectionWithLineString:polygonLineString];
        
        // Try to simplify the number of points in the polygon
        NSArray *points = [self simplifyPoints:polygonLineString.points];
        int numPoints = (int) points.count;
        
        MKMapPoint * polygonPoints = malloc(sizeof(MKMapPoint)*numPoints);
        
        for(int i = 0; i < numPoints; i++){
            SFPoint * point = (SFPoint *)[points objectAtIndex:i];
            MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
            polygonPoints[i] = mapPoint;
        }
        
        // Add the holes
        NSUInteger ringCount = [rings count];
        NSMutableArray * holes = [[NSMutableArray alloc] initWithCapacity:ringCount-1];
        for(int i = 1; i < ringCount; i++){
            SFLineString * hole = (SFLineString *)[rings objectAtIndex:i];
            hole = [self shortestDirectionWithLineString:hole];
            
            // Try to simplify the number of points in the hole
            NSArray *holePoints = [self simplifyPoints:hole.points];
            int numHolePoints = (int) holePoints.count;
            
            MKMapPoint * polygonHolePoints = malloc(sizeof(MKMapPoint)*numHolePoints);
            
            for(int j = 0; j < numHolePoints; j++){
                SFPoint * point = (SFPoint *)[holePoints objectAtIndex:j];
                MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
                polygonHolePoints[j] = mapPoint;
            }
            GPKGPolygon * holePolygon = [GPKGPolygon polygonWithPoints:polygonHolePoints count:numHolePoints];
            [holes addObject:holePolygon];
        }
        
        mapPolygon = [GPKGPolygon polygonWithPoints:polygonPoints count:numPoints interiorPolygons:holes];
    }
    return mapPolygon;
}

-(GPKGPolygon *) toMapCurvePolygonWithPolygon: (SFCurvePolygon *) curvePolygon{
    
    GPKGPolygon * mapPolygon = nil;
    
    NSArray * rings = curvePolygon.rings;
    
    if([rings count] > 0){
    
        MKMapPoint *polygonPoints;
        int numPoints = 0;
        
        // Add the polygon points
        NSObject *curve = (SFCurve *)[rings objectAtIndex:0];
        if([curve isKindOfClass:[SFCompoundCurve class]]){
            SFCompoundCurve *compoundCurve = (SFCompoundCurve *) curve;
            for(SFLineString *lineString in compoundCurve.lineStrings){
                numPoints += [lineString numPoints];
            }
            polygonPoints = malloc(sizeof(MKMapPoint) * numPoints);
            int index = 0;
            for(SFLineString *lineString in compoundCurve.lineStrings){
                SFLineString *compoundCurveLineString = [self shortestDirectionWithLineString:lineString];
                NSArray *compoundCurvePoints = [self simplifyPoints:compoundCurveLineString.points];
                for(SFPoint *point in compoundCurvePoints){
                    MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
                    polygonPoints[index++] = mapPoint;
                }
            }
        }else if([curve isKindOfClass:[SFLineString class]]){
            SFLineString *lineString = (SFLineString *)curve;
            lineString = [self shortestDirectionWithLineString:lineString];
            NSArray *points = [self simplifyPoints:lineString.points];
            numPoints = (int) points.count;
            polygonPoints = malloc(sizeof(MKMapPoint) * numPoints);
            for(int i = 0; i < numPoints; i++){
                SFPoint * point = (SFPoint *)[points objectAtIndex:i];
                MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
                polygonPoints[i] = mapPoint;
            }
        }else{
            [NSException raise:@"Unsupported Curve Type" format:@"Unsupported Curve Type: %@", NSStringFromClass([curve class])];
        }
        
        // Add the holes
        NSUInteger ringCount = [rings count];
        NSMutableArray * holes = [[NSMutableArray alloc] init];
        for(int i = 1; i < ringCount; i++){
            SFCurve *hole = (SFCurve *)[rings objectAtIndex:i];
            if([hole isKindOfClass:[SFCompoundCurve class]]){
                SFCompoundCurve *holeCompoundCurve = (SFCompoundCurve *) hole;
                int numHolePoints = 0;
                for(SFLineString *holeLineString in holeCompoundCurve.lineStrings){
                    numHolePoints += [holeLineString numPoints];
                }
                MKMapPoint * holePoints = malloc(sizeof(MKMapPoint)*numHolePoints);
                int index = 0;
                for(SFLineString *holeLineString in holeCompoundCurve.lineStrings){
                    SFLineString *compoundCurveHoleLineString = [self shortestDirectionWithLineString:holeLineString];
                    NSArray *compoundCurveHolePoints = [self simplifyPoints:compoundCurveHoleLineString.points];
                    for(SFPoint *point in compoundCurveHolePoints){
                        MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
                        holePoints[index++] = mapPoint;
                    }
                }
                GPKGPolygon * holePolygon = [GPKGPolygon polygonWithPoints:holePoints count:numHolePoints];
                [holes addObject:holePolygon];
            }else if([hole isKindOfClass:[SFLineString class]]){
                SFLineString *holeLineString = (SFLineString *)hole;
                holeLineString = [self shortestDirectionWithLineString:holeLineString];
                NSArray *holePoints = [self simplifyPoints:holeLineString.points];
                int numHolePoints = (int) holePoints.count;
                MKMapPoint * polygonHolePoints = malloc(sizeof(MKMapPoint)*numHolePoints);
                for(int j = 0; j < numHolePoints; j++){
                    SFPoint * point = (SFPoint *)[holePoints objectAtIndex:j];
                    MKMapPoint mapPoint = [self toMKMapPointWithPoint:point];
                    polygonHolePoints[j] = mapPoint;
                }
                GPKGPolygon * holePolygon = [GPKGPolygon polygonWithPoints:polygonHolePoints count:numHolePoints];
                [holes addObject:holePolygon];
            }else{
                [NSException raise:@"Unsupported Curve Hole Type" format:@"Unsupported Curve Hole Type: %@", NSStringFromClass([hole class])];
            }
        }

        mapPolygon = [GPKGPolygon polygonWithPoints:polygonPoints count:numPoints interiorPolygons:holes];
    }
    return mapPolygon;
}

-(SFPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon{
    return [self toPolygonWithMapPolygon:mapPolygon andHasZ:NO andHasM:NO];
}

-(SFPolygon *) toPolygonWithMapPolygon: (MKPolygon *) mapPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return [self toPolygonWithMKMapPoints:mapPolygon.points andPointCount:mapPolygon.pointCount andHolePolygons:mapPolygon.interiorPolygons andHasZ:hasZ andHasM:hasM];
}

-(SFPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes{
    return [self toPolygonWithMKMapPoints:mapPoints andPointCount:pointCount andHolePolygons:holes andHasZ:NO andHasM:NO];
}

-(SFPolygon *) toPolygonWithMKMapPoints: (MKMapPoint *) mapPoints andPointCount: (NSUInteger) pointCount andHolePolygons: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFPolygon * polygon = [[SFPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    // Add the polygon points
    NSMutableArray<SFPoint *> * polygonPoints = [[NSMutableArray alloc] init];
    for(int i = 0; i < pointCount; i++){
        MKMapPoint mapPoint = mapPoints[i];
        SFPoint * point = [self toPointWithMKMapPoint:mapPoint];
        [polygonPoints addObject:point];
    }
    
    // Add the exterior ring
    SFLineString * ring = [self buildPolygonRingWithPoints:polygonPoints andHasZ:hasZ andHasM:hasM];
    [polygon addRing:ring];
    
    // Add the holes
    if(holes != nil){
        for(MKPolygon * hole in holes){
            
            // Add the hole points
            NSMutableArray<SFPoint *> * holePoints = [[NSMutableArray alloc] init];
            for(int i = 0; i < hole.pointCount; i++){
                MKMapPoint mapPoint = hole.points[i];
                SFPoint * point = [self toPointWithMKMapPoint:mapPoint];
                [holePoints addObject:point];
            }
            
            // Add the hole ring
            SFLineString * holeRing = [self buildPolygonRingWithPoints:holePoints andHasZ:hasZ andHasM:hasM];
            [polygon addRing:holeRing];
        }
    }
    
    return polygon;
}

-(SFPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes{
    return [self toPolygonWithMapPoints:mapPoints andHolePoints:holes andHasZ:NO andHasM:NO];
}

-(SFPolygon *) toPolygonWithMapPoints: (NSArray *) mapPoints andHolePoints: (NSArray *) holes andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{

    SFPolygon * polygon = [[SFPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    // Add the polygon points
    NSMutableArray<SFPoint *> * polygonPoints = [[NSMutableArray alloc] init];
    for(GPKGMapPoint * mapPoint in mapPoints){
        SFPoint * point = [self toPointWithMapPoint:mapPoint];
        [polygonPoints addObject:point];
    }
    
    // Add the exterior ring
    SFLineString * ring = [self buildPolygonRingWithPoints:polygonPoints andHasZ:hasZ andHasM:hasM];
    [polygon addRing:ring];
    
    // Add the holes
    if(holes != nil){
        for(NSArray * hole in holes){
            
            NSMutableArray<SFPoint *> * holePoints = [[NSMutableArray alloc] init];
            for(GPKGMapPoint * mapPoint in hole){
                SFPoint * point = [self toPointWithMapPoint:mapPoint];
                [holePoints addObject:point];
            }
            
            // Add the hole ring
            SFLineString * holeRing = [self buildPolygonRingWithPoints:holePoints andHasZ:hasZ andHasM:hasM];
            [polygon addRing:holeRing];
        }
    }
    
    return polygon;
}

/**
 *  When the simplify tolerance is set, simplify the points to a similar curve with fewer points.
 *
 *  @param points ordered points
 *
 *  @return simplified points
 */
-(NSArray *) simplifyPoints: (NSArray *) points{
    
    NSArray *simplifiedPoints;
    if(self.simplifyTolerance != nil){
        
        // Reproject to web mercator if not in meters
        if(self.projection != nil && ![self.projection isUnit:SFP_UNIT_METERS]){
            points = [self.toWebMercator transformWithPoints:points];
        }
        
        // Simplify the points
        simplifiedPoints = [SFGeometryUtils simplifyPoints:points withTolerance:[self.simplifyTolerance doubleValue]];
        
        // Reproject back to the original projection
        if(self.projection != nil && ![self.projection isUnit:SFP_UNIT_METERS]){
            simplifiedPoints = [self.fromWebMercator transformWithPoints:simplifiedPoints];
        }
    }else{
        simplifiedPoints = points;
    }
    
    return simplifiedPoints;
}

-(SFLineString *) buildPolygonRingWithPoints: (NSMutableArray<SFPoint *> *) points andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    // Close the ring if needed and determine orientation
    [self closePolygonRingWithPoints: points];
    enum GPKGPolygonOrientation ringOrientation = [self orientationWithPoints: points];
    
    // Reverse the order as needed to match the desired orientation
    if(self.exteriorOrientation != GPKG_PO_UNSPECIFIED && self.exteriorOrientation != ringOrientation){
        points = (NSMutableArray<SFPoint *> *)[[points reverseObjectEnumerator] allObjects];
    }
    
    // Create the ring
    SFLineString * ring = [[SFLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    [ring setPoints:points];
    
    return ring;
}

-(void) closePolygonRingWithPoints: (NSMutableArray<SFPoint *> *) points{
    if(![GPKGGeometryUtils isClosedPolygonWithPoints:points]){
        SFPoint * first = [points objectAtIndex:0];
        [points addObject:[[SFPoint alloc] initWithX:first.x andY:first.y]];
    }
}

-(enum GPKGPolygonOrientation) orientationWithPoints: (NSMutableArray *) points{
    return [GPKGGeometryUtils computeSignedAreaOfDegreesPath:points] >= 0 ? GPKG_PO_COUNTERCLOCKWISE : GPKG_PO_CLOCKWISE;
}

-(SFLineString *) shortestDirectionWithLineString: (SFLineString *) lineString{
    
    SFLineString *shortest = nil;
    NSMutableArray *points = lineString.points;
    if(self.drawShortestDirection && points.count > 1){
        shortest = [[SFLineString alloc] init];
        
        SFPoint *previousPoint = [lineString.points objectAtIndex:0];
        [shortest addPoint:[[SFPoint alloc] initWithX:previousPoint.x andY:previousPoint.y]];
        
        for(int i = 1; i < points.count; i++){
            SFPoint *point = [lineString.points objectAtIndex:i];
            
            double x = [point.x doubleValue];
            double previousX = [previousPoint.x doubleValue];
            if(x < previousX){
                if(previousX - x > PROJ_WGS84_HALF_WORLD_LON_WIDTH){
                    x += (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
                }
            }else if(x > previousX){
                if(x - previousX > PROJ_WGS84_HALF_WORLD_LON_WIDTH){
                    x -= (2 * PROJ_WGS84_HALF_WORLD_LON_WIDTH);
                }
            }
            SFPoint *shortestPoint = [[SFPoint alloc] initWithXValue:x andYValue:[point.y doubleValue]];
            [shortest addPoint:shortestPoint];
            
            previousPoint = shortestPoint;
        }
    }else{
        shortest = lineString;
    }
    
    return shortest;
}

-(GPKGMultiPoint *) toMapMultiPointWithMultiPoint: (SFMultiPoint *) multiPoint{
    
    GPKGMultiPoint * mapMultiPoint = [[GPKGMultiPoint alloc] init];
    
    for(SFPoint * point in [multiPoint points]){
        GPKGMapPoint * mapPoint = [self toMapPointWithPoint:point];
        [mapMultiPoint addPoint:mapPoint];
    }
    
    return mapMultiPoint;
}

-(SFMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint{
    return [self toMultiPointWithMapMultiPoint:mapMultiPoint andHasZ:NO andHasM:NO];
}

-(SFMultiPoint *) toMultiPointWithMapMultiPoint: (GPKGMultiPoint *) mapMultiPoint andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    return [self toMultiPointWithMapPoints:mapMultiPoint.points andHasZ:hasZ andHasM:hasM];
}

-(SFMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints{
    return [self toMultiPointWithMapPoints:mapPoints andHasZ:NO andHasM:NO];
}

-(SFMultiPoint *) toMultiPointWithMapPoints: (NSArray *) mapPoints andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFMultiPoint * multiPoint = [[SFMultiPoint alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(GPKGMapPoint * mapPoint in mapPoints){
        SFPoint * point = [self toPointWithMapPoint:mapPoint];
        [multiPoint addPoint:point];
    }
    
    return multiPoint;
}

-(GPKGMultiPolyline *) toMapMultiPolylineWithMultiLineString: (SFMultiLineString *) multiLineString{
    
    GPKGMultiPolyline * mapMultiPoyline = [[GPKGMultiPolyline alloc] init];
    
    for(SFLineString * lineString in [multiLineString lineStrings]){
        GPKGPolyline * polyline = [self toMapPolylineWithLineString:lineString];
        [mapMultiPoyline addPolyline:polyline];
    }
    
    return mapMultiPoyline;
}

-(SFMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines{
    return [self toMultiLineStringWithMapPolylines:mapPolylines andHasZ:NO andHasM:NO];
}

-(SFMultiLineString *) toMultiLineStringWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFMultiLineString * multiLineString = [[SFMultiLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in mapPolylines){
        SFLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [multiLineString addLineString:lineString];
    }
    
    return multiLineString;
}

-(SFMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray{
    return [self toMultiLineStringWithMapPolylinesArray:mapPolylinesArray andHasZ:NO andHasM:NO];
}

-(SFMultiLineString *) toMultiLineStringWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{

    SFMultiLineString * multiLineString = [[SFMultiLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(NSArray * polyline in mapPolylinesArray){
        SFLineString * lineString = [self toLineStringWithMapPoints:polyline];
        [multiLineString addLineString:lineString];
    }
    
    return multiLineString;
}

-(SFCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray{
    return [self toCompoundCurveWithMapPolylinesArray:mapPolylinesArray andHasZ:NO andHasM:NO];
}

-(SFCompoundCurve *) toCompoundCurveWithMapPolylinesArray: (NSArray *) mapPolylinesArray andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{

    SFCompoundCurve * compoundCurve = [[SFCompoundCurve alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(NSArray * polyline in mapPolylinesArray){
        SFLineString * lineString = [self toLineStringWithMapPoints:polyline];
        [compoundCurve addLineString:lineString];
    }
    
    return compoundCurve;
}

-(SFMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline{
    return [self toMultiLineStringWithMapMultiPolyline:multiPolyline andHasZ:NO andHasM:NO];
}

-(SFMultiLineString *) toMultiLineStringWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFMultiLineString * multiLineString = [[SFMultiLineString alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in multiPolyline.polylines){
        SFLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [multiLineString addLineString:lineString];
    }
    
    return multiLineString;
}

-(SFCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline{
    return [self toCompoundCurveWithMapMultiPolyline:multiPolyline andHasZ:NO andHasM:NO];
}

-(SFCompoundCurve *) toCompoundCurveWithMapMultiPolyline: (GPKGMultiPolyline *) multiPolyline andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFCompoundCurve * compoundCurve = [[SFCompoundCurve alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in multiPolyline.polylines){
        SFLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [compoundCurve addLineString:lineString];
    }
    
    return compoundCurve;
}

-(GPKGMultiPolygon *) toMapMultiPolygonWithMultiPolygon: (SFMultiPolygon *) multiPolygon{
    
    GPKGMultiPolygon * mapMultiPolygon = [[GPKGMultiPolygon alloc] init];
    
    for(SFPolygon * polygon in [multiPolygon polygons]){
        GPKGPolygon * mapPolygon = [self toMapPolygonWithPolygon:polygon];
        [mapMultiPolygon addPolygon:mapPolygon];
    }
    
    return mapMultiPolygon;
}

-(SFMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons{
    return [self toMultiPolygonWithMapPolygons:mapPolygons andHasZ:NO andHasM:NO];
}

-(SFMultiPolygon *) toMultiPolygonWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFMultiPolygon * multiPolygon = [[SFMultiPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolygon * mapPolygon in mapPolygons){
        SFPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(SFMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons{
    return [self createMultiPolygonWithPolygons:polygons andHasZ:NO andHasM:NO];
}

-(SFMultiPolygon *) createMultiPolygonWithPolygons: (NSArray *) polygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFMultiPolygon * multiPolygon = [[SFMultiPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(SFPolygon * polygon in polygons){
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(SFMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon{
    return [self toMultiPolygonWithMapMultiPolygon:mapMultiPolygon andHasZ:NO andHasM:NO];
}

-(SFMultiPolygon *) toMultiPolygonWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFMultiPolygon * multiPolygon = [[SFMultiPolygon alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolygon * mapPolygon in mapMultiPolygon.polygons){
        SFPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [multiPolygon addPolygon:polygon];
    }
    
    return multiPolygon;
}

-(GPKGMultiPolyline *) toMapMultiPolylineWithCompoundCurve: (SFCompoundCurve *) compoundCurve{
    
    GPKGMultiPolyline * mapMultiPolyline = [[GPKGMultiPolyline alloc] init];
    
    for(SFLineString * lineString in compoundCurve.lineStrings){
        GPKGPolyline * mapPolyline = [self toMapPolylineWithLineString:lineString];
        [mapMultiPolyline addPolyline:mapPolyline];
    }
    
    return mapMultiPolyline;
}

-(SFCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines{
    return [self toCompoundCurveWithMapPolylines:mapPolylines andHasZ:NO andHasM:NO];
}

-(SFCompoundCurve *) toCompoundCurveWithMapPolylines: (NSArray *) mapPolylines andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFCompoundCurve * compoundCurve = [[SFCompoundCurve alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for(MKPolyline * mapPolyline in mapPolylines){
        SFLineString * lineString = [self toLineStringWithMapPolyline:mapPolyline];
        [compoundCurve addLineString:lineString];
    }
    
    return compoundCurve;
}

-(GPKGMultiPolygon *) toMapMultiPolygonWithPolyhedralSurface: (SFPolyhedralSurface *) polyhedralSurface{
    
    GPKGMultiPolygon * mapMultiPolygon = [[GPKGMultiPolygon alloc] init];
    
    for(SFPolygon * polygon in polyhedralSurface.polygons){
        GPKGPolygon * mapPolygon = [self toMapPolygonWithPolygon:polygon];
        [mapMultiPolygon addPolygon:mapPolygon];
    }
    
    return mapMultiPolygon;
}

-(SFPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons{
    return [self toPolyhedralSurfaceWithMapPolygons:mapPolygons andHasZ:NO andHasM:NO];
}

-(SFPolyhedralSurface *) toPolyhedralSurfaceWithMapPolygons: (NSArray *) mapPolygons andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFPolyhedralSurface * polyhedralSurface = [[SFPolyhedralSurface alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for (MKPolygon * mapPolygon in mapPolygons) {
        SFPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [polyhedralSurface addPolygon:polygon];
    }
    
    return polyhedralSurface;
}

-(SFPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon{
    return [self toPolyhedralSurfaceWithMapMultiPolygon:mapMultiPolygon andHasZ:NO andHasM:NO];
}

-(SFPolyhedralSurface *) toPolyhedralSurfaceWithMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon andHasZ: (BOOL) hasZ andHasM: (BOOL) hasM{
    
    SFPolyhedralSurface * polyhedralSurface = [[SFPolyhedralSurface alloc] initWithHasZ:hasZ andHasM:hasM];
    
    for (MKPolygon * mapPolygon in mapMultiPolygon.polygons) {
        SFPolygon * polygon = [self toPolygonWithMapPolygon:mapPolygon];
        [polyhedralSurface addPolygon:polygon];
    }
    
    return polyhedralSurface;
}

-(GPKGMapShape *) toShapeWithGeometry: (SFGeometry *) geometry{
    
    GPKGMapShape * shape = nil;
    
    enum SFGeometryType geometryType = geometry.geometryType;
    switch (geometryType) {
        case SF_POINT:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POINT andShape:[self toMapPointWithPoint:(SFPoint *) geometry]];
            break;
        case SF_LINESTRING:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[self toMapPolylineWithLineString:(SFLineString *) geometry]];
            break;
        case SF_POLYGON:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[self toMapPolygonWithPolygon:(SFPolygon *) geometry]];
            break;
        case SF_MULTIPOINT:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POINT andShape:[self toMapMultiPointWithMultiPoint:(SFMultiPoint *) geometry]];
            break;
        case SF_MULTILINESTRING:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[self toMapMultiPolylineWithMultiLineString:(SFMultiLineString *) geometry]];
            break;
        case SF_MULTIPOLYGON:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self toMapMultiPolygonWithMultiPolygon:(SFMultiPolygon *) geometry]];
            break;
        case SF_CIRCULARSTRING:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[self toMapPolylineWithLineString:(SFCircularString *) geometry]];
            break;
        case SF_COMPOUNDCURVE:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[self toMapMultiPolylineWithCompoundCurve:(SFCompoundCurve *) geometry]];
            break;
        case SF_CURVEPOLYGON:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[self toMapCurvePolygonWithPolygon:(SFCurvePolygon *) geometry]];
            break;
        case SF_POLYHEDRALSURFACE:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self toMapMultiPolygonWithPolyhedralSurface:(SFPolyhedralSurface *) geometry]];
            break;
        case SF_TIN:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[self toMapMultiPolygonWithPolyhedralSurface:(SFTIN *) geometry]];
            break;
        case SF_TRIANGLE:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[self toMapPolygonWithPolygon:(SFTriangle *) geometry]];
            break;
        case SF_GEOMETRYCOLLECTION:
            shape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_COLLECTION andShape:[self toShapesWithGeometryCollection:(SFGeometryCollection *) geometry]];
            break;
        default:
            [NSException raise:@"Unsupported Geometry" format:@"Unsupported Geometry Type: %@", [SFGeometryTypes name:geometryType]];
    }
    
    return shape;
}

-(NSArray *) toShapesWithGeometryCollection: (SFGeometryCollection *) geometryCollection{
    
    NSMutableArray * shapes = [[NSMutableArray alloc] init];
    
    for(SFGeometry * geometry in geometryCollection.geometries){
        GPKGMapShape * shape = [self toShapeWithGeometry:geometry];
        [GPKGUtils addObject:shape toArray:shapes];
    }
    
    return shapes;
}

-(GPKGMapShape *) addGeometry: (SFGeometry *) geometry toMapView: (MKMapView *) mapView{
    
    GPKGMapShape * addedShape = nil;
    
    enum SFGeometryType geometryType = geometry.geometryType;
    switch (geometryType) {
        case SF_POINT:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POINT andShape:[GPKGMapShapeConverter addMapPoint:[self toMapPointWithPoint:(SFPoint *) geometry] toMapView:mapView]];
            break;
        case SF_LINESTRING:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[GPKGMapShapeConverter addMapPolyline:[self toMapPolylineWithLineString:(SFLineString *) geometry] toMapView:mapView]];
            break;
        case SF_POLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[GPKGMapShapeConverter addMapPolygon:[self toMapPolygonWithPolygon:(SFPolygon *) geometry] toMapView:mapView]];
            break;
        case SF_MULTIPOINT:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POINT andShape:[GPKGMapShapeConverter addMapMultiPoint:[self toMapMultiPointWithMultiPoint:(SFMultiPoint *) geometry]toMapView:mapView]];
            break;
        case SF_MULTILINESTRING:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[GPKGMapShapeConverter addMapMultiPolyline:[self toMapMultiPolylineWithMultiLineString:(SFMultiLineString *) geometry]toMapView:mapView]];
            break;
        case SF_MULTIPOLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[GPKGMapShapeConverter addMapMultiPolygon:[self toMapMultiPolygonWithMultiPolygon:(SFMultiPolygon *) geometry]toMapView:mapView]];
            break;
        case SF_CIRCULARSTRING:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYLINE andShape:[GPKGMapShapeConverter addMapPolyline:[self toMapPolylineWithLineString:(SFCircularString *) geometry]toMapView:mapView]];
            break;
        case SF_COMPOUNDCURVE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYLINE andShape:[GPKGMapShapeConverter addMapMultiPolyline:[self toMapMultiPolylineWithCompoundCurve:(SFCompoundCurve *) geometry]toMapView:mapView]];
            break;
        case SF_CURVEPOLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[GPKGMapShapeConverter addMapPolygon:[self toMapCurvePolygonWithPolygon:(SFCurvePolygon *) geometry] toMapView:mapView]];
            break;
        case SF_POLYHEDRALSURFACE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[GPKGMapShapeConverter addMapMultiPolygon:[self toMapMultiPolygonWithPolyhedralSurface:(SFPolyhedralSurface *) geometry]toMapView:mapView]];
            break;
        case SF_TIN:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_MULTI_POLYGON andShape:[GPKGMapShapeConverter addMapMultiPolygon:[self toMapMultiPolygonWithPolyhedralSurface:(SFTIN *) geometry]toMapView:mapView]];
            break;
        case SF_TRIANGLE:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_POLYGON andShape:[GPKGMapShapeConverter addMapPolygon:[self toMapPolygonWithPolygon:(SFTriangle *) geometry]toMapView:mapView]];
            break;
        case SF_GEOMETRYCOLLECTION:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:geometryType andShapeType:GPKG_MST_COLLECTION andShape:[self addGeometryCollection:(SFGeometryCollection *) geometry toMapView:mapView]];
            break;
        default:
            [NSException raise:@"Unsupported Geometry" format:@"Unsupported Geometry Type: %@", [SFGeometryTypes name:geometryType]];
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
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYLINE andShape:[self addMapPolyline:(GPKGPolyline *) mapShape.shape toMapView:mapView]];
            break;
        case GPKG_MST_POLYGON:
            addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYGON andShape:[self addMapPolygon:(GPKGPolygon *) mapShape.shape toMapView:mapView]];
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
        mapPoint.options = [pointOptions mutableCopy];
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

+(GPKGPolyline *) addMapPolyline: (GPKGPolyline *) mapPolyline toMapView: (MKMapView *) mapView{
    [mapView addOverlay:mapPolyline];
    return mapPolyline;
}

+(GPKGPolygon *) addMapPolygon: (GPKGPolygon *) mapPolylgon toMapView: (MKMapView *) mapView{
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
    for(GPKGPolyline * polyline in mapMultiPolyline.polylines){
        [self addMapPolyline:polyline toMapView:mapView];
    }
    return mapMultiPolyline;
}

+(GPKGMultiPolygon *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon toMapView: (MKMapView *) mapView{
    for(GPKGPolygon * polygon in mapMultiPolygon.polygons){
        [self addMapPolygon:polygon toMapView:mapView];
    }
    return mapMultiPolygon;
}

-(NSArray *) addGeometryCollection: (SFGeometryCollection *) geometryCollection toMapView: (MKMapView *) mapView{
    
    NSMutableArray * shapes = [[NSMutableArray alloc] init];
    
    for(SFGeometry * geometry in geometryCollection.geometries){
        GPKGMapShape * shape = [self addGeometry:geometry toMapView:mapView];
        [GPKGUtils addObject:shape toArray:shapes];
    }
    
    return shapes;
}

-(GPKGMapShapePoints *) addMapShape: (GPKGMapShape *) mapShape asPointsToMapView: (MKMapView *) mapView withPointOptions: (GPKGMapPointOptions *) pointOptions andPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions andPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions andPolylineOptions: (GPKGPolylineOptions *) globalPolylineOptions andPolygonOptions: (GPKGPolygonOptions *) globalPolygonOptions{
    
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
                GPKGPolylinePoints * polylinePoints = [self addMapPolyline:(GPKGPolyline *) mapShape.shape asPointsToMapView:mapView withPolylinePointOptions:polylinePointOptions andPolylineOptions:globalPolylineOptions];
                [shapePoints addShapePoints:polylinePoints];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_POLYLINE_POINTS andShape:polylinePoints];
            }
            break;
        case GPKG_MST_POLYGON:
            {
                GPKGPolygonPoints * polygonPoints = [self addMapPolygon:(GPKGPolygon *) mapShape.shape asPointsToMapView:mapView withShapePoints:shapePoints withPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions andPolygonOptions:globalPolygonOptions];
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
                GPKGMultiPolylinePoints * multiPolylinePoints = [self addMapMultiPolyline:(GPKGMultiPolyline *)mapShape.shape asPointsToMapView:mapView withShapePoints:shapePoints withPolylinePointOptions:polylinePointOptions andPolylineOptions:globalPolylineOptions];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POLYLINE_POINTS andShape:multiPolylinePoints];
            }
            break;
        case GPKG_MST_MULTI_POLYGON:
            {
                GPKGMultiPolygonPoints * multiPolygonPoints = [self addMapMultiPolygon:(GPKGMultiPolygon *)mapShape.shape asPointsToMapView:mapView withShapePoints:shapePoints withPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions andPolygonOptions:globalPolygonOptions];
                addedShape = [[GPKGMapShape alloc] initWithGeometryType:mapShape.geometryType andShapeType:GPKG_MST_MULTI_POLYGON_POINTS andShape:multiPolygonPoints];
            }
            break;
        case GPKG_MST_COLLECTION:
            {
                NSMutableArray * addedShapeArray = [[NSMutableArray alloc] init];
                NSArray * shapeArray = (NSArray *) mapShape.shape;
                for(GPKGMapShape * shapeArrayItem in shapeArray){
                    GPKGMapShapePoints * shapeArrayItemPoints = [self addMapShape:shapeArrayItem asPointsToMapView:mapView withPointOptions:pointOptions andPolylinePointOptions:polylinePointOptions andPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions andPolylineOptions:globalPolylineOptions andPolygonOptions:globalPolygonOptions];
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
        
        if(points.count > 1 && i + 1 == pointCount && ignoreIdenticalEnds){
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

-(GPKGPolylinePoints *) addMapPolyline: (GPKGPolyline *) mapPolyline asPointsToMapView: (MKMapView *) mapView withPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions andPolylineOptions: (GPKGPolylineOptions *) globalPolylineOptions{
    
    GPKGPolylinePoints * polylinePoints = [[GPKGPolylinePoints alloc] init];
    
    if(globalPolylineOptions != nil){
        GPKGPolylineOptions *options = [[GPKGPolylineOptions alloc] init];
        [options setStrokeColor:globalPolylineOptions.strokeColor];
        [options setLineWidth:globalPolylineOptions.lineWidth];
        [mapPolyline setOptions:options];
    }
    
    GPKGPolyline * polyline = [GPKGMapShapeConverter addMapPolyline:mapPolyline toMapView:mapView];
    [polylinePoints setPolyline:polyline];
    
    NSMutableArray * points = [self addMKMapPoints:polyline.points withPointCount:polyline.pointCount asPointsToMapView:mapView withPointOptions:polylinePointOptions andIgnoreIdenticalEnds:NO];
    [polylinePoints setPoints:points];
    
    return polylinePoints;
}

-(GPKGPolygonPoints *) addMapPolygon: (GPKGPolygon *) mapPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions andPolygonOptions: (GPKGPolygonOptions *) globalPolygonOptions{
    
    GPKGPolygonPoints * polygonPoints = [[GPKGPolygonPoints alloc] init];
    
    if(globalPolygonOptions != nil){
        GPKGPolygonOptions *options = [[GPKGPolygonOptions alloc] init];
        [options setStrokeColor:globalPolygonOptions.strokeColor];
        [options setLineWidth:globalPolygonOptions.lineWidth];
        [options setFillColor:globalPolygonOptions.fillColor];
        [mapPolygon setOptions:options];
    }
    
    GPKGPolygon * polygon = [GPKGMapShapeConverter addMapPolygon:mapPolygon toMapView:mapView];
    [polygonPoints setPolygon:polygon];
    
    NSMutableArray * points = [self addMKMapPoints:polygon.points withPointCount:polygon.pointCount asPointsToMapView:mapView withPointOptions:polygonPointOptions andIgnoreIdenticalEnds:YES];
    [polygonPoints setPoints:points];
    
    for(MKPolygon * hole in polygon.interiorPolygons){
        NSMutableArray * holePoints = [self addMKMapPoints:hole.points withPointCount:hole.pointCount asPointsToMapView:mapView withPointOptions:polygonHolePointOptions andIgnoreIdenticalEnds:YES];
        GPKGPolygonHolePoints * polygonHolePoints = [[GPKGPolygonHolePoints alloc] initWithPolygonPoints:polygonPoints];
        [polygonHolePoints setPoints:holePoints];
        [shapePoints addShapePoints:polygonHolePoints];
        [polygonPoints addHole:polygonHolePoints];
    }
    
    return polygonPoints;
}

-(GPKGMultiPolylinePoints *) addMapMultiPolyline: (GPKGMultiPolyline *) mapMultiPolyline asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolylinePointOptions: (GPKGMapPointOptions *) polylinePointOptions andPolylineOptions: (GPKGPolylineOptions *) globalPolylineOptions{
    
    GPKGMultiPolylinePoints * multiPolylinePoints = [[GPKGMultiPolylinePoints alloc] init];
    for(GPKGPolyline * polyline in mapMultiPolyline.polylines){
        GPKGPolylinePoints * polylinePoints = [self addMapPolyline:polyline asPointsToMapView:mapView withPolylinePointOptions:polylinePointOptions andPolylineOptions:globalPolylineOptions];
        [shapePoints addShapePoints:polylinePoints];
        [multiPolylinePoints addPolylinePoints:polylinePoints];
    }
    return multiPolylinePoints;
}

-(GPKGMultiPolygonPoints *) addMapMultiPolygon: (GPKGMultiPolygon *) mapMultiPolygon asPointsToMapView: (MKMapView *) mapView withShapePoints: (GPKGMapShapePoints *) shapePoints withPolygonPointOptions: (GPKGMapPointOptions *) polygonPointOptions andPolygonPointHoleOptions: (GPKGMapPointOptions *) polygonHolePointOptions andPolygonOptions: (GPKGPolygonOptions *) globalPolygonOptions{

    GPKGMultiPolygonPoints * multiPolygonPoints = [[GPKGMultiPolygonPoints alloc] init];
    for(GPKGPolygon * polygon in mapMultiPolygon.polygons){
        GPKGPolygonPoints * polygonPoints = [self addMapPolygon:polygon asPointsToMapView:mapView withShapePoints:shapePoints withPolygonPointOptions:polygonPointOptions andPolygonPointHoleOptions:polygonHolePointOptions andPolygonOptions:globalPolygonOptions];
        [shapePoints addShapePoints:polygonPoints];
        [multiPolygonPoints addPolygonPoints:polygonPoints];
    }
    return multiPolygonPoints;
}

+(CLLocationCoordinate2D *) locationCoordinatesFromPoints: (NSArray *) points{
    CLLocationCoordinate2D *coordinates = calloc([points count], sizeof(CLLocationCoordinate2D));
    int index = 0;
    for(GPKGMapPoint * point in points){
        coordinates[index++] = point.coordinate;
    }
    return coordinates;
}

+(CLLocationCoordinate2D *) locationCoordinatesFromLocations: (NSArray *) locations{
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

-(SFGeometry *) toGeometryFromMapShape: (GPKGMapShape *) mapShape{
    
    SFGeometry * geometry = nil;
    NSObject * shapeObject = mapShape.shape;
    
    switch(mapShape.geometryType){

        case SF_POINT:
            {
                GPKGMapPoint * point = nil;
                switch(mapShape.shapeType){
                    case GPKG_MST_POINT:
                        point = (GPKGMapPoint *) shapeObject;
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [SFGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(point != nil){
                    geometry = [self toPointWithMapPoint:point];
                }
                
            }
            break;
        case SF_LINESTRING:
        case SF_CIRCULARSTRING:
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
                                [NSException raise:@"Not Valid" format:@"Polyline Points is not valid to create %@", [SFGeometryTypes name:mapShape.geometryType]];
                            }
                            if(![polylinePoints isDeleted]){
                                lineStringPoints = polylinePoints.points;
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [SFGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(lineStringPoints != nil){
                    switch(mapShape.geometryType){
                        case SF_LINESTRING:
                            geometry = [self toLineStringWithMapPoints:lineStringPoints];
                            break;
                        case SF_CIRCULARSTRING:
                            geometry = [self toCircularStringWithMapPoints:lineStringPoints];
                            break;
                        default:
                            [NSException raise:@"Unhandled Geometry" format:@"Unhandled Geometry Type %@", [SFGeometryTypes name:mapShape.geometryType]];
                    }
                }
            }
            break;
        case SF_POLYGON:
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
                                [NSException raise:@"Not Valid" format:@"Polygon Points is not valid to create %@", [SFGeometryTypes name:mapShape.geometryType]];
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
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [SFGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(polygonPoints != nil){
                    geometry = [self toPolygonWithMapPoints:polygonPoints andHolePoints:holePointArray];
                }
            }
            break;
        case SF_MULTIPOINT:
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
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [SFGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
                if(multiPoints != nil){
                    geometry = [self toMultiPointWithMapPoints:multiPoints];
                }
            }
            break;
        case SF_MULTILINESTRING:
        case SF_COMPOUNDCURVE:
            {
                switch(mapShape.shapeType){
                    case GPKG_MST_MULTI_POLYLINE:
                        {
                            GPKGMultiPolyline * multiPolyline = (GPKGMultiPolyline *) shapeObject;
                            switch(mapShape.geometryType){
                                case SF_MULTILINESTRING:
                                    geometry = [self toMultiLineStringWithMapMultiPolyline:multiPolyline];
                                    break;
                                case SF_COMPOUNDCURVE:
                                    geometry = [self toCompoundCurveWithMapMultiPolyline:multiPolyline];
                                    break;
                                default:
                                    [NSException raise:@"Unhandled Geometry" format:@"Unhandled Geometry Type %@", [SFGeometryTypes name:mapShape.geometryType]];
                            }
                        }
                        break;
                    case GPKG_MST_MULTI_POLYLINE_POINTS:
                        {
                            GPKGMultiPolylinePoints * multiPolylinePoints = (GPKGMultiPolylinePoints *) shapeObject;
                            if(![multiPolylinePoints isValid]){
                                [NSException raise:@"Not Valid" format:@"Multi Polyline Points is not valid to create %@", [SFGeometryTypes name:mapShape.geometryType]];
                            }
                            if(![multiPolylinePoints isDeleted]){
                                NSMutableArray * multiPolylinePointsArray = [[NSMutableArray alloc] init];
                                for(GPKGPolylinePoints * polylinePoints in multiPolylinePoints.polylinePoints){
                                    if(![polylinePoints isDeleted]){
                                        [GPKGUtils addObject:polylinePoints.points toArray:multiPolylinePointsArray];
                                    }
                                }
                                switch(mapShape.geometryType){
                                    case SF_MULTILINESTRING:
                                        geometry = [self toMultiLineStringWithMapPolylinesArray:multiPolylinePointsArray];
                                        break;
                                    case SF_COMPOUNDCURVE:
                                        geometry = [self toCompoundCurveWithMapPolylinesArray:multiPolylinePointsArray];
                                        break;
                                    default:
                                        [NSException raise:@"Unhandled Geometry" format:@"Unhandled Geometry Type %@", [SFGeometryTypes name:mapShape.geometryType]];
                                }
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [SFGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
            }
            break;
        case SF_MULTIPOLYGON:
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
                                [NSException raise:@"Not Valid" format:@"Multi Polygon Points is not valid to create %@", [SFGeometryTypes name:mapShape.geometryType]];
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
                                        
                                        SFPolygon * polygon = [self toPolygonWithMapPoints:multiPolygonPoints andHolePoints:multiPolygonHolePoints];
                                        [GPKGUtils addObject:polygon toArray:multiPolygonPointsArray];
                                    }
                                }
                                geometry = [self createMultiPolygonWithPolygons:multiPolygonPointsArray];
                            }
                        }
                        break;
                    default:
                        [NSException raise:@"Invalid Shape" format:@"Not a valid %@ shape type: %@", [SFGeometryTypes name:mapShape.geometryType], [GPKGMapShapeTypes name:mapShape.shapeType]];
                }
            }
            break;
        case SF_POLYHEDRALSURFACE:
        case SF_TIN:
        case SF_TRIANGLE:
            [NSException raise:@"Unsupported GeoPackage Type" format:@"Unsupported GeoPackage type: %@", [SFGeometryTypes name:mapShape.geometryType]];
            break;
        case SF_GEOMETRYCOLLECTION:
            {
                NSArray * shapeArray = (NSArray *) mapShape.shape;
                SFGeometryCollection * geometryCollection = [[SFGeometryCollection alloc] initWithHasZ:NO andHasM:NO];
                for(GPKGMapShape * shapeArrayItem in shapeArray){
                    SFGeometry * subGeometry = [self toGeometryFromMapShape:shapeArrayItem];
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

-(GPKGBoundingBox *) boundingBoxToWebMercator: (GPKGBoundingBox *) boundingBox{
    if(self.projection == nil){
        [NSException raise:@"Nil Projection" format:@"Shape Converter projection is nil"];
    }
    return [boundingBox transform:self.toWebMercator];
}

-(GPKGBoundingBox *) boundingBoxToWgs84: (GPKGBoundingBox *) boundingBox{
    if(self.projection == nil){
        [NSException raise:@"Nil Projection" format:@"Shape Converter projection is nil"];
    }
    return [boundingBox transform:self.toWgs84];
}

-(GPKGBoundingBox *) boundingBoxFromWebMercator: (GPKGBoundingBox *) boundingBox{
    if(self.projection == nil){
        [NSException raise:@"Nil Projection" format:@"Shape Converter projection is nil"];
    }
    return [boundingBox transform:self.fromWebMercator];
}

-(GPKGBoundingBox *) boundingBoxFromWgs84: (GPKGBoundingBox *) boundingBox{
    if(self.projection == nil){
        [NSException raise:@"Nil Projection" format:@"Shape Converter projection is nil"];
    }
    return [boundingBox transform:self.fromWgs84];
}

@end
