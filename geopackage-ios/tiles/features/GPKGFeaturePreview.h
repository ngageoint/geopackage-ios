//
//  GPKGFeaturePreview.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGFeatureTiles.h"

@interface GPKGFeaturePreview : NSObject

/**
 * Manual bounding box query flag for non indexed and empty contents bounds
 * feature tables
 */
@property (nonatomic) BOOL manual;

/**
 * Buffer percentage for drawing empty non features edges (greater than or equal to 0.0 and less than 0.5)
 */
@property (nonatomic) double bufferPercentage;

/**
 * Where clause
 */
@property (nonatomic, strong) NSString *where;

/**
 * Where clause arguments
 */
@property (nonatomic, strong) NSArray *whereArgs;

/**
 * Query feature limit
 */
@property (nonatomic, strong) NSNumber *limit;

/**
 *  Initialize
 *
 *  @param geoPackage  GeoPackage
 *  @param featureTable feature table
 *
 *  @return new feature tile context
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) featureTable;

/**
 *  Initialize
 *
 *  @param geoPackage  GeoPackage
 *  @param featureDao feature DAO
 *
 *  @return new feature tile context
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureDao: (GPKGFeatureDao *) featureDao;

/**
 *  Initialize
 *
 *  @param geoPackage  GeoPackage
 *  @param featureTiles feature tiles
 *
 *  @return new feature tile context
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andFeatureTiles: (GPKGFeatureTiles *) featureTiles;

/**
 * Get the GeoPackage
 *
 * @return GeoPackage
 */
-(GPKGGeoPackage *) geoPackage;

/**
 * Get the feature tiles
 *
 * @return feature tiles
 */
-(GPKGFeatureTiles *) featureTiles;

/**
 * Get the query columns
 *
 * @return columns
 */
-(NSSet<NSString *> *) columns;

/**
 * Add query columns
 *
 * @param columns columns
 */
-(void) addColumns: (NSArray<NSString *> *) columns;

/**
 * Add a query column
 *
 * @param column column
 */
-(void) addColumn: (NSString *) column;

/**
 * Append to the where clause
 *
 * @param where where
 */
-(void) appendWhere: (NSString *) where;

/**
 * Draw a preview image
 *
 * @return preview image
 */
-(UIImage *) draw;

/**
 * Close the feature tiles connection
 */
-(void) close;

@end
