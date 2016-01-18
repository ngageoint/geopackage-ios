//
//  GPKGProjectionTransform.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionTransform.h"
#import "GPKGUtils.h"
#import "GPKGProjectionFactory.h"
#import "GPKGGeometryProjectionTransform.h"

@implementation GPKGProjectionTransform

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToProjection: (GPKGProjection *) toProjection{
    self = [super init];
    if(self != nil){
        self.fromProjection = fromProjection;
        self.toProjection = toProjection;
    }
    return self;
}

-(instancetype) initWithFromEpsg: (int) fromEpsg andToEpsg: (int) toEpsg{
    
    GPKGProjection * fromProjection = [GPKGProjectionFactory getProjectionWithInt:fromEpsg];
    GPKGProjection * toProjection = [GPKGProjectionFactory getProjectionWithInt:toEpsg];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToEpsg: (int) toEpsg{
    
    GPKGProjection * toProjection = [GPKGProjectionFactory getProjectionWithInt:toEpsg];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromEpsg: (int) fromEpsg andToProjection: (GPKGProjection *) toProjection{
    
    GPKGProjection * fromProjection = [GPKGProjectionFactory getProjectionWithInt:fromEpsg];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(CLLocationCoordinate2D) transform: (CLLocationCoordinate2D) from{
    GPKGSLocationCoordinate3D * result = [self transform3d:[[GPKGSLocationCoordinate3D alloc] initWithCoordinate:from]];
    return result.coordinate;
}

-(GPKGSLocationCoordinate3D *) transform3d: (GPKGSLocationCoordinate3D *) from{
    
    CLLocationCoordinate2D to = CLLocationCoordinate2DMake(from.coordinate.latitude, from.coordinate.longitude);
    
    if(self.fromProjection.isLatLong){
        to.latitude *= DEG_TO_RAD;
        to.longitude *= DEG_TO_RAD;
    }
    
    double zValue = 0;
    BOOL hasZ = [from hasZ];
    if(hasZ){
        zValue = [from.z doubleValue];
    }
    
    int value = pj_transform(self.fromProjection.crs, self.toProjection.crs, 1, 0, &to.longitude, &to.latitude, hasZ ? &zValue : NULL);
    
    if(value != 0){
        [NSException raise:@"Transform Error" format:@"Failed to transform EPSG %@ latitude: %f and longitude: %f to EPSG %@, Error: %d", self.fromProjection.epsg, from.coordinate.latitude, from.coordinate.longitude, self.toProjection.epsg, value];
    }
    
    if(self.toProjection.isLatLong){
        to.latitude *= RAD_TO_DEG;
        to.longitude *= RAD_TO_DEG;
    }
    
    NSDecimalNumber * toZ = nil;
    if(hasZ){
        toZ = [[NSDecimalNumber alloc] initWithDouble:zValue];
    }
    
    return [[GPKGSLocationCoordinate3D alloc] initWithCoordinate:to andZ:toZ];
}

-(WKBPoint *) transformWithPoint: (WKBPoint *) from{
    
    GPKGGeometryProjectionTransform * geometryTransform = [[GPKGGeometryProjectionTransform alloc] initWithProjectionTransform:self];
    WKBPoint * to = [geometryTransform transformPoint:from];
    
    return to;
}

-(WKBGeometry *) transformWithGeometry: (WKBGeometry *) from{
    
    GPKGGeometryProjectionTransform * geometryTransform = [[GPKGGeometryProjectionTransform alloc] initWithProjectionTransform:self];
    WKBGeometry * to = [geometryTransform transformGeometry:from];
    
    return to;
}

-(GPKGBoundingBox *) transformWithBoundingBox: (GPKGBoundingBox *) boundingBox{
    
    CLLocationCoordinate2D lowerLeft = CLLocationCoordinate2DMake([boundingBox.minLatitude doubleValue], [boundingBox.minLongitude doubleValue]);
    CLLocationCoordinate2D lowerRight = CLLocationCoordinate2DMake([boundingBox.minLatitude doubleValue], [boundingBox.maxLongitude doubleValue]);
    CLLocationCoordinate2D upperRight = CLLocationCoordinate2DMake([boundingBox.maxLatitude doubleValue], [boundingBox.maxLongitude doubleValue]);
    CLLocationCoordinate2D upperLeft = CLLocationCoordinate2DMake([boundingBox.maxLatitude doubleValue], [boundingBox.minLongitude doubleValue]);

    CLLocationCoordinate2D projectedLowerLeft = [self transform:lowerLeft];
    CLLocationCoordinate2D projectedLowerRight = [self transform:lowerRight];
    CLLocationCoordinate2D projectedUpperRight = [self transform:upperRight];
    CLLocationCoordinate2D projectedUpperLeft = [self transform:upperLeft];
    
    double minX = MIN(projectedLowerLeft.longitude, projectedUpperLeft.longitude);
    double maxX = MAX(projectedLowerRight.longitude, projectedUpperRight.longitude);
    double minY = MIN(projectedLowerLeft.latitude, projectedLowerRight.latitude);
    double maxY = MAX(projectedUpperLeft.latitude, projectedUpperRight.latitude);
    
    GPKGBoundingBox * projectedBoundingBox = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minX andMaxLongitudeDouble:maxX andMinLatitudeDouble:minY andMaxLatitudeDouble:maxY];
    
    return projectedBoundingBox;
}

-(NSArray *) transformWithX: (double) x andY: (double) y{
    CLLocationCoordinate2D fromCoord = CLLocationCoordinate2DMake(y, x);
    CLLocationCoordinate2D toCoord = [self transform:fromCoord];
    return [[NSArray alloc] initWithObjects:[NSDecimalNumber numberWithDouble:toCoord.longitude], [NSDecimalNumber numberWithDouble:toCoord.latitude], nil];
}

@end
