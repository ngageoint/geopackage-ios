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

/**
 * Mapping of authorities to projections
 */
static NSMutableDictionary<NSString *, GPKGAuthorityProjections *> * authorities;

@implementation GPKGProjectionFactory

+(GPKGProjection *) projectionWithEpsg: (NSNumber *) epsg{
    return [self projectionWithAuthority:PROJ_AUTHORITY_EPSG andNumberCode:epsg];
}

+(GPKGProjection *) projectionWithEpsgInt: (int) epsg{
    return [self projectionWithAuthority:PROJ_AUTHORITY_EPSG andCode:[NSString stringWithFormat:@"%d",epsg]];
}

+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andNumberCode:(NSNumber *)code{
    return [self projectionWithAuthority:authority andCode:[code stringValue]];
}

+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andCode:(NSString *)code{
    return [self projectionWithAuthority:authority andCode:code andParams:nil andDefinition:nil];
}

+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andNumberCode:(NSNumber *)code andParams: (NSString *) params{
    return [self projectionWithAuthority:authority andCode:[code stringValue] andParams:params];
}

+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andCode:(NSString *)code andParams: (NSString *) params{
    return [self projectionWithAuthority:authority andCode:code andParams:params andDefinition:nil];
}

+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andNumberCode:(NSNumber *)code andParams: (NSString *) params andDefinition: (NSString *) definition{
    return [self projectionWithAuthority:authority andCode:[code stringValue] andParams:params andDefinition:definition];
}

+(GPKGProjection *) projectionWithAuthority: (NSString *) authority andCode:(NSString *)code andParams: (NSString *) params andDefinition: (NSString *) definition{
    
    // Get or create the authority
    GPKGAuthorityProjections *authorityProjections = [self projectionsWithAuthority:authority];
    
    // Check if the projection already exists
    GPKGProjection *projection = [authorityProjections projectionForCode:code];
    
    if(projection == nil){
        
        // Try to get or create the projection from a definition
        projection = [self fromDefinition:definition withAuthorityProjections:authorityProjections andCode:code];
        
        if(projection == nil){
            
            // Try to create the projection from the provided params
            projection = [self fromParams:params withAuthorityProjections:authorityProjections andCode:code];
            
            if(projection == nil){
                
                // Try to create the projection from properties
                projection = [self fromPropertiesWithAuthorityProjections:authorityProjections andCode:code];
                
                if(projection == nil){
                    [NSException raise:@"" format:@"Failed to create projection for authority: %@, code: %@, definition: %@, params: %@", authority, code, definition, params];
                }
            }
        }
    }
    
    return projection;
}

+(GPKGAuthorityProjections *) projectionsWithAuthority: (NSString *) authority{
    
    if(authorities == nil){
        authorities = [[NSMutableDictionary alloc] init];
    }
    
    GPKGAuthorityProjections *authorityProjections = [authorities objectForKey:[authority uppercaseString]];
    if(authorityProjections == nil){
        authorityProjections = [[GPKGAuthorityProjections alloc] initWithAuthority:authority];
        [authorities setObject:authorityProjections forKey:[authority uppercaseString]];
    }
    return authorityProjections;
}

+(void) clear{
    [authorities removeAllObjects];
}

+(void) clearAuthority: (NSString *) authority{
    [[self projectionsWithAuthority:authority] clear];
}

+(void) clearAuthority: (NSString *) authority andNumberCode: (NSNumber *) code{
    [[self projectionsWithAuthority:authority] clearNumberCode:code];
}

+(void) clearAuthority: (NSString *) authority andCode: (NSString *) code{
    [[self projectionsWithAuthority:authority] clearCode:code];
}

/**
 * Create a projection from the WKT definition
 *
 * @param definition
 *            WKT coordinate definition
 * @param authorityProjections
 *            authority projections
 * @param code
 *            coordinate code
 * @return projection
 */
+(GPKGProjection *) fromDefinition: (NSString *) definition withAuthorityProjections: (GPKGAuthorityProjections *) authorityProjections andCode: (NSString *) code{

    GPKGProjection *projection = nil;
    
    if(definition != nil && definition.length > 0){
        
        NSString *parametersString = nil;
        // TODO parse WKT definition into proj4 parameters
        
        // Try to create the projection from the parameters
        if(parametersString != nil && parametersString.length > 0){
            
            projPJ crs = pj_init_plus([parametersString UTF8String]);
            if(crs != nil){
                NSDecimalNumber * toMeters = [self toMetersFromParameters:parametersString];
                projection = [[GPKGProjection alloc] initWithAuthority:[authorityProjections authority] andCode:code andCrs:crs andToMeters:toMeters];
                [authorityProjections addProjection:projection];
            }else{
                NSLog(@"Failed to create projection for authority: %@, code: %@, definition, %@, parameters: %@", [authorityProjections authority], code, definition, parametersString);
            }
        }
    }
    
    return projection;
}

/**
 * Create a projection from the proj4 parameters
 *
 * @param params
 *            proj4 parameters
 * @param authorityProjections
 *            authority projections
 * @param code
 *            coordinate code
 * @return projection
 */
+(GPKGProjection *) fromParams: (NSString *) params withAuthorityProjections: (GPKGAuthorityProjections *) authorityProjections andCode: (NSString *) code{
    
    GPKGProjection *projection = nil;
    
    if (params != nil && params.length > 0) {
        projPJ crs = pj_init_plus([params UTF8String]);
        if(crs != nil){
            NSDecimalNumber * toMeters = [self toMetersFromParameters:params];
            projection = [[GPKGProjection alloc] initWithAuthority:[authorityProjections authority] andCode:code andCrs:crs andToMeters:toMeters];
            [authorityProjections addProjection:projection];
        }else{
            NSLog(@"Failed to create projection for authority: %@, code: %@, parameters: %@", [authorityProjections authority], code, params);
        }
    }
    
    return projection;
}

/**
 * Create a projection from configured coordinate properties
 *
 * @param authorityProjections
 *            authority projections
 * @param code
 *            coordinate code
 * @return projection
 */
+(GPKGProjection *) fromPropertiesWithAuthorityProjections: (GPKGAuthorityProjections *) authorityProjections andCode: (NSString *) code{
    
    GPKGProjection *projection = nil;
    
    NSString *parameters = [GPKGProjectionRetriever projectionWithAuthority:[authorityProjections authority] andCode:code];
    
    if(parameters != nil && parameters.length > 0){
        projPJ crs = pj_init_plus([parameters UTF8String]);
        if(crs != nil){
            NSDecimalNumber * toMeters = [self toMetersFromParameters:parameters];
            projection = [[GPKGProjection alloc] initWithAuthority:[authorityProjections authority] andCode:code andCrs:crs andToMeters:toMeters];
            [authorityProjections addProjection:projection];
        }else{
            NSLog(@"Failed to create projection for authority: %@, code: %@, parameters: %@", [authorityProjections authority], code, parameters);
        }
    }
    
    return projection;
}

+(GPKGProjection *) projectionWithSrs: (GPKGSpatialReferenceSystem *) srs{
    
    NSString *authority = srs.organization;
    NSNumber *code = srs.organizationCoordsysId;
    NSString *definition = srs.definition_12_063;
    if(definition == nil){
        definition = srs.definition;
    }
    
    GPKGProjection *projection = [self projectionWithAuthority:authority andNumberCode:code andParams:nil andDefinition:definition];
    
    return projection;
}

+(NSDecimalNumber *) toMetersFromParameters: (NSString *) parameters{
    
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
