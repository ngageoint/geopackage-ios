//
//  GPKGProjectionRetriever.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionRetriever.h"
#import "GPKGProjectionConstants.h"
#import "GPKGIOUtils.h"

static NSDictionary * projections;

@implementation GPKGProjectionRetriever

+(NSString *) getProjectionWithNumber: (NSNumber *) epsg{
    
    if(projections == nil){
        NSString * propertiesPath = [GPKGIOUtils getPropertyListPathWithName:PROJ_PROPERTIES];
        projections = [NSDictionary dictionaryWithContentsOfFile:propertiesPath];
    }
    
    NSString * parameters = [projections valueForKey:[epsg stringValue]];
    
    if(parameters == nil){
        parameters = [projections valueForKey:[NSString stringWithFormat:@"%d", PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
    }
    
    return parameters;
}

@end
