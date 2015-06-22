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

-(CLLocationCoordinate2D *) getLocationCoordinatesFromPoints: (NSArray *) points{
    CLLocationCoordinate2D *coordinates = calloc([points count], sizeof(CLLocationCoordinate2D));
    int index = 0;
    for(GPKGMapPoint * point in points){
        coordinates[index++] = point.coordinate;
    }
    return coordinates;
}

//TODO

@end
