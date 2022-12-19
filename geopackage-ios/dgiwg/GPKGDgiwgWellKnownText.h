//
//  GPKGDgiwgWellKnownText.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "CRSGeoDatums.h"
#import "CRSTypes.h"

extern NSString * const GPKG_DGIWG_RESOURCES_WKT;

/**
 * DGIWG (Defence Geospatial Information Working Group) Well-Known Text
 * constants
 */
@interface GPKGDgiwgWellKnownText : NSObject

/**
 * ETRS89-extended / LAEA Europe
 */
+(NSString *) epsg3035;

/**
 * WGS 84 / World Mercator
 */
+(NSString *) epsg3395;

/**
 * EGM2008 geoid height
 */
+(NSString *) epsg3855;

/**
 * WGS 84 / Pseudo-Mercator
 */
+(NSString *) epsg3857;

/**
 * NAD83 / Canada Atlas Lambert
 */
+(NSString *) epsg3978;

/**
 * WGS 84 Geographic 2D
 */
+(NSString *) epsg4326;

/**
 * WGS 84 Geographic 3D
 */
+(NSString *) epsg4979;

/**
 * WGS 84 / UPS North (E,N)
 */
+(NSString *) epsg5041;

/**
 * WGS 84 / UPS South (E,N)
 */
+(NSString *) epsg5042;

/**
 * WGS84 4326 + EGM2008 height 3855
 */
+(NSString *) epsg9518;

/**
 * Get the UTM Zone Well-Known Text
 *
 * @param epsg
 *            UTM Zone EPSG
 * @return UTM Zone Well-Known Text
 */
+(NSString *) utmZone: (int) epsg;

/**
 * Get Lambert Conic Conformal 1SP well-known text
 *
 * @param epsg
 *            Lambert Conic Conformal 1SP EPSG
 * @param name
 *            CRS name
 * @param crsType
 *            CRS type
 * @param geoDatum
 *            WGS84, ETRS89, or NAD83
 * @param latitudeOfOrigin
 *            latitude of origin
 * @param centralMeridian
 *            central meridian
 * @param scaleFactor
 *            scale factor
 * @param falseEasting
 *            false easting
 * @param falseNorthing
 *            false northing
 * @return well-known text
 */
+(NSString *) lambertConicConformal1SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andScaleFactor: (double) scaleFactor andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing;

/**
 * Get Lambert Conic Conformal 2SP well-known text
 *
 * @param epsg
 *            Lambert Conic Conformal 2SP EPSG
 * @param name
 *            CRS name
 * @param crsType
 *            CRS type
 * @param geoDatum
 *            WGS84, ETRS89, or NAD83
 * @param standardParallel1
 *            standard parallel 1
 * @param standardParallel2
 *            standard parallel 2
 * @param latitudeOfOrigin
 *            latitude of origin
 * @param centralMeridian
 *            central meridian
 * @param falseEasting
 *            false easting
 * @param falseNorthing
 *            false northing
 * @return well-known text
 */
+(NSString *) lambertConicConformal2SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andStandardParallel1: (double) standardParallel1 andStandardParallel2: (double) standardParallel2 andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing;

/**
 * Get Lambert Conic Conformal 1SP description
 */
+(NSString *) lambertConicConformal1SPDescription;

/**
 * Get Lambert Conic Conformal 2SP description
 */
+(NSString *) lambertConicConformal2SPDescription;

@end
