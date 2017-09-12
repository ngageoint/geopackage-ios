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
#import "GPKGProjectionConstants.h"

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

    return [self initWithFromAuthority:PROJ_AUTHORITY_EPSG andFromIntCode:fromEpsg andToAuthority:PROJ_AUTHORITY_EPSG andToIntCode:toEpsg];
}

-(instancetype) initWithFromAuthority: (NSString *) fromAuthority andFromIntCode: (int) fromCode andToAuthority: (NSString *) toAuthority andToIntCode: (int) toCode{
    
    NSString *fromStringCode = [NSString stringWithFormat:@"%d", fromCode];
    NSString *toStringCode = [NSString stringWithFormat:@"%d", toCode];
    
    return [self initWithFromAuthority:fromAuthority andFromCode:fromStringCode andToAuthority:toAuthority andToCode:toStringCode];
}

-(instancetype) initWithFromAuthority: (NSString *) fromAuthority andFromCode: (NSString *) fromCode andToAuthority: (NSString *) toAuthority andToCode: (NSString *) toCode{
    
    GPKGProjection * fromProjection = [GPKGProjectionFactory projectionWithAuthority:fromAuthority andCode:fromCode];
    GPKGProjection * toProjection = [GPKGProjectionFactory projectionWithAuthority:toAuthority andCode:toCode];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToEpsg: (int) toEpsg{
    
    NSString *toCode = [NSString stringWithFormat:@"%d", toEpsg];
    
    return [self initWithFromProjection:fromProjection andToAuthority:PROJ_AUTHORITY_EPSG andToCode:toCode];
}

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToAuthority: (NSString *) toAuthority andToCode: (NSString *) toCode{
    
    GPKGProjection * toProjection = [GPKGProjectionFactory projectionWithAuthority:toAuthority andCode:toCode];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromEpsg: (int) fromEpsg andToProjection: (GPKGProjection *) toProjection{
    
    NSString *fromCode = [NSString stringWithFormat:@"%d", fromEpsg];
    
    return [self initWithFromAuthority:PROJ_AUTHORITY_EPSG andFromCode:fromCode andToProjection:toProjection];
}

-(instancetype) initWithFromAuthority: (NSString *) fromAuthority andFromCode: (NSString *) fromCode andToProjection: (GPKGProjection *) toProjection{
    
    GPKGProjection * fromProjection = [GPKGProjectionFactory projectionWithAuthority:fromAuthority andCode:fromCode];
    
    return [self initWithFromProjection:fromProjection andToProjection:toProjection];
}

-(instancetype) initWithFromSrs: (GPKGSpatialReferenceSystem *) fromSrs andToSrs: (GPKGSpatialReferenceSystem *) toSrs{
    
    NSString *fromCode = [fromSrs.organizationCoordsysId stringValue];
    NSString *toCode = [toSrs.organizationCoordsysId stringValue];
    
    return [self initWithFromAuthority:fromSrs.organization andFromCode:fromCode andToAuthority:toSrs.organization andToCode:toCode];
}

-(instancetype) initWithFromSrs: (GPKGSpatialReferenceSystem *) fromSrs andToProjection: (GPKGProjection *) toProjection{
    
    NSString *fromCode = [fromSrs.organizationCoordsysId stringValue];
    
    return [self initWithFromAuthority:fromSrs.organization andFromCode:fromCode andToProjection:toProjection];
}

-(instancetype) initWithFromProjection: (GPKGProjection *) fromProjection andToSrs: (GPKGSpatialReferenceSystem *) toSrs{
    
    NSString *toCode = [toSrs.organizationCoordsysId stringValue];
    
    return [self initWithFromProjection:fromProjection andToAuthority:toSrs.organization andToCode:toCode];
}

-(instancetype) initWithFromSrs: (GPKGSpatialReferenceSystem *) fromSrs andToEpsg: (int) toEpsg{
    
    NSString *toCode = [NSString stringWithFormat:@"%d", toEpsg];
    
    return [self initWithFromSrs:fromSrs andToAuthority:PROJ_AUTHORITY_EPSG andToCode:toCode];
}

-(instancetype) initWithFromSrs: (GPKGSpatialReferenceSystem *) fromSrs andToAuthority: (NSString *) toAuthority andToCode: (NSString *) toCode{
    
    NSString *fromCode = [fromSrs.organizationCoordsysId stringValue];
    
    return [self initWithFromAuthority:fromSrs.organization andFromCode:fromCode andToAuthority:toAuthority andToCode:toCode];
}

-(instancetype) initWithFromEpsg: (int) fromEpsg andToSrs: (GPKGSpatialReferenceSystem *) toSrs{
    
    NSString *fromCode = [NSString stringWithFormat:@"%d", fromEpsg];
    
    return [self initWithFromAuthority:PROJ_AUTHORITY_EPSG andFromCode:fromCode andToSrs:toSrs];
}

-(instancetype) initWithFromAuthority: (NSString *) fromAuthority andFromCode: (NSString *) fromCode andToSrs: (GPKGSpatialReferenceSystem *) toSrs{
    
    NSString *toCode = [toSrs.organizationCoordsysId stringValue];
    
    return [self initWithFromAuthority:fromAuthority andFromCode:fromCode andToAuthority:toSrs.organization andToCode:toCode];
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
        [NSException raise:@"Transform Error" format:@"Failed to transform authority: %@, code: %@, latitude: %f, longitude: %f to authority: %@, code: %@, Error: %d", self.fromProjection.authority, self.fromProjection.code, from.coordinate.latitude, from.coordinate.longitude, self.toProjection.authority, self.toProjection.code, value];
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

-(NSArray<WKBPoint *> *) transformWithPoints: (NSArray<WKBPoint *> *) from{
    
    NSMutableArray<WKBPoint *> *to = [[NSMutableArray alloc] init];
    
    GPKGGeometryProjectionTransform * geometryTransform = [[GPKGGeometryProjectionTransform alloc] initWithProjectionTransform:self];
    for(WKBPoint *fromPoint in from){
        WKBPoint * toPoint = [geometryTransform transformPoint:fromPoint];
        [to addObject:toPoint];
    }
    
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
