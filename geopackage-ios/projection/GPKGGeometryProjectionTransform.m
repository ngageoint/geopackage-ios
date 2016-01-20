//
//  GPKGGeometryProjectionTransform.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGGeometryProjectionTransform.h"
#import "GPKGSLocationCoordinate3D.h"

@interface GPKGGeometryProjectionTransform()

@property (nonatomic, strong) GPKGProjectionTransform *transform;

@end

@implementation GPKGGeometryProjectionTransform

-(instancetype) initWithProjectionTransform: (GPKGProjectionTransform *) transform{
    self = [super init];
    if(self){
        self.transform = transform;
    }
    return self;
}

-(WKBGeometry *) transformGeometry: (WKBGeometry *) geometry{
    
    WKBGeometry * to = nil;
    
    enum WKBGeometryType geometryType = geometry.geometryType;
    switch(geometryType){
        case WKB_POINT:
            to = [self transformPoint:(WKBPoint *)geometry];
            break;
        case WKB_LINESTRING:
            to = [self transformLineString:(WKBLineString *)geometry];
            break;
        case WKB_POLYGON:
            to = [self transformPolygon:(WKBPolygon *)geometry];
            break;
        case WKB_MULTIPOINT:
            to = [self transformMultiPoint:(WKBMultiPoint *)geometry];
            break;
        case WKB_MULTILINESTRING:
            to = [self transformMultiLineString:(WKBMultiLineString *)geometry];
            break;
        case WKB_MULTIPOLYGON:
            to = [self transformMultiPolygon:(WKBMultiPolygon *)geometry];
            break;
        case WKB_CIRCULARSTRING:
            to = [self transformCircularString:(WKBCircularString *)geometry];
            break;
        case WKB_COMPOUNDCURVE:
            to = [self transformCompoundCurve:(WKBCompoundCurve *)geometry];
            break;
        case WKB_POLYHEDRALSURFACE:
            to = [self transformPolyhedralSurface:(WKBPolyhedralSurface *)geometry];
            break;
        case WKB_TIN:
            to = [self transformTIN:(WKBTIN *)geometry];
            break;
        case WKB_TRIANGLE:
            to = [self transformTriangle:(WKBTriangle *)geometry];
            break;
        case WKB_GEOMETRYCOLLECTION:
            to = [self transformGeometryCollection:(WKBGeometryCollection *)geometry];
            break;
        default:
            [NSException raise:@"Unsupported Geometry" format:@"Unsupported Geometry Type: %u", geometryType];
    }
    
    return to;
}

-(WKBPoint *) transformPoint: (WKBPoint *) point{
    
    CLLocationCoordinate2D fromCoord2d = CLLocationCoordinate2DMake([point.y doubleValue], [point.x doubleValue]);
    GPKGSLocationCoordinate3D * fromCoord = [[GPKGSLocationCoordinate3D alloc] initWithCoordinate:fromCoord2d];
    if(point.hasZ){
        [fromCoord setZ:point.z];
    }
    
    GPKGSLocationCoordinate3D * toCoord = [self.transform transform3d:fromCoord];
    
    NSDecimalNumber * x = [[NSDecimalNumber alloc] initWithDouble:toCoord.coordinate.longitude];
    NSDecimalNumber * y = [[NSDecimalNumber alloc] initWithDouble:toCoord.coordinate.latitude];
    WKBPoint * to = [[WKBPoint alloc] initWithHasZ:point.hasZ andHasM:point.hasM andX:x andY:y];
    
    if(point.hasZ){
        [to setZ:toCoord.z];
    }
    if(point.hasM){
        [to setM:point.m];
    }
    
    return to;
}

-(WKBLineString *) transformLineString: (WKBLineString *) lineString{
    
    WKBLineString * to = [[WKBLineString alloc] initWithHasZ:lineString.hasZ andHasM:lineString.hasM];
    
    for(WKBPoint * point in lineString.points){
        WKBPoint * toPoint = [self transformPoint:point];
        [to addPoint:toPoint];
    }
    
    return to;
}

-(WKBPolygon *) transformPolygon: (WKBPolygon *) polygon{
    
    WKBPolygon * to = [[WKBPolygon alloc] initWithHasZ:polygon.hasZ andHasM:polygon.hasM];
    
    for(WKBLineString * ring in polygon.rings){
        WKBLineString * toRing = [self transformLineString:ring];
        [to addRing:toRing];
    }
    
    return to;
}

