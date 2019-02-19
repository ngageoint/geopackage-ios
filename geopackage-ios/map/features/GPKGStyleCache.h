//
//  GPKGStyleCache.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureStyleExtension.h"
#import "GPKGIconCache.h"
#import "GPKGMapPoint.h"

/**
 * Style utilities for populating points and shapes. Caches icons for a single GeoPackage
 */
@interface GPKGStyleCache : NSObject

/**
 * Screen scale, see [UIScreen mainScreen].scale
 */
@property (nonatomic) float scale;

/**
 * Initialize
 *
 * @param geoPackage GeoPackage
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Initialize
 *
 * @param geoPackage GeoPackage
 * @param scale      screen scale, see [UIScreen mainScreen].scale
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andScale: (float) scale;

/**
 * Initialize
 *
 * @param geoPackage    GeoPackage
 * @param iconCacheSize number of icon images to cache
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andIconCacheSize: (int) iconCacheSize;

/**
 * Initialize
 *
 * @param geoPackage    GeoPackage
 * @param scale         screen scale, see [UIScreen mainScreen].scale
 * @param iconCacheSize number of icon images to cache
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andScale: (float) scale andIconCacheSize: (int) iconCacheSize;

/**
 * Initialize
 *
 * @param featureStyleExtension feature style extension
 */
-(instancetype) initWithExtension: (GPKGFeatureStyleExtension *) featureStyleExtension;

/**
 * Initialize
 *
 * @param featureStyleExtension feature style extension
 * @param scale                 screen scale, see [UIScreen mainScreen].scale
 */
-(instancetype) initWithExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andScale: (float) scale;

/**
 * Initialize
 *
 * @param featureStyleExtension feature style extension
 * @param iconCacheSize         number of icon bitmaps to cache
 */
-(instancetype) initWithExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andIconCacheSize: (int) iconCacheSize;

/**
 * Initialize
 *
 * @param featureStyleExtension feature style extension
 * @param scale                 screen scale, see [UIScreen mainScreen].scale
 * @param iconCacheSize         number of icon bitmaps to cache
 */
-(instancetype) initWithExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andScale: (float) scale andIconCacheSize: (int) iconCacheSize;

/**
 * Clear the cache
 */
-(void) clear;

/**
 * Get the feature style extension
 *
 * @return feature style extension
 */
-(GPKGFeatureStyleExtension *) featureStyleExtension;

/**
 * Set the feature row style (icon or style) into the map point
 *
 * @param mapPoint      map point
 * @param featureRow    feature row
 * @return true if icon or style was set into the map point
 */
-(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature style (icon or style) into the marker options
 *
 * @param markerOptions marker options
 * @param featureStyle  feature style
 * @return true if icon or style was set into the marker options
 */
-(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the icon into the marker options
 *
 * @param markerOptions marker options
 * @param icon          icon row
 * @return true if icon was set into the marker options
 */
-(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon;

/**
 * Create the icon bitmap
 *
 * @param icon icon row
 * @return icon bitmap
 */
-(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon;

/**
 * Set the style into the marker options
 *
 * @param markerOptions marker options
 * @param style         style row
 * @return true if style was set into the marker options
 */
-(BOOL) setStyleWithMapPoint: (GPKGMapPoint *) mapPoint andStyle: (GPKGStyleRow *) style;

@end
