//
//  GPKGSpatialReferenceSystem.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystem.h"
#import "PROJProjectionFactory.h"
#import "GPKGGeoPackageConstants.h"

NSString * const GPKG_SRS_TABLE_NAME = @"gpkg_spatial_ref_sys";
NSString * const GPKG_SRS_COLUMN_PK = @"srs_id";
NSString * const GPKG_SRS_COLUMN_SRS_NAME = @"srs_name";
NSString * const GPKG_SRS_COLUMN_SRS_ID = @"srs_id";
NSString * const GPKG_SRS_COLUMN_ORGANIZATION = @"organization";
NSString * const GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID = @"organization_coordsys_id";
NSString * const GPKG_SRS_COLUMN_DEFINITION = @"definition";
NSString * const GPKG_SRS_COLUMN_DESCRIPTION = @"description";

@implementation GPKGSpatialReferenceSystem

-(PROJProjection *) projection{
    
    NSString *authority = self.organization;
    NSNumber *code = self.organizationCoordsysId;
    NSString *definition = [self projectionDefinition];
    
    PROJProjection *projection = [PROJProjectionFactory projectionWithAuthority:authority andNumberCode:code andParams:nil andDefinition:definition];
    
    return projection;
}

-(NSString *) projectionDefinition{
    
    NSString *definition = self.definition_12_063;
    if([self emptyDefinition:definition]){
        
        definition = self.definition;
        
        if([self emptyDefinition:definition]){
            definition = nil;
        }
    }
    
    return definition;
}

-(BOOL) emptyDefinition: (NSString *) definition{
    BOOL empty = definition == nil;
    if(!empty){
        NSString *trim = [definition stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        empty = trim.length == 0 || [trim caseInsensitiveCompare:GPKG_UNDEFINED_DEFINITION] == NSOrderedSame;
    }
    return empty;
}

-(SFPGeometryTransform *) transformationFromProjection: (PROJProjection *) projection{
    PROJProjection *projectionTo = [self projection];
    return [SFPGeometryTransform transformFromProjection:projection andToProjection:projectionTo];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    srs.srsName = _srsName;
    srs.srsId = _srsId;
    srs.organization = _organization;
    srs.organizationCoordsysId = _organizationCoordsysId;
    srs.definition = _definition;
    srs.theDescription = _theDescription;
    srs.definition_12_063 = _definition_12_063;
    srs.epoch = _epoch;
    return srs;
}

@end
