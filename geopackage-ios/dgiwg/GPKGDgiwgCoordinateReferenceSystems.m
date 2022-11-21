//
//  GPKGDgiwgCoordinateReferenceSystems.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "PROJProjectionConstants.h"
#import "GPKGDgiwgWellKnownText.h"
#import "GPKGUTMZone.h"
#import "GPKGGeoPackageConstants.h"

@interface GPKGDgiwgCoordinateReferenceSystems()

/**
 * DGIWG CRS Type
 */
@property (nonatomic) enum GPKGDgiwgCoordinateReferenceSystem type;

/**
 * Authority
 */
@property (nonatomic, strong) NSString *authority;

/**
 * CRS Code
 */
@property (nonatomic) int code;

/**
 * Name
 */
@property (nonatomic, strong) NSString *crsName;

/**
 * CRS Type
 */
@property (nonatomic) enum CRSType crsType;

/**
 * Dimension
 */
@property (nonatomic) int dimension;

/**
 * Well-Known Text
 */
@property (nonatomic, strong) NSString *wkt;

/**
 * Description
 */
@property (nonatomic, strong) NSString *theDescription;

/**
 * Bounds
 */
@property (nonatomic, strong) GPKGBoundingBox *bounds;

/**
 * WGS84 bounds extent
 */
@property (nonatomic, strong) GPKGBoundingBox *wgs84Bounds;

/**
 * Data Types
 */
@property (nonatomic, strong) NSArray<NSNumber *> *dataTypes;

/**
 * Contents Data Types
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, NSArray<NSNumber *> *> *contentsDataTypes;

@end

@implementation GPKGDgiwgCoordinateReferenceSystems

/**
 * Type to CRS mapping
 */
static NSMutableDictionary<NSNumber *, GPKGDgiwgCoordinateReferenceSystems *> *typeCRS = nil;

/**
 * Map between authority and codes to Coordinate Reference Systems
 */
static NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, GPKGDgiwgCoordinateReferenceSystems *> *> *authorityCodeCRS;

/**
 * Map between data types and supported Coordinate Reference Systems
 */
static NSMutableDictionary<NSNumber *, NSMutableArray<GPKGDgiwgCoordinateReferenceSystems *> *> *dataTypeCRS;

