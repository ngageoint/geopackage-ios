//
//  GPKGDgiwgRequirements.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/10/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgRequirements.h"

NSString * const GPKG_DGIWG_REQ_GEOPACKAGE_BASE_NAME = @"GeoPackage Base definition";
NSString * const GPKG_DGIWG_REQ_GEOPACKAGE_OPTIONS_NAME = @"GeoPackage Options definition";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY_NAME = @"Mandatory Extensions";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_OPTIONAL_NAME = @"Optional Extensions";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED_NAME = @"Extensions Not Allowed";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_CONDITIONAL_NAME = @"Conditional Extensions";
NSString * const GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED_NAME = @"Raster CRS Allowed";
NSString * const GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET_NAME = @"CRS Raster tile matrix set";
NSString * const GPKG_DGIWG_REQ_CRS_2D_VECTOR_NAME = @"Two-Dimensional Vector CRS";
NSString * const GPKG_DGIWG_REQ_CRS_3D_VECTOR_NAME = @"Three-Dimensional Vector CRS";
NSString * const GPKG_DGIWG_REQ_CRS_WKT_NAME = @"Well Known Text for CRS";
NSString * const GPKG_DGIWG_REQ_CRS_COMPOUND_NAME = @"Compound CRS Usage";
NSString * const GPKG_DGIWG_REQ_CRS_COMPOUND_WKT_NAME = @"Compound CRS Well Known Text";
NSString * const GPKG_DGIWG_REQ_METADATA_DMF_NAME = @"GeoPackage Metadata DMF";
NSString * const GPKG_DGIWG_REQ_METADATA_GPKG_NAME = @"GeoPackage Metadata document";
NSString * const GPKG_DGIWG_REQ_METADATA_ROW_NAME = @"Complete Row GeoPackage Metadata";
NSString * const GPKG_DGIWG_REQ_METADATA_USER_NAME = @"User Row GeoPackage Metadata";
NSString * const GPKG_DGIWG_REQ_METADATA_PRODUCT_NAME = @"GeoPackage Product Metadata";
NSString * const GPKG_DGIWG_REQ_METADATA_PRODUCT_PARTIAL_NAME = @"GeoPackage Product Partial Metadata";
NSString * const GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY_NAME = @"GeoPackage Data Validity";
NSString * const GPKG_DGIWG_REQ_TILE_SIZE_MATRIX_NAME = @"Tile Matrix Width Height";
NSString * const GPKG_DGIWG_REQ_TILE_SIZE_DATA_NAME = @"Tile Pyramid Width Height";
NSString * const GPKG_DGIWG_REQ_ZOOM_FACTOR_NAME = @"Zoom level factor";
NSString * const GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE_NAME = @"Tile Matrix Set with Multiple Zoom Levels";
NSString * const GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_ONE_NAME = @"Tile Matrix Set with one Zoom Level";
NSString * const GPKG_DGIWG_REQ_BBOX_CRS_NAME = @"Tile Matrix Set CRS Bounding box";
NSString * const GPKG_DGIWG_REQ_METADATA_TILE_NAME = @"Tile layer Metadata";
NSString * const GPKG_DGIWG_REQ_METADATA_FEATURE_NAME = @"Feature layer Metadata";