-(WKBMultiPoint *) transformMultiPoint: (WKBMultiPoint *) multiPoint{

    WKBMultiPoint * to = [[WKBMultiPoint alloc] initWithHasZ:multiPoint.hasZ andHasM:multiPoint.hasM];
    
    for(WKBPoint * point in [multiPoint getPoints]){
        WKBPoint * toPoint = [self transformPoint:point];
        [to addPoint:toPoint];
    }
    
    return to;
}

-(WKBMultiLineString *) transformMultiLineString: (WKBMultiLineString *) multiLineString{

    WKBMultiLineString * to = [[WKBMultiLineString alloc] initWithHasZ:multiLineString.hasZ andHasM:multiLineString.hasM];
    
    for(WKBLineString * lineString in [multiLineString getLineStrings]){
        WKBLineString * toLineString = [self transformLineString:lineString];
        [to addLineString:toLineString];
    }
    
    return to;
}

-(WKBMultiPolygon *) transformMultiPolygon: (WKBMultiPolygon *) multiPolygon{
    
    WKBMultiPolygon * to = [[WKBMultiPolygon alloc] initWithHasZ:multiPolygon.hasZ andHasM:multiPolygon.hasM];
    
    for(WKBPolygon * polygon in [multiPolygon getPolygons]){
        WKBPolygon * toPolygon = [self transformPolygon:polygon];
        [to addPolygon:toPolygon];
    }
    
    return to;
}

-(WKBCircularString *) transformCircularString: (WKBCircularString *) circularString{
    
    WKBCircularString * to = [[WKBCircularString alloc] initWithHasZ:circularString.hasZ andHasM:circularString.hasM];
    
    for(WKBPoint * point in circularString.points){
        WKBPoint * toPoint = [self transformPoint:point];
        [to addPoint:toPoint];
    }
    
    return to;
}

-(WKBCompoundCurve *) transformCompoundCurve: (WKBCompoundCurve *) compoundCurve{
    
    WKBCompoundCurve * to = [[WKBCompoundCurve alloc] initWithHasZ:compoundCurve.hasZ andHasM:compoundCurve.hasM];
    
    for(WKBLineString * lineString in compoundCurve.lineStrings){
        WKBLineString * toLineString = [self transformLineString:lineString];
        [to addLineString:toLineString];
    }
    
    return to;
}

-(WKBPolyhedralSurface *) transformPolyhedralSurface: (WKBPolyhedralSurface *) polyhedralSurface{
    
    WKBPolyhedralSurface * to = [[WKBPolyhedralSurface alloc] initWithHasZ:polyhedralSurface.hasZ andHasM:polyhedralSurface.hasM];
    
    for(WKBPolygon * polygon in polyhedralSurface.polygons){
        WKBPolygon * toPolygon = [self transformPolygon:polygon];
        [to addPolygon:toPolygon];
    }
    
    return to;
}

-(WKBTIN *) transformTIN: (WKBTIN *) tin{
    
    WKBTIN * to = [[WKBTIN alloc] initWithHasZ:tin.hasZ andHasM:tin.hasM];
    
    for(WKBPolygon * polygon in tin.polygons){
        WKBPolygon * toPolygon = [self transformPolygon:polygon];
        [to addPolygon:toPolygon];
    }
    
    return to;
}

-(WKBTriangle *) transformTriangle: (WKBTriangle *) triangle{
    
    WKBTriangle * to = [[WKBTriangle alloc] initWithHasZ:triangle.hasZ andHasM:triangle.hasM];
    
    for(WKBLineString * ring in triangle.rings){
        WKBLineString * toRing = [self transformLineString:ring];
        [to addRing:toRing];
    }
    
    return to;
}

-(WKBGeometryCollection *) transformGeometryCollection: (WKBGeometryCollection *) geometryCollection{
    
    WKBGeometryCollection * to = [[WKBGeometryCollection alloc] initWithHasZ:geometryCollection.hasZ andHasM:geometryCollection.hasM];
    
    for(WKBGeometry * geometry in geometryCollection.geometries){
        WKBGeometry * toGeometry = [self transformGeometry:geometry];
        [to addGeometry:toGeometry];
    }

    return to;
}

@end
