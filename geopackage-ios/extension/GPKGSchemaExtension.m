//
//  GPKGSchemaExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGSchemaExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"

NSString * const GPKG_SCHEMA_EXTENSION_NAME = @"schema";
NSString * const GPKG_PROP_SCHEMA_EXTENSION_DEFINITION = @"geopackage.extensions.schema";

@implementation GPKGSchemaExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_SCHEMA_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_SCHEMA_EXTENSION_DEFINITION];
    }
    return self;
}

-(GPKGExtensions *) getOrCreate{
    
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:nil andColumnName:nil andDescription:self.definition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) has{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:nil andColumnName:nil];
    
    return exists;
}

@end
