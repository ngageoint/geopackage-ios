//
//  GPKGStyleUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/18/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGMapPoint.h"
#import "GPKGIconCache.h"
#import "GPKGFeatureStyleExtension.h"
#import "GPKGPolyline.h"
#import "GPKGPolygon.h"

/**
 * Style utilities for populating points and shapes
 */
@interface GPKGStyleUtils : NSObject

/**
 * Set the feature row style (icon or style) into the map point
 *
 * @param mapPoint      map point
 * @param geoPackage    GeoPackage
 * @param featureRow    feature row
 * @return true if icon or style was set into the map point
 */
+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature row style (icon or style) into the map point
 *
 * @param mapPoint      map point
 * @param geoPackage    GeoPackage
 * @param featureRow    feature row
 * @param iconCache     icon cache
 * @return true if icon or style was set into the map point
 */
+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow andIconCache: (GPKGIconCache *) iconCache;

/**
 * Set the feature row style (icon or style) into the map point
 *
 * @param mapPoint              map point
 * @param featureStyleExtension feature style extension
 * @param featureRow            feature row
 * @return true if icon or style was set into the map point
 */
+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature row style (icon or style) into the map point
 *
 * @param mapPoint              map point
 * @param featureStyleExtension feature style extension
 * @param featureRow            feature row
 * @param iconCache             icon cache
 * @return true if icon or style was set into the map point
 */
+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow andIconCache: (GPKGIconCache *) iconCache;

/**
 * Set the feature style (icon or style) into the map point
 *
 * @param mapPoint      map point
 * @param featureStyle  feature style
 * @return true if icon or style was set into the map point
 */
+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the feature style (icon or style) into the map point
 *
 * @param mapPoint      map point
 * @param featureStyle  feature style
 * @param iconCache     icon cache
 * @return true if icon or style was set into the map point
 */
+(BOOL) setFeatureStyleWithMapPoint: (GPKGMapPoint *) mapPoint andFeatureStyle: (GPKGFeatureStyle *) featureStyle andIconCache: (GPKGIconCache *) iconCache;

/**
 * Set the icon into the map point
 *
 * @param mapPoint      map point
 * @param icon          icon row
 * @return true if icon was set into the map point
 */
+(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon;

/**
 * Set the icon into the map point
 *
 * @param mapPoint      map point
 * @param icon          icon row
 * @param iconCache     icon cache
 * @return true if icon was set into the map point
 */
+(BOOL) setIconWithMapPoint: (GPKGMapPoint *) mapPoint andIcon: (GPKGIconRow *) icon andIconCache: (GPKGIconCache *) iconCache;

/**
 * Create the icon image
 *
 * @param icon    icon row
 * @return icon image
 */
+(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon;

/**
 * Create the icon image
 *
 * @param icon      icon row
 * @param iconCache icon cache
 * @return icon image
 */
+(UIImage *) createIconImageWithIcon: (GPKGIconRow *) icon andIconCache: (GPKGIconCache *) iconCache;

/**
 * Set the style into the marker point
 *
 * @param mapPoint      map point
 * @param style         style row
 * @return true if style was set into the marker point
 */
+(BOOL) setStyleWithMapPoint: (GPKGMapPoint *) mapPoint andStyle: (GPKGStyleRow *) style;

/**
 * Set the feature row style into the polyline
 *
 * @param polyline   polyline
 * @param geoPackage GeoPackage
 * @param featureRow feature row
 * @return true if style was set into the polyline
 */
+(BOOL) setFeatureStyleWithPolyline: (GPKGPolyline *) polyline andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature row style into the polyline
 *
 * @param polyline              polyline
 * @param featureStyleExtension feature style extension
 * @param featureRow            feature row
 * @return true if style was set into the polyline
 */
+(BOOL) setFeatureStyleWithPolyline: (GPKGPolyline *) polyline andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature style into the polyline
 *
 * @param polyline     polyline
 * @param featureStyle feature style
 * @return true if style was set into the polyline
 */
+(BOOL) setFeatureStyleWithPolyline: (GPKGPolyline *) polyline andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the style into the polyline
 *
 * @param polyline polyline
 * @param style    style row
 * @return true if style was set into the polyline
 */
+(BOOL) setStyleWithPolyline: (GPKGPolyline *) polyline andStyle: (GPKGStyleRow *) style;

/**
 * Set the feature row style into the polygon
 *
 * @param polygon    polygon
 * @param geoPackage GeoPackage
 * @param featureRow feature row
 * @return true if style was set into the polygon
 */
+(BOOL) setFeatureStyleWithPolygon: (GPKGPolygon *) polygon andGeoPackage: (GPKGGeoPackage *) geoPackage andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature row style into the polygon
 *
 * @param polygon               polygon
 * @param featureStyleExtension feature style extension
 * @param featureRow            feature row
 * @return true if style was set into the polygon
 */
+(BOOL) setFeatureStyleWithPolygon: (GPKGPolygon *) polygon andExtension: (GPKGFeatureStyleExtension *) featureStyleExtension andFeature: (GPKGFeatureRow *) featureRow;

/**
 * Set the feature style into the polygon
 *
 * @param polygon      polygon
 * @param featureStyle feature style
 * @return true if style was set into the polygon
 */
+(BOOL) setFeatureStyleWithPolygon: (GPKGPolygon *) polygon andFeatureStyle: (GPKGFeatureStyle *) featureStyle;

/**
 * Set the style into the polygon
 *
 * @param polygon polygon
 * @param style   style row
 * @return true if style was set into the polygon
 */
+(BOOL) setStyleWithPolygon: (GPKGPolygon *) polygon andStyle: (GPKGStyleRow *) style;

@end
