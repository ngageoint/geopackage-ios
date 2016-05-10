//
//  GPKGWebPExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGWebPExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"

NSString * const GPKG_WEBP_EXTENSION_NAME = @"webp";
NSString * const GPKG_PROP_WEBP_EXTENSION_DEFINITION = @"geopackage.extensions.webp";

@implementation GPKGWebPExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_WEBP_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_WEBP_EXTENSION_DEFINITION];
    }
    return self;
}

-(GPKGExtensions *) getOrCreateWithTableName: (NSString *) tableName{
    
    GPKGExtensions * extension = [self getOrCreateWithExtensionName:self.extensionName andTableName:tableName andColumnName:GPKG_TT_COLUMN_TILE_ROW andDescription:self.definition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) hasWithTableName: (NSString *) tableName{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:tableName andColumnName:GPKG_TT_COLUMN_TILE_ROW];
    
    return exists;
}

@end
