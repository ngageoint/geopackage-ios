//
//  GPKGFeatureInfoBuilder.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureDao.h"
#import "GPKGFeatureTableData.h"
#import "GPKGFeatureIndexResults.h"
#import "SFPoint.h"
#import "GPKGMapTolerance.h"

@interface GPKGFeatureInfoBuilder : NSObject

/**
 *  Table name used when building text
 */
@property (nonatomic, strong) NSString * name;

/**
 * Max number of points clicked to return detailed information about
 */
@property (nonatomic) int maxPointDetailedInfo;

/**
 * Max number of features clicked to return detailed information about
 */
@property (nonatomic) int maxFeatureDetailedInfo;

/**
 * Print Point geometries within detailed info when true
 */
@property (nonatomic) BOOL detailedInfoPrintPoints;

/**
 * Print Feature geometries within detailed info when true
 */
@property (nonatomic) BOOL detailedInfoPrintFeatures;

/**
 * Initializer
 *
 * @param featureDao feature dao
 */
-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao;

/**
 *  Get the geometry type
 *
 *  @return geometry type
 */
-(enum SFGeometryType) geometryType;

/**
 * Add a geomtetry type to ignore
 *
 * @param geometryType geometry type
 */
-(void) ignoreGeometryType: (enum SFGeometryType) geometryType;

/**
 *  Build a feature results information message and close the results
 *
 *  @param results feature index results
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results;

/**
 *  Build a feature results information message and close the results
 *
 *  @param results feature index results
 *  @param projection         desired geometry projection
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andProjection: (PROJProjection *) projection;

/**
 *  Build a feature results information message
 *
 *  @param results   feature index results
 *  @param tolerance distance and screen tolerance
 *  @param point     point
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andPoint: (SFPoint *) point;

/**
 *  Build a feature results information message
 *
 *  @param results    feature index results
 *  @param tolerance  distance and screen tolerance
 *  @param point      point
 *  @param projection desired geometry projection
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andPoint: (SFPoint *) point andProjection: (PROJProjection *) projection;

/**
 *  Build a feature results information message
 *
 *  @param results            feature index results
 *  @param tolerance          distance and screen tolerance
 *  @param locationCoordinate location coordinate
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate;

/**
 *  Build a feature results information message
 *
 *  @param results            feature index results
 *  @param tolerance          distance and screen tolerance
 *  @param locationCoordinate location coordinate
 *  @param projection         desired geometry projection
 *
 *  @return results message or null if no results
 */
-(NSString *) buildResultsInfoMessageAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andProjection: (PROJProjection *) projection;

/**
 *  Build feature table data results
 *
 *  @param results   feature index results
 *  @param tolerance distance and screen tolerance
 *  @param point   point
 *
 *  @return feature table data or nil if not results
 */
-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andPoint: (SFPoint *) point;

/**
 *  Build feature table data results
 *
 *  @param results    feature index results
 *  @param tolerance  distance and screen tolerance
 *  @param point      point
 *  @param projection desired geometry projection
 *
 *  @return feature table data or nil if not results
 */
-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andPoint: (SFPoint *) point andProjection: (PROJProjection *) projection;

/**
 *  Build feature table data results
 *
 *  @param results            feature index results
 *  @param tolerance          distance and screen tolerance
 *  @param locationCoordinate location coordinate
 *
 *  @return table data or nil if not results
 */
-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate;

/**
 *  Build feature table data results
 *
 *  @param results            feature index results
 *  @param tolerance          distance and screen tolerance
 *  @param locationCoordinate location coordinate
 *  @param projection         desired geometry projection
 *
 *  @return table data or nil if not results
 */
-(GPKGFeatureTableData *) buildTableDataAndCloseWithFeatureIndexResults: (GPKGFeatureIndexResults *) results andTolerance: (GPKGMapTolerance *) tolerance andLocationCoordinate: (CLLocationCoordinate2D) locationCoordinate andProjection: (PROJProjection *) projection;

@end
