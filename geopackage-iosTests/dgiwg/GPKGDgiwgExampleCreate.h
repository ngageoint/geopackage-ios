//
//  GPKGDgiwgExampleCreate.h
//  geopackage-iosTests
//
//  Created by Brian Osborn on 12/2/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * DGIWG Example Create parts
 */
@interface GPKGDgiwgExampleCreate : NSObject

/**
 *  Create features
 */
@property (nonatomic) BOOL features;

/**
 * Create tiles
 */
@property (nonatomic) BOOL tiles;

/**
 * Create optional national metadata
 */
@property (nonatomic) BOOL nationalMetadata;

/**
 * Create optional features metadata
 */
@property (nonatomic) BOOL featuresMetadata;

/**
 * Create optional tiles metadata
 */
@property (nonatomic) BOOL tilesMetadata;

/**
 * Create schema
 */
@property (nonatomic) BOOL schema;

/**
 * Create coverage data
 */
@property (nonatomic) BOOL coverage;

/**
 * Create related tables media
 */
@property (nonatomic) BOOL relatedMedia;

/**
 * Create related tables tiles
 */
@property (nonatomic) BOOL relatedTiles;

/**
 * Create the base
 *
 * @return create
 */
+(GPKGDgiwgExampleCreate *) base;

/**
 * Create all parts
 *
 * @return create
 */
+(GPKGDgiwgExampleCreate *) all;

/**
 * Create the base
 *
 * @return create
 */
+(GPKGDgiwgExampleCreate *) featuresAndTiles;

/**
 * Create features
 *
 * @return create
 */
+(GPKGDgiwgExampleCreate *) features;

/**
 * Create tiles
 *
 * @return create
 */
+(GPKGDgiwgExampleCreate *) tiles;

/**
 *  Initialize
 *
 *  @return example create
 */
-(instancetype) init;

@end
