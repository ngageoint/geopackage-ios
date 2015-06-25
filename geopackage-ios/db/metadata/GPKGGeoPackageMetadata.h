//
//  GPKGGeoPackageMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GPKG_GPM_TABLE_NAME;
extern NSString * const GPKG_GPM_COLUMN_PK;
extern NSString * const GPKG_GPM_COLUMN_ID;
extern NSString * const GPKG_GPM_COLUMN_NAME;
extern NSString * const GPKG_GPM_COLUMN_PATH;

@interface GPKGGeoPackageMetadata : NSObject

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;

@end