NSString * const GPKG_DGIWG_REQ_GEOPACKAGE_BASE_IDENTIFIER = @"geopackage/base";
NSString * const GPKG_DGIWG_REQ_GEOPACKAGE_OPTIONS_IDENTIFIER = @"geopackage/options";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY_IDENTIFIER = @"extensions/mandatory";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_OPTIONAL_IDENTIFIER = @"extensions/optional";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED_IDENTIFIER = @"extensions/not-allowed";
NSString * const GPKG_DGIWG_REQ_EXTENSIONS_CONDITIONAL_IDENTIFIER = @"extensions/conditional";
NSString * const GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED_IDENTIFIER = @"crs/raster-allowed";
NSString * const GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET_IDENTIFIER = @"crs/raster-tile-matrix-set";
NSString * const GPKG_DGIWG_REQ_CRS_2D_VECTOR_IDENTIFIER = @"crs/2d-vector";
NSString * const GPKG_DGIWG_REQ_CRS_3D_VECTOR_IDENTIFIER = @"crs/3d-vector";
NSString * const GPKG_DGIWG_REQ_CRS_WKT_IDENTIFIER = @"crs/wkt";
NSString * const GPKG_DGIWG_REQ_CRS_COMPOUND_IDENTIFIER = @"crs/compound";
NSString * const GPKG_DGIWG_REQ_CRS_COMPOUND_WKT_IDENTIFIER = @"crs/compound-wkt";
NSString * const GPKG_DGIWG_REQ_METADATA_DMF_IDENTIFIER = @"metadata/dmf";
NSString * const GPKG_DGIWG_REQ_METADATA_GPKG_IDENTIFIER = @"metadata/gpkg";
NSString * const GPKG_DGIWG_REQ_METADATA_ROW_IDENTIFIER = @"metadata/row";
NSString * const GPKG_DGIWG_REQ_METADATA_USER_IDENTIFIER = @"metadata/user";
NSString * const GPKG_DGIWG_REQ_METADATA_PRODUCT_IDENTIFIER = @"metadata/product";
NSString * const GPKG_DGIWG_REQ_METADATA_PRODUCT_PARTIAL_IDENTIFIER = @"metadata/product-partial";
NSString * const GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY_IDENTIFIER = @"validity/data-validity";
NSString * const GPKG_DGIWG_REQ_TILE_SIZE_MATRIX_IDENTIFIER = @"tile/size-matrix";
NSString * const GPKG_DGIWG_REQ_TILE_SIZE_DATA_IDENTIFIER = @"tile/size-data";
NSString * const GPKG_DGIWG_REQ_ZOOM_FACTOR_IDENTIFIER = @"zoom/factor";
NSString * const GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE_IDENTIFIER = @"zoom/matrix-sets-multiple";
NSString * const GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_ONE_IDENTIFIER = @"zoom/matrix-sets-one";
NSString * const GPKG_DGIWG_REQ_BBOX_CRS_IDENTIFIER = @"bbox/crs";
NSString * const GPKG_DGIWG_REQ_METADATA_TILE_IDENTIFIER = @"metadata/tile";
NSString * const GPKG_DGIWG_REQ_METADATA_FEATURE_IDENTIFIER = @"metadata/feature";

NSString * const GPKG_DGIWG_REQ_IDENTIFIER_PREFIX = @"/req/";

@implementation GPKGDgiwgRequirements

+(int) number: (enum GPKGDgiwgRequirement) requirement{
    return requirement + 1;
}

+(NSString *) name: (enum GPKGDgiwgRequirement) requirement{
    NSString *name = nil;
    
    switch(requirement){
        case GPKG_DGIWG_REQ_GEOPACKAGE_BASE:
            name = GPKG_DGIWG_REQ_GEOPACKAGE_BASE_NAME;
            break;
        case GPKG_DGIWG_REQ_GEOPACKAGE_OPTIONS:
            name = GPKG_DGIWG_REQ_GEOPACKAGE_OPTIONS_NAME;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY:
            name = GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY_NAME;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_OPTIONAL:
            name = GPKG_DGIWG_REQ_EXTENSIONS_OPTIONAL_NAME;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED:
            name = GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED_NAME;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_CONDITIONAL:
            name = GPKG_DGIWG_REQ_EXTENSIONS_CONDITIONAL_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED:
            name = GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET:
            name = GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_2D_VECTOR:
            name = GPKG_DGIWG_REQ_CRS_2D_VECTOR_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_3D_VECTOR:
            name = GPKG_DGIWG_REQ_CRS_3D_VECTOR_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_WKT:
            name = GPKG_DGIWG_REQ_CRS_WKT_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_COMPOUND:
            name = GPKG_DGIWG_REQ_CRS_COMPOUND_NAME;
            break;
        case GPKG_DGIWG_REQ_CRS_COMPOUND_WKT:
            name = GPKG_DGIWG_REQ_CRS_COMPOUND_WKT_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_DMF:
            name = GPKG_DGIWG_REQ_METADATA_DMF_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_GPKG:
            name = GPKG_DGIWG_REQ_METADATA_GPKG_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_ROW:
            name = GPKG_DGIWG_REQ_METADATA_ROW_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_USER:
            name = GPKG_DGIWG_REQ_METADATA_USER_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_PRODUCT:
            name = GPKG_DGIWG_REQ_METADATA_PRODUCT_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_PRODUCT_PARTIAL:
            name = GPKG_DGIWG_REQ_METADATA_PRODUCT_PARTIAL_NAME;
            break;
        case GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY:
            name = GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY_NAME;
            break;
        case GPKG_DGIWG_REQ_TILE_SIZE_MATRIX:
            name = GPKG_DGIWG_REQ_TILE_SIZE_MATRIX_NAME;
            break;
        case GPKG_DGIWG_REQ_TILE_SIZE_DATA:
            name = GPKG_DGIWG_REQ_TILE_SIZE_DATA_NAME;
            break;
        case GPKG_DGIWG_REQ_ZOOM_FACTOR:
            name = GPKG_DGIWG_REQ_ZOOM_FACTOR_NAME;
            break;
        case GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE:
            name = GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE_NAME;
            break;
        case GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_ONE:
            name = GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_ONE_NAME;
            break;
        case GPKG_DGIWG_REQ_BBOX_CRS:
            name = GPKG_DGIWG_REQ_BBOX_CRS_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_TILE:
            name = GPKG_DGIWG_REQ_METADATA_TILE_NAME;
            break;
        case GPKG_DGIWG_REQ_METADATA_FEATURE:
            name = GPKG_DGIWG_REQ_METADATA_FEATURE_NAME;
            break;
    }
    
    return name;
}

