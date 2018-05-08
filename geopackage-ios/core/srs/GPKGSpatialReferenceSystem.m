//
//  GPKGSpatialReferenceSystem.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystem.h"
#import "SFPProjectionTransform.h"
#import "SFPProjectionFactory.h"

NSString * const GPKG_SRS_TABLE_NAME = @"gpkg_spatial_ref_sys";
NSString * const GPKG_SRS_COLUMN_PK = @"srs_id";
NSString * const GPKG_SRS_COLUMN_SRS_NAME = @"srs_name";
NSString * const GPKG_SRS_COLUMN_SRS_ID = @"srs_id";
NSString * const GPKG_SRS_COLUMN_ORGANIZATION = @"organization";
NSString * const GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID = @"organization_coordsys_id";
NSString * const GPKG_SRS_COLUMN_DEFINITION = @"definition";
NSString * const GPKG_SRS_COLUMN_DESCRIPTION = @"description";
NSString * const GPKG_SRS_COLUMN_DEFINITION_12_063 = @"definition_12_063";

@implementation GPKGSpatialReferenceSystem

-(SFPProjection *) projection{
    
    NSString *authority = self.organization;
    NSNumber *code = self.organizationCoordsysId;
    NSString *definition = self.definition_12_063;
    if(definition == nil){
        definition = self.definition;
    }
    
    SFPProjection *projection = [SFPProjectionFactory projectionWithAuthority:authority andNumberCode:code andParams:nil andDefinition:definition];
    
    return projection;
}

-(SFPProjectionTransform *) transformationFromProjection: (SFPProjection *) projection{
    SFPProjection *projectionTo = [self projection];
    return [[SFPProjectionTransform alloc] initWithFromProjection:projection andToProjection:projectionTo];
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
    return srs;
}

@end
