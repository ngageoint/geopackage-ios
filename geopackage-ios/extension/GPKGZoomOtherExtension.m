//
//  GPKGZoomOtherExtension.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/4/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGZoomOtherExtension.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"

NSString * const GPKG_ZOOM_OTHER_EXTENSION_NAME = @"zoom_other";
NSString * const GPKG_PROP_ZOOM_OTHER_EXTENSION_DEFINITION = @"geopackage.extensions.zoom_other";

@implementation GPKGZoomOtherExtension

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildDefaultAuthorExtensionName:GPKG_ZOOM_OTHER_EXTENSION_NAME];
        self.definition = [GPKGProperties valueOfProperty:GPKG_PROP_ZOOM_OTHER_EXTENSION_DEFINITION];
    }
    return self;
}

-(GPKGExtensions *) extensionCreateWithTableName: (NSString *) tableName{
    
    GPKGExtensions * extension = [self extensionCreateWithName:self.extensionName andTableName:tableName andColumnName:GPKG_TC_COLUMN_TILE_DATA andDefinition:self.definition andScope:GPKG_EST_READ_WRITE];
    
    return extension;
}

-(BOOL) hasWithTableName: (NSString *) tableName{
    
    BOOL exists = [self hasWithExtensionName:self.extensionName andTableName:tableName andColumnName:GPKG_TC_COLUMN_TILE_DATA];
    
    return exists;
}

@end
