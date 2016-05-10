//
//  GPKGProjectionFactory.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGProjectionFactory.h"
#import "proj_api.h"
#import "GPKGProjectionRetriever.h"
#import "GPKGProjectionConstants.h"

NSString * const GPKG_PROJ_TO_METER_PATTERN = @"\\+to_meter=(\\S+)";

static NSMutableDictionary * projections;

@implementation GPKGProjectionFactory

+(GPKGProjection *) getProjectionWithNumber: (NSNumber *) epsg{
    
    if(projections == nil){
        projections = [[NSMutableDictionary alloc] init];
    }
    
    GPKGProjection * projection = [projections objectForKey:epsg];
    
    if(projection == nil){
        
        // Get the projection parameters from the properties
        NSString * parameters = nil;
        int epsgInt = [epsg intValue];
        if(epsgInt == -1 || epsgInt == 0){
            parameters = [GPKGProjectionRetriever getProjectionWithNumber:[NSNumber numberWithInt:PROJ_EPSG_WORLD_GEODETIC_SYSTEM]];
        }else{
            parameters = [GPKGProjectionRetriever getProjectionWithNumber:epsg];
        }
        
        projPJ crs = pj_init_plus([parameters UTF8String]);
        if(crs == nil){
            [NSException raise:@"Projection Creation Failed" format:@"Failed to create projection for EPSG %@ with parameters: '%@'. Error: %d", epsg, parameters, pj_errno];
        }
        
        NSDecimalNumber * toMeters = [self getToMetersFromParameters:parameters];
        
        projection = [[GPKGProjection alloc] initWithEpsg:epsg andCrs:crs andToMeters:toMeters];
        
        [projections setObject:projection forKey:epsg];
    }
    
    return projection;
}

+(GPKGProjection *) getProjectionWithInt: (int) epsg{
    return [self getProjectionWithNumber:[NSNumber numberWithInt:epsg]];
}

+(GPKGProjection *) getProjectionWithSrs: (GPKGSpatialReferenceSystem *) srs{
    
    NSNumber * epsg = srs.organizationCoordsysId;
    GPKGProjection * projection = [self getProjectionWithNumber:epsg];
    
    return projection;
}

+(NSDecimalNumber *) getToMetersFromParameters: (NSString *) parameters{
    
    NSDecimalNumber * toMeters = nil;
    
    NSError  *error = nil;
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:GPKG_PROJ_TO_METER_PATTERN options:NSRegularExpressionCaseInsensitive error:&error];
    if(error){
        [NSException raise:@"To Meter Regular Expression" format:@"Failed to create projection to meter regular epxression with error: %@", error];
    }
    NSArray * matches = [regExp matchesInString:parameters options:0 range:NSMakeRange(0, [parameters length])];
    if([matches count] > 0){
        NSTextCheckingResult* match = (NSTextCheckingResult*) [matches objectAtIndex:0];
        if([match numberOfRanges] > 0){
            NSRange toMeterGroup = [match rangeAtIndex:1];
            NSString * toMeterGroupString = [parameters substringWithRange:toMeterGroup];
            toMeters = [[NSDecimalNumber alloc] initWithString:toMeterGroupString];
        }
    }
    
    return toMeters;
}

@end