+(NSString *) identifier: (enum GPKGDgiwgRequirement) requirement{
    NSString *identifier = nil;
    
    switch(requirement){
        case GPKG_DGIWG_REQ_GEOPACKAGE_BASE:
            identifier = GPKG_DGIWG_REQ_GEOPACKAGE_BASE_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_GEOPACKAGE_OPTIONS:
            identifier = GPKG_DGIWG_REQ_GEOPACKAGE_OPTIONS_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY:
            identifier = GPKG_DGIWG_REQ_EXTENSIONS_MANDATORY_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_OPTIONAL:
            identifier = GPKG_DGIWG_REQ_EXTENSIONS_OPTIONAL_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED:
            identifier = GPKG_DGIWG_REQ_EXTENSIONS_NOT_ALLOWED_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_EXTENSIONS_CONDITIONAL:
            identifier = GPKG_DGIWG_REQ_EXTENSIONS_CONDITIONAL_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED:
            identifier = GPKG_DGIWG_REQ_CRS_RASTER_ALLOWED_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET:
            identifier = GPKG_DGIWG_REQ_CRS_RASTER_TILE_MATRIX_SET_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_2D_VECTOR:
            identifier = GPKG_DGIWG_REQ_CRS_2D_VECTOR_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_3D_VECTOR:
            identifier = GPKG_DGIWG_REQ_CRS_3D_VECTOR_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_WKT:
            identifier = GPKG_DGIWG_REQ_CRS_WKT_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_COMPOUND:
            identifier = GPKG_DGIWG_REQ_CRS_COMPOUND_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_CRS_COMPOUND_WKT:
            identifier = GPKG_DGIWG_REQ_CRS_COMPOUND_WKT_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_DMF:
            identifier = GPKG_DGIWG_REQ_METADATA_DMF_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_GPKG:
            identifier = GPKG_DGIWG_REQ_METADATA_GPKG_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_ROW:
            identifier = GPKG_DGIWG_REQ_METADATA_ROW_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_USER:
            identifier = GPKG_DGIWG_REQ_METADATA_USER_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_PRODUCT:
            identifier = GPKG_DGIWG_REQ_METADATA_PRODUCT_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_PRODUCT_PARTIAL:
            identifier = GPKG_DGIWG_REQ_METADATA_PRODUCT_PARTIAL_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY:
            identifier = GPKG_DGIWG_REQ_VALIDITY_DATA_VALIDITY_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_TILE_SIZE_MATRIX:
            identifier = GPKG_DGIWG_REQ_TILE_SIZE_MATRIX_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_TILE_SIZE_DATA:
            identifier = GPKG_DGIWG_REQ_TILE_SIZE_DATA_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_ZOOM_FACTOR:
            identifier = GPKG_DGIWG_REQ_ZOOM_FACTOR_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE:
            identifier = GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_MULTIPLE_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_ONE:
            identifier = GPKG_DGIWG_REQ_ZOOM_MATRIX_SETS_ONE_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_BBOX_CRS:
            identifier = GPKG_DGIWG_REQ_BBOX_CRS_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_TILE:
            identifier = GPKG_DGIWG_REQ_METADATA_TILE_IDENTIFIER;
            break;
        case GPKG_DGIWG_REQ_METADATA_FEATURE:
            identifier = GPKG_DGIWG_REQ_METADATA_FEATURE_IDENTIFIER;
            break;
    }
    
    return identifier;
}

+(NSString *) fullIdentifier: (enum GPKGDgiwgRequirement) requirement{
    return [NSString stringWithFormat:@"%@%@", GPKG_DGIWG_REQ_IDENTIFIER_PREFIX, [self identifier:requirement]];
}

+(NSString *) description: (enum GPKGDgiwgRequirement) requirement{
    NSMutableString *description = [NSMutableString alloc];
    [description appendFormat:@"Number: %d", [self number:requirement]];
    [description appendFormat:@", Name: %@", [self name:requirement]];
    [description appendFormat:@", Identifier: %@", [self fullIdentifier:requirement]];
    return description;
}

@end
