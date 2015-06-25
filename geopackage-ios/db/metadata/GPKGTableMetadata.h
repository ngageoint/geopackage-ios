//
//  GPKGTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/24/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GPKG_GPTM_TABLE_NAME;
extern NSString * const GPKG_GPTM_COLUMN_PK1;
extern NSString * const GPKG_GPTM_COLUMN_PK2;
extern NSString * const GPKG_GPTM_COLUMN_GEOPACKAGE_ID;
extern NSString * const GPKG_GPTM_COLUMN_TABLE_NAME;
extern NSString * const GPKG_GPTM_COLUMN_LAST_INDEXED;

@interface GPKGTableMetadata : NSObject

@property (nonatomic, strong) NSNumber *geoPackageId;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSDate *lastIndexed;

@end
