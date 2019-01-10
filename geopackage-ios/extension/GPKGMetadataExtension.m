//
//  GPKGMetadataExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGMetadataExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"

NSString * const GPKG_METADATA_EXTENSION_NAME = @"metadata";
NSString * const GPKG_PROP_METADATA_EXTENSION_DEFINITION = @"geopackage.extensions.metadata";

@implementation GPKGMetadataExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_METADATA_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_METADATA_EXTENSION_DEFINITION];
    }
    return self;
}

-(GPKGExtensions *) getOrCreate{
    
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:nil andColumnName:nil andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) has{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:nil andColumnName:nil];
    
    return exists;
}

-(void) removeExtension{
    
    if([self.geoPackage isTable:GPKG_MR_TABLE_NAME]){
        [self.geoPackage dropTable:GPKG_MR_TABLE_NAME];
    }
    
    if([self.geoPackage isTable:GPKG_M_TABLE_NAME]){
        [self.geoPackage dropTable:GPKG_M_TABLE_NAME];
    }
    
    if([self.extensionsDao tableExists]){
        [self.extensionsDao deleteByExtension:self.extensionName];
    }
    
}

@end
