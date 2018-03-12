//
//  GPKGTileTableScaling.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileTableScaling.h"
#import "GPKGProperties.h"

NSString * const GPKG_EXTENSION_TILE_SCALING_AUTHOR = @"nga";
NSString * const GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR = @"tile_scaling";
NSString * const GPKG_PROP_EXTENSION_TILE_SCALING_DEFINITION = @"geopackage.extensions.tile_scaling";

@interface GPKGTileTableScaling ()

@property (nonatomic, strong) NSString *extensionName;
@property (nonatomic, strong) NSString *extensionDefinition;
@property (nonatomic, strong) GPKGTileScalingDao *tileScalingDao;

@end

@implementation GPKGTileTableScaling

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [GPKGExtensions buildExtensionNameWithAuthor:GPKG_EXTENSION_TILE_SCALING_AUTHOR andExtensionName:GPKG_EXTENSION_TILE_SCALING_NAME_NO_AUTHOR];
        self.extensionDefinition = [GPKGProperties getValueOfProperty:GPKG_PROP_EXTENSION_TILE_SCALING_DEFINITION];
        self.tileScalingDao = [geoPackage getTileScalingDao];
    }
    return self;
}

-(GPKGGeoPackage *) getGeoPackage{
    return self.geoPackage;
}

-(GPKGTileScalingDao *) getDao{
    return self.tileScalingDao;
}

-(NSString *) getExtensionName{
    return self.extensionName;
}

-(NSString *) getExtensionDefinition{
    return self.extensionDefinition;
}

@end
