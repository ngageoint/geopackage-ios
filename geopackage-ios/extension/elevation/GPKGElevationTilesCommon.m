//
//  GPKGElevationTilesCommon.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGElevationTilesCommon.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGProperties.h"
#import "GPKGElevationTilesAlgorithms.h"

NSString * const GPKG_ELEVATION_TILES_EXTENSION_NAME = @"elevation_tiles";
NSString * const GPKG_PROP_ELEVATION_TILES_EXTENSION_DEFINITION = @"geopackage.extensions.elevation_tiles";

@interface GPKGElevationTilesCommon ()

@property (nonatomic, strong) GPKGTileMatrixSet *tileMatrixSet;
@property (nonatomic, strong) GPKGGriddedCoverageDao *griddedCoverageDao;
@property (nonatomic, strong) GPKGGriddedTileDao *griddedTileDao;
@property (nonatomic, strong) GPKGGriddedCoverage *griddedCoverage;
@property (nonatomic, strong) NSNumber *width;
@property (nonatomic, strong) NSNumber *height;
@property (nonatomic, strong) GPKGProjection *requestProjection;
@property (nonatomic, strong) GPKGProjection *elevationProjection;
@property (nonatomic, strong) GPKGBoundingBox *elevationBoundingBox;
@property (nonatomic) BOOL sameProjection;
@property (nonatomic) BOOL zoomIn;
@property (nonatomic) BOOL zoomOut;
@property (nonatomic) BOOL zoomInBeforeOut;
@property (nonatomic) enum GPKGElevationTilesAlgorithm algorithm;

@end

@implementation GPKGElevationTilesCommon

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    self = [super initWithGeoPackage:geoPackage];
    if(self != nil){
        self.extensionName = [NSString stringWithFormat:@"%@%@%@", GPKG_GEO_PACKAGE_EXTENSION_AUTHOR, GPKG_EX_EXTENSION_NAME_DIVIDER, GPKG_ELEVATION_TILES_EXTENSION_NAME];
        self.definition = [GPKGProperties getValueOfProperty:GPKG_PROP_ELEVATION_TILES_EXTENSION_DEFINITION];
        self.zoomIn = true;
        self.zoomOut = true;
        self.zoomInBeforeOut = true;
        self.algorithm = GPKG_ETA_NEAREST_NEIGHBOR;
    }
    return self;
}

@end
