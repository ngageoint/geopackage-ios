//
//  GPKGDgiwgDataTypes.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgDataTypes.h"

@implementation GPKGDgiwgDataTypes

+(enum GPKGContentsDataType) dataType: (enum GPKGDgiwgDataType) dataType{
    enum GPKGContentsDataType type = -1;
    
    switch(dataType){
        case GPKG_DGIWG_DT_FEATURES_2D:
        case GPKG_DGIWG_DT_FEATURES_3D:
            type = GPKG_CDT_FEATURES;
            break;
        case GPKG_DGIWG_DT_TILES_2D:
        case GPKG_DGIWG_DT_TILES_3D:
            type = GPKG_CDT_TILES;
            break;
    }
    
    return type;
}

+(NSString *) name: (enum GPKGDgiwgDataType) dataType{
    NSString *name = nil;
    
    switch(dataType){
        case GPKG_DGIWG_DT_FEATURES_2D:
            name = @"FEATURES_2D";
            break;
        case GPKG_DGIWG_DT_FEATURES_3D:
            name = @"FEATURES_3D";
            break;
        case GPKG_DGIWG_DT_TILES_2D:
            name = @"TILES_2D";
            break;
        case GPKG_DGIWG_DT_TILES_3D:
            name = @"TILES_3D";
            break;
    }
    
    return name;
}

+(int) dimension: (enum GPKGDgiwgDataType) dataType{
    int dimension = -1;
    
    switch(dataType){
        case GPKG_DGIWG_DT_FEATURES_2D:
        case GPKG_DGIWG_DT_TILES_2D:
            dimension = 2;
            break;
        case GPKG_DGIWG_DT_FEATURES_3D:
        case GPKG_DGIWG_DT_TILES_3D:
            dimension = 3;
            break;
    }
    
    return dimension;
}

+(BOOL) isFeatures: (enum GPKGDgiwgDataType) dataType{
    return [self dataType:dataType] == GPKG_CDT_FEATURES;
}

+(BOOL) isTiles: (enum GPKGDgiwgDataType) dataType{
    return [self dataType:dataType] == GPKG_CDT_TILES;
}

+(BOOL) is2D: (enum GPKGDgiwgDataType) dataType{
    return [self dimension:dataType] == 2;
}

+(BOOL) is3D: (enum GPKGDgiwgDataType) dataType{
    return [self dimension:dataType] == 3;
}

+(int) z: (enum GPKGDgiwgDataType) dataType{
    return [self dimension:dataType] - 2;
}

+(NSSet<NSNumber *> *) dataTypes: (enum GPKGContentsDataType) type{
    NSMutableSet<NSNumber *> *types = [NSMutableSet set];
    
    for(int dataType = 0; dataType <= GPKG_DGIWG_DT_TILES_3D; dataType++) {
        if([self dataType:dataType] == type){
            [types addObject:[NSNumber numberWithInt:dataType]];
        }
    }
    
    return types;
}

@end
