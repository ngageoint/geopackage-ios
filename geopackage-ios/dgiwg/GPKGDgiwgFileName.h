//
//  GPKGDgiwgFileName.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Delimiter between elements
 */
extern NSString * const GPKG_DGIWG_FN_DELIMITER_ELEMENTS;

/**
 * Delimiter between words
 */
extern NSString * const GPKG_DGIWG_FN_DELIMITER_WORDS;

/**
 * Delimiter between zoom scale
 */
extern NSString * const GPKG_DGIWG_FN_DELIMITER_SCALE;

/**
 * Version prefix
 */
extern NSString * const GPKG_DGIWG_FN_VERSION_PREFIX;

/**
 * Date format
 */
extern NSString * const GPKG_DGIWG_FN_DATE_FORMAT;

/**
 * DGIWG (Defence Geospatial Information Working Group) GeoPackage File Name
 */
@interface GPKGDgiwgFileName : NSObject

/**
 *  GeoPackage producer
 */
@property (nonatomic, strong) NSString *producer;

/**
 *  Data Product(s)
 */
@property (nonatomic, strong) NSString *dataProduct;

/**
 *  Geographic Coverage Area
 */
@property (nonatomic, strong) NSString *geographicCoverageArea;

/**
 *  Zoom Levels
 */
@property (nonatomic, strong) NSString *zoomLevels;

/**
 *  Version
 */
@property (nonatomic, strong) NSString *version;

/**
 *  GeoPackage Creation Date
 */
@property (nonatomic, strong) NSString *creationDateText;

/**
 *  GeoPackage Creation Date
 */
@property (nonatomic, strong) NSDate *creationDate;

/**
 *  Optional additional elements, for mission or agency specific use
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *additional;

/**
 *  Initialize
 *
 *  @return new file name
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param name GeoPackage file name or path
 *
 *  @return new file name
 */
-(instancetype) initWithName: (NSString *) name;

/**
 * Get the zoom level part 1, max zoom or scale map units
 *
 * @return zoom level part 1
 */
-(NSNumber *) zoomLevel1;

/**
 * Has a zoom level part 1, max zoom or scale map units
 *
 * @return true if has zoom level part 1
 */
-(BOOL) hasZoomLevel1;

/**
 * Get the zoom level part 2, max zoom or scale surface units
 *
 * @return zoom level part 2
 */
-(NSNumber *) zoomLevel2;

/**
 * Has a zoom level part 2, max zoom or scale surface units
 *
 * @return true if has zoom level part 2
 */
-(BOOL) hasZoomLevel2;

/**
 * Set the zoom level range
 *
 * @param minZoom
 *            min zoom level
 * @param maxZoom
 *            max zoom level
 */
-(void) setZoomLevelRangeWithMin: (int) minZoom andMax: (int) maxZoom;

/**
 * Set the zoom level map scale
 *
 * @param mapUnits
 *            scale map units
 * @param surfaceUnits
 *            scale surface units
 */
-(void) setZoomLevelScaleWithMapUnits: (int) mapUnits andSurfaceUnits: (int) surfaceUnits;

/**
 * Get the major version
 *
 * @return major version
 */
-(NSNumber *) majorVersion;

/**
 * Has a major version
 *
 * @return true if has major version
 */
-(BOOL) hasMajorVersion;

/**
 * Get the minor version
 *
 * @return minor version
 */
-(NSNumber *) minorVersion;

/**
 * Has a minor version
 *
 * @return true if has minor version
 */
-(BOOL) hasMinorVersion;

/**
 * Set the version
 *
 * @param majorVersion
 *            major version
 * @param minorVersion
 *            minor version
 */
-(void) setVersionWithMajor: (int) majorVersion andMinor: (int) minorVersion;

/**
 * Has additional elements
 *
 * @return true if has additional elements
 */
-(BOOL) hasAdditional;

/**
 * Add an additional element
 *
 * @param additional
 *            additional element
 */
-(void) addAdditional: (NSString *) additional;

/**
 * Determine if a complete informative file name
 *
 * @return true if informative
 */
-(BOOL) isInformative;

/**
 * Get the file name
 *
 * @return file name
 */
-(NSString *) name;

/**
 * Get the file name with GeoPackage extension
 *
 * @return file name with extension
 */
-(NSString *) nameWithExtension;

/**
 * Replace word delimiters with spaces
 *
 * @param value
 *            delimited value
 * @return space replaced value
 */
-(NSString *) delimitersToSpaces: (NSString *) value;

@end