+(void) initialize{
    typeCRS = [NSMutableDictionary dictionary];
    authorityCodeCRS = [NSMutableDictionary dictionary];
    dataTypeCRS = [NSMutableDictionary dictionary];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_3035 andEPSG:3035 andName:@"ETRS89-extended / LAEA Europe" andCRS:CRS_TYPE_PROJECTED andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg3035] andDescription:@"Lambert Azimuthal Equal Area ETRS89 for Europe" andBounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:2000000.0 andMinLatitudeDouble:1000000.0 andMaxLongitudeDouble:6500000 andMaxLatitudeDouble:5500000.0] andWGS84Bounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-16.1 andMinLatitudeDouble:32.88 andMaxLongitudeDouble:40.18 andMaxLatitudeDouble:84.73] andDataTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_2D], [NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_3D], nil]]];

    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_3395 andEPSG:3395 andName:@"WGS 84 / World Mercator" andCRS:CRS_TYPE_PROJECTED andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg3395] andDescription:@"Mercator view of world excluding polar areas for very small scale mapping" andBounds:[GPKGBoundingBox worldWebMercator] andWGS84Bounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-PROJ_WGS84_HALF_WORLD_LON_WIDTH andMinLatitudeDouble:-80.0 andMaxLongitudeDouble:PROJ_WGS84_HALF_WORLD_LON_WIDTH andMaxLatitudeDouble:84.0] andDataTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_2D], [NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_3D], nil]]];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_3857 andEPSG:3857 andName:@"WGS 84 / Pseudo-Mercator" andCRS:CRS_TYPE_PROJECTED andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg3857] andDescription:@"Uses spherical development of ellipsoidal coordinates. This should only be used for visualization purposes." andBounds:[GPKGBoundingBox worldWebMercator] andWGS84Bounds:[GPKGBoundingBox worldWGS84WithWebMercatorLimits] andDataType:GPKG_DGIWG_DT_TILES_2D]];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_3978 andEPSG:3978 andName:@"NAD83 / Canada Atlas Lambert" andCRS:CRS_TYPE_PROJECTED andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg3978] andDescription:@"Lambert Conformal Conic NAD83 for Canada" andBounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-7786476.885838887 andMinLatitudeDouble:-5153821.09213678 andMaxLongitudeDouble:7148753.233541353 andMaxLatitudeDouble:7928343.534071138] andWGS84Bounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-172.54 andMinLatitudeDouble:23.81 andMaxLongitudeDouble:-47.74 andMaxLatitudeDouble:86.46] andDataType:GPKG_DGIWG_DT_TILES_2D]];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_4326 andEPSG:4326 andName:@"WGS 84 Geographic 2D" andCRS:CRS_TYPE_GEODETIC andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg4326] andDescription:@"Horizontal component of 3D system. Used by the GPS satellite navigation system and for NATO military geodetic surveying." andDataTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_3D], [NSNumber numberWithInt:GPKG_DGIWG_DT_FEATURES_2D], nil]]];

    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_4979 andEPSG:4979 andName:@"WGS 84 Geographic 3D" andCRS:CRS_TYPE_GEODETIC andDimension:3 andWKT:[GPKGDgiwgWellKnownText epsg4979] andDescription:@"Used by the GPS satellite navigation system and for NATO military geodetic surveying." andDataTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_3D], [NSNumber numberWithInt:GPKG_DGIWG_DT_FEATURES_3D], nil]]];

    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_5041 andEPSG:5041 andName:@"WGS 84 / UPS North (E,N)" andCRS:CRS_TYPE_PROJECTED andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg5041] andDescription:@"Military mapping by NATO north of 60° N" andBounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-14440759.350252 andMinLatitudeDouble:-14440759.350252 andMaxLongitudeDouble:18440759.350252 andMaxLatitudeDouble:18440759.350252] andWGS84Bounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-PROJ_WGS84_HALF_WORLD_LON_WIDTH andMinLatitudeDouble:60.0 andMaxLongitudeDouble:PROJ_WGS84_HALF_WORLD_LON_WIDTH andMaxLatitudeDouble:PROJ_WGS84_HALF_WORLD_LAT_HEIGHT] andDataTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_2D], [NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_3D], nil]]];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_5042 andEPSG:5042 andName:@"WGS 84 / UPS South (E,N)" andCRS:CRS_TYPE_PROJECTED andDimension:2 andWKT:[GPKGDgiwgWellKnownText epsg5042] andDescription:@"Military mapping by NATO south of 60° S" andBounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-14440759.350252 andMinLatitudeDouble:-14440759.350252 andMaxLongitudeDouble:18440759.350252 andMaxLatitudeDouble:18440759.350252] andWGS84Bounds:[[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-PROJ_WGS84_HALF_WORLD_LON_WIDTH andMinLatitudeDouble:-PROJ_WGS84_HALF_WORLD_LAT_HEIGHT andMaxLongitudeDouble:PROJ_WGS84_HALF_WORLD_LON_WIDTH andMaxLatitudeDouble:-60.0] andDataTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_2D], [NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_3D], nil]]];

    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_9518 andEPSG:9518 andName:@"WGS84 4326 + EGM2008 height 3855" andCRS:CRS_TYPE_COMPOUND andDimension:3 andWKT:[GPKGDgiwgWellKnownText epsg9518] andDescription:@"Geodetic position based on the World Geodetic System 1984 (WGS 84), extended by height position based on the Earth Gravity Model 2008 (EGM08)." andDataType:GPKG_DGIWG_DT_FEATURES_3D]];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32601 andEPSG:32601]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32602 andEPSG:32602]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32603 andEPSG:32603]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32604 andEPSG:32604]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32605 andEPSG:32605]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32606 andEPSG:32606]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32607 andEPSG:32607]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32608 andEPSG:32608]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32609 andEPSG:32609]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32610 andEPSG:32610]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32611 andEPSG:32611]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32612 andEPSG:32612]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32613 andEPSG:32613]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32614 andEPSG:32614]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32615 andEPSG:32615]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32616 andEPSG:32616]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32617 andEPSG:32617]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32618 andEPSG:32618]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32619 andEPSG:32619]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32620 andEPSG:32620]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32621 andEPSG:32621]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32622 andEPSG:32622]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32623 andEPSG:32623]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32624 andEPSG:32624]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32625 andEPSG:32625]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32626 andEPSG:32626]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32627 andEPSG:32627]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32628 andEPSG:32628]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32629 andEPSG:32629]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32630 andEPSG:32630]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32631 andEPSG:32631]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32632 andEPSG:32632]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32633 andEPSG:32633]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32634 andEPSG:32634]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32635 andEPSG:32635]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32636 andEPSG:32636]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32637 andEPSG:32637]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32638 andEPSG:32638]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32639 andEPSG:32639]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32640 andEPSG:32640]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32641 andEPSG:32641]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32642 andEPSG:32642]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32643 andEPSG:32643]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32644 andEPSG:32644]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32645 andEPSG:32645]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32646 andEPSG:32646]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32647 andEPSG:32647]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32648 andEPSG:32648]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32649 andEPSG:32649]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32650 andEPSG:32650]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32651 andEPSG:32651]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32652 andEPSG:32652]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32653 andEPSG:32653]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32654 andEPSG:32654]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32655 andEPSG:32655]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32656 andEPSG:32656]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32657 andEPSG:32657]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32658 andEPSG:32658]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32659 andEPSG:32659]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32660 andEPSG:32660]];
    
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32701 andEPSG:32701]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32702 andEPSG:32702]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32703 andEPSG:32703]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32704 andEPSG:32704]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32705 andEPSG:32705]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32706 andEPSG:32706]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32707 andEPSG:32707]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32708 andEPSG:32708]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32709 andEPSG:32709]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32710 andEPSG:32710]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32711 andEPSG:32711]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32712 andEPSG:32712]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32713 andEPSG:32713]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32714 andEPSG:32714]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32715 andEPSG:32715]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32716 andEPSG:32716]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32717 andEPSG:32717]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32718 andEPSG:32718]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32719 andEPSG:32719]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32720 andEPSG:32720]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32721 andEPSG:32721]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32722 andEPSG:32722]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32723 andEPSG:32723]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32724 andEPSG:32724]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32725 andEPSG:32725]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32726 andEPSG:32726]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32727 andEPSG:32727]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32728 andEPSG:32728]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32729 andEPSG:32729]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32730 andEPSG:32730]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32731 andEPSG:32731]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32732 andEPSG:32732]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32733 andEPSG:32733]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32734 andEPSG:32734]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32735 andEPSG:32735]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32736 andEPSG:32736]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32737 andEPSG:32737]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32738 andEPSG:32738]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32739 andEPSG:32739]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32740 andEPSG:32740]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32741 andEPSG:32741]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32742 andEPSG:32742]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32743 andEPSG:32743]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32744 andEPSG:32744]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32745 andEPSG:32745]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32746 andEPSG:32746]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32747 andEPSG:32747]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32748 andEPSG:32748]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32749 andEPSG:32749]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32750 andEPSG:32750]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32751 andEPSG:32751]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32752 andEPSG:32752]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32753 andEPSG:32753]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32754 andEPSG:32754]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32755 andEPSG:32755]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32756 andEPSG:32756]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32757 andEPSG:32757]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32758 andEPSG:32758]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32759 andEPSG:32759]];
    [self initialize:[self createWithType:GPKG_DGIWG_CRS_EPSG_32760 andEPSG:32760]];
    
}

