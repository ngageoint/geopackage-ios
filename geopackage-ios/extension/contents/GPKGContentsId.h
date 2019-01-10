//
//  GPKGContentsId.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"

/**
 *  Contents Id table constants
 */
extern NSString * const GPKG_CI_TABLE_NAME;
extern NSString * const GPKG_CI_COLUMN_PK;
extern NSString * const GPKG_CI_COLUMN_ID;
extern NSString * const GPKG_CI_COLUMN_TABLE_NAME;

@interface GPKGContentsId : NSObject <NSMutableCopying>

/**
 * Id primary key
 */
@property (nonatomic, strong) NSNumber *id;

/**
 *  Foreign key to Contents by table name
 */
@property (nonatomic, strong) GPKGContents *contents;

/**
 * The name of the actual content table, foreign key to gpkg_contents
 */
@property (nonatomic, strong) NSString *tableName;

/**
 *  Initialize
 *
 *  @return new contents id
 */
-(instancetype) init;

@end