/**
 * Initialize static mappings
 *
 * @param crs
 *            CRS
 */
+(void) initialize: (GPKGDgiwgCoordinateReferenceSystems *) crs{
    
    [typeCRS setObject:crs forKey:[NSNumber numberWithInt:crs.type]];

    NSMutableDictionary<NSNumber *, GPKGDgiwgCoordinateReferenceSystems *> *codeDictionary = [authorityCodeCRS objectForKey:crs.authority];
    if(codeDictionary == nil){
        codeDictionary = [NSMutableDictionary dictionary];
        [authorityCodeCRS setObject:codeDictionary forKey:crs.authority];
    }
    [codeDictionary setObject:crs forKey:[NSNumber numberWithInt:crs.code]];

    for(NSNumber *dataType in crs.dataTypes){
        
        NSMutableArray<GPKGDgiwgCoordinateReferenceSystems *> *crsArray = [dataTypeCRS objectForKey:dataType];
        if(crsArray == nil){
            crsArray = [NSMutableArray array];
            [dataTypeCRS setObject:crsArray forKey:dataType];
        }
        
        [crsArray addObject:crs];
    }
    
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataType
 *            data type
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self createWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataTypes
 *            data types
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self createWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:[GPKGBoundingBox worldWGS84] andDataTypes:dataTypes];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self createWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self createWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:wgs84Bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self createWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self createWithType:type andAuthority:PROJ_AUTHORITY_EPSG andCode:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataType
 *            data type
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self createWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataTypes
 *            data types
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self createWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:[GPKGBoundingBox worldWGS84] andDataTypes:dataTypes];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self createWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self createWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:wgs84Bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self createWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Create with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [[GPKGDgiwgCoordinateReferenceSystems alloc] initWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Create for UTM Zones
 *
 * @param type
 *            type
 * @param epsgCode
 *            UTM Zone EPSG
 */
+(GPKGDgiwgCoordinateReferenceSystems *) createWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode{
    return [[GPKGDgiwgCoordinateReferenceSystems alloc] initWithType: type andEPSG:epsgCode];
}

+(GPKGDgiwgCoordinateReferenceSystems *) fromType: (enum GPKGDgiwgCoordinateReferenceSystem) type{
    return [typeCRS objectForKey:[NSNumber numberWithInt:type]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    self = [super init];
    if(self != nil){
        _type = type;
        _authority = authority;
        _code = code;
        _crsName = name;
        _crsType = crsType;
        _dimension = dimension;
        _wkt = wkt;
        _theDescription = description;
        _bounds = bounds;
        _wgs84Bounds = wgs84Bounds;
        _dataTypes = dataTypes;
        NSMutableDictionary<NSNumber *, NSMutableArray<NSNumber *> *> *contentsTypes = [NSMutableDictionary dictionary];
        for(NSNumber *dataType in dataTypes){
            enum GPKGContentsDataType contentsDataType = [GPKGDgiwgDataTypes dataType:[dataType intValue]];
            NSNumber *contentsNumber = [NSNumber numberWithInt:contentsDataType];
            NSMutableArray<NSNumber *> *dataTypesArray = [contentsTypes objectForKey:contentsNumber];
            if(dataTypesArray == nil){
                dataTypesArray = [NSMutableArray array];
                [contentsTypes setObject:dataTypesArray forKey:contentsNumber];
            }
            [dataTypesArray addObject:dataType];
        }
        _contentsDataTypes = contentsTypes;
    }
    return self;
}

/**
 * Initialize for UTM Zones
 *
 * @param type
 *            type
 * @param epsgCode
 *            UTM Zone EPSG
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode{
    self = [super init];
    if(self != nil){
        _type = type;
        _wkt = [GPKGDgiwgWellKnownText utmZone:epsgCode];
        _authority = PROJ_AUTHORITY_EPSG;
        _code = epsgCode;
        int zone = [GPKGUTMZone zone:epsgCode];
        NSString *latDirection = [GPKGUTMZone latDirection:epsgCode];
        _crsName = [NSString stringWithFormat:@"WGS 84 / UTM zone %d%@", zone, latDirection];
        _crsType = CRS_TYPE_PROJECTED;
        _dimension = 2;

        int centralMedian = [GPKGUTMZone centralMeridian:zone];
        NSString *lonDirection = centralMedian < 0 ? @"W" : @"S";
        BOOL north = [GPKGUTMZone isNorth:epsgCode];

        double minLongitude = centralMedian - 3;
        double maxLongitude = centralMedian + 3;
        double minLatitude = 0.0;
        double maxLatitude = 0.0;
        if(north){
            maxLatitude = 84.0;
        }else{
            minLatitude = -80.0;
        }

        NSMutableString *description = [NSMutableString stringWithString:@"Between "];
        [description appendFormat:@"%f", fabs(minLongitude)];
        [description appendString:@"°"];
        [description appendFormat:@"%@", lonDirection];
        [description appendString:@" and "];
        [description appendFormat:@"%f", fabs(maxLongitude)];
        [description appendString:@"°"];
        [description appendFormat:@"%@", lonDirection];
        [description appendString:@", "];
        if(north){
            [description appendString:@"northern"];
        }else{
            [description appendString:@"southern"];
        }
        [description appendString:@" hemisphere between "];
        if(north){
            [description appendString:@"equator and 84°N"];
        }else{
            [description appendString:@"80°S and equator"];
        }
        [description appendString:@", onshore and offshore."];
        _theDescription = description;
        
        _bounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:-9501965.72931276 andMinLatitudeDouble:-20003931.4586255 andMaxLongitudeDouble:10501965.7293128 andMaxLatitudeDouble:20003931.4586255];
        _wgs84Bounds = [[GPKGBoundingBox alloc] initWithMinLongitudeDouble:minLongitude andMinLatitudeDouble:minLatitude andMaxLongitudeDouble:maxLongitude andMaxLatitudeDouble:maxLatitude];
        _dataTypes = [NSArray arrayWithObject:[NSNumber numberWithInt:GPKG_DGIWG_DT_TILES_2D]];
        _contentsDataTypes = [NSDictionary dictionaryWithObject:_dataTypes forKey:[NSNumber numberWithInt:GPKG_CDT_TILES]];
    }
    return self;
}

-(enum GPKGDgiwgCoordinateReferenceSystem) type{
    return _type;
}

-(NSString *) authority{
    return _authority;
}

-(int) code{
    return _code;
}

-(NSString *) authorityAndCode{
    return [NSString stringWithFormat:@"%@:%d", _authority, _code];
}

-(NSString *) name{
    return _crsName;
}

-(enum CRSType) crsType{
    return _crsType;
}

-(int) dimension{
    return _dimension;
}

-(NSString *) wkt{
    return _wkt;
}

-(NSString *) theDescription{
    return _theDescription;
}

-(GPKGBoundingBox *) bounds{
    return _bounds;
}

-(GPKGBoundingBox *) wgs84Bounds{
    return _wgs84Bounds;
}

-(NSArray<NSNumber *> *) dataTypes{
    return _dataTypes;
}

-(NSArray<NSString *> *) dataTypeNames{
    NSMutableArray<NSString *> *names = [NSMutableArray array];
    for(NSNumber *dataType in _dataTypes){
        [names addObject:[GPKGDgiwgDataTypes name:[dataType intValue]]];
    }
    return names;
}

-(BOOL) isCRSType: (enum CRSType) type{
    return _crsType == type;
}

-(BOOL) isDataType: (enum GPKGDgiwgDataType) dataType{
    return [_dataTypes containsObject:[NSNumber numberWithInt:dataType]];
}

-(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *) contentsDataTypes{
    return _contentsDataTypes;
}

-(NSArray<NSNumber *> *) tilesDataTypes{
    return [self dataTypes:GPKG_CDT_TILES];
}

-(BOOL) hasTilesDataTypes{
    NSArray<NSNumber *> *tiles = [self tilesDataTypes];
    return tiles != nil && tiles.count > 0;
}

-(NSArray<NSNumber *> *) featuresDataTypes{
    return [self dataTypes:GPKG_CDT_FEATURES];
}

-(BOOL) hasFeaturesDataTypes{
    NSArray<NSNumber *> *features = [self featuresDataTypes];
    return features != nil && features.count > 0;
}

-(NSArray<NSNumber *> *) dataTypes: (enum GPKGContentsDataType) contentsDataType{
    return [_contentsDataTypes objectForKey:[NSNumber numberWithInt:contentsDataType]];
}

-(GPKGSpatialReferenceSystem *) createSpatialReferenceSystem{
    
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];

    [srs setSrsName:_crsName];
    [srs setSrsId:[NSNumber numberWithInt:_code]];
    [srs setOrganization:_authority];
    [srs setOrganizationCoordsysId:[NSNumber numberWithInt:_code]];
    NSString *definition = _wkt;
    if(_crsType == CRS_TYPE_COMPOUND){
        definition = GPKG_UNDEFINED_DEFINITION;
    }
    [srs setDefinition:definition];
    [srs setTheDescription:_theDescription];
    [srs setDefinition_12_063:_wkt];

    return srs;
}

-(GPKGSpatialReferenceSystem *) createTilesSpatialReferenceSystem{
    if(![self hasTilesDataTypes]){
        [NSException raise:@"Invalid Tiles CRS" format:@"CRS is not valid for tiles: %@", [self authorityAndCode]];
    }
    return [self createSpatialReferenceSystem];
}

-(GPKGSpatialReferenceSystem *) createFeaturesSpatialReferenceSystem{
    if(![self hasFeaturesDataTypes]){
        [NSException raise:@"Invalid Features CRS" format:@"CRS is not valid for features: %@", [self authorityAndCode]];
    }
    return [self createSpatialReferenceSystem];
}

+(GPKGSpatialReferenceSystem *) createLambertConicConformal1SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andScaleFactor: (double) scaleFactor andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing{
    
    NSString *definition = [GPKGDgiwgWellKnownText lambertConicConformal1SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:geoDatum andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andScaleFactor:scaleFactor andFalseEasting:falseEasting andFalseNorthing:falseNorthing];
    NSString *description = [GPKGDgiwgWellKnownText lambertConicConformal1SPDescription];

    return [self createLambertConicConformalWithEPSG:epsg andName:name andDefinition:definition andDescription:description];
}

+(GPKGSpatialReferenceSystem *) createLambertConicConformal2SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andStandardParallel1: (double) standardParallel1 andStandardParallel2: (double) standardParallel2 andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing{
    
    NSString *definition = [GPKGDgiwgWellKnownText lambertConicConformal2SPWithEPSG:epsg andName:name andCRS:crsType andGeoDatum:geoDatum andStandardParallel1:standardParallel1 andStandardParallel2:standardParallel2 andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];
    NSString *description = [GPKGDgiwgWellKnownText lambertConicConformal2SPDescription];

    return [self createLambertConicConformalWithEPSG:epsg andName:name andDefinition:definition andDescription:description];
}

/**
 * Create a Lambert Conic Conformal Spatial Reference System
 *
 * @param epsg
 *            Lambert Conic Conformal EPSG
 * @param name
 *            CRS name
 * @param definition
 *            well-known text definition
 * @param description
 *            srs description
 * @return Spatial Reference System
 */
+(GPKGSpatialReferenceSystem *) createLambertConicConformalWithEPSG: (int) epsg andName: (NSString *) name andDefinition: (NSString *) definition andDescription: (NSString *) description{

    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];

    [srs setSrsName:name];
    [srs setSrsId:[NSNumber numberWithInt:epsg]];
    [srs setOrganization:PROJ_AUTHORITY_EPSG];
    [srs setOrganizationCoordsysId:[NSNumber numberWithInt:epsg]];
    [srs setDefinition:definition];
    [srs setTheDescription:description];
    [srs setDefinition_12_063:definition];
    
    return srs;
}

+(GPKGDgiwgCoordinateReferenceSystems *) coordinateReferenceSystemWithEPSG: (int) epsg{
    return [self coordinateReferenceSystemWithAuthority:PROJ_AUTHORITY_EPSG andCode:epsg];
}

+(GPKGDgiwgCoordinateReferenceSystems *) coordinateReferenceSystemWithSRS: (GPKGSpatialReferenceSystem *) srs{
    return [self coordinateReferenceSystemWithAuthority:srs.organization andCode:[srs.organizationCoordsysId intValue]];
}

+(GPKGDgiwgCoordinateReferenceSystems *) coordinateReferenceSystemWithAuthority: (NSString *) authority andCode: (int) code{
    GPKGDgiwgCoordinateReferenceSystems *crs = nil;
    NSMutableDictionary<NSNumber *, GPKGDgiwgCoordinateReferenceSystems *> *codeDictionary = [authorityCodeCRS objectForKey:authority];
    if(codeDictionary != nil){
        crs = [codeDictionary objectForKey:[NSNumber numberWithInt:code]];
    }
    return crs;
}

+(NSArray<GPKGDgiwgCoordinateReferenceSystems *> *) coordinateReferenceSystemsForType: (enum GPKGDgiwgDataType) dataType{
    return [dataTypeCRS objectForKey:[NSNumber numberWithInt:dataType]];
}

+(NSArray<GPKGDgiwgCoordinateReferenceSystems *> *) coordinateReferenceSystemsForContentsType: (enum GPKGContentsDataType) dataType{
    
    NSMutableArray<GPKGDgiwgCoordinateReferenceSystems *> *crss = [NSMutableArray array];
    
    for(NSNumber *dt in [GPKGDgiwgDataTypes dataTypes:dataType]){
        
        NSArray<GPKGDgiwgCoordinateReferenceSystems *> *crs = [dataTypeCRS objectForKey:dt];
        if(crs != nil){
            [crss addObjectsFromArray:crs];
        }
        
    }

    return crss;
}

@end
