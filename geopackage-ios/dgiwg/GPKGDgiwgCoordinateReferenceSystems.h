//
//  GPKGDgiwgCoordinateReferenceSystems.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgDataTypes.h"
#import "GPKGBoundingBox.h"
#import "GPKGSpatialReferenceSystem.h"
#import "CRSGeoDatums.h"

/**
 * DGIWG (Defence Geospatial Information Working Group) Coordinate Reference
 * Systems
 */
enum GPKGDgiwgCoordinateReferenceSystem{
    GPKG_DGIWG_CRS_EPSG_3035,
    GPKG_DGIWG_CRS_EPSG_3395,
    GPKG_DGIWG_CRS_EPSG_3857,
    GPKG_DGIWG_CRS_EPSG_3978,
    GPKG_DGIWG_CRS_EPSG_4326,
    GPKG_DGIWG_CRS_EPSG_4979,
    GPKG_DGIWG_CRS_EPSG_5041,
    GPKG_DGIWG_CRS_EPSG_5042,
    GPKG_DGIWG_CRS_EPSG_9518,
    GPKG_DGIWG_CRS_EPSG_32601,
    GPKG_DGIWG_CRS_EPSG_32602,
    GPKG_DGIWG_CRS_EPSG_32603,
    GPKG_DGIWG_CRS_EPSG_32604,
    GPKG_DGIWG_CRS_EPSG_32605,
    GPKG_DGIWG_CRS_EPSG_32606,
    GPKG_DGIWG_CRS_EPSG_32607,
    GPKG_DGIWG_CRS_EPSG_32608,
    GPKG_DGIWG_CRS_EPSG_32609,
    GPKG_DGIWG_CRS_EPSG_32610,
    GPKG_DGIWG_CRS_EPSG_32611,
    GPKG_DGIWG_CRS_EPSG_32612,
    GPKG_DGIWG_CRS_EPSG_32613,
    GPKG_DGIWG_CRS_EPSG_32614,
    GPKG_DGIWG_CRS_EPSG_32615,
    GPKG_DGIWG_CRS_EPSG_32616,
    GPKG_DGIWG_CRS_EPSG_32617,
    GPKG_DGIWG_CRS_EPSG_32618,
    GPKG_DGIWG_CRS_EPSG_32619,
    GPKG_DGIWG_CRS_EPSG_32620,
    GPKG_DGIWG_CRS_EPSG_32621,
    GPKG_DGIWG_CRS_EPSG_32622,
    GPKG_DGIWG_CRS_EPSG_32623,
    GPKG_DGIWG_CRS_EPSG_32624,
    GPKG_DGIWG_CRS_EPSG_32625,
    GPKG_DGIWG_CRS_EPSG_32626,
    GPKG_DGIWG_CRS_EPSG_32627,
    GPKG_DGIWG_CRS_EPSG_32628,
    GPKG_DGIWG_CRS_EPSG_32629,
    GPKG_DGIWG_CRS_EPSG_32630,
    GPKG_DGIWG_CRS_EPSG_32631,
    GPKG_DGIWG_CRS_EPSG_32632,
    GPKG_DGIWG_CRS_EPSG_32633,
    GPKG_DGIWG_CRS_EPSG_32634,
    GPKG_DGIWG_CRS_EPSG_32635,
    GPKG_DGIWG_CRS_EPSG_32636,
    GPKG_DGIWG_CRS_EPSG_32637,
    GPKG_DGIWG_CRS_EPSG_32638,
    GPKG_DGIWG_CRS_EPSG_32639,
    GPKG_DGIWG_CRS_EPSG_32640,
    GPKG_DGIWG_CRS_EPSG_32641,
    GPKG_DGIWG_CRS_EPSG_32642,
    GPKG_DGIWG_CRS_EPSG_32643,
    GPKG_DGIWG_CRS_EPSG_32644,
    GPKG_DGIWG_CRS_EPSG_32645,
    GPKG_DGIWG_CRS_EPSG_32646,
    GPKG_DGIWG_CRS_EPSG_32647,
    GPKG_DGIWG_CRS_EPSG_32648,
    GPKG_DGIWG_CRS_EPSG_32649,
    GPKG_DGIWG_CRS_EPSG_32650,
    GPKG_DGIWG_CRS_EPSG_32651,
    GPKG_DGIWG_CRS_EPSG_32652,
    GPKG_DGIWG_CRS_EPSG_32653,
    GPKG_DGIWG_CRS_EPSG_32654,
    GPKG_DGIWG_CRS_EPSG_32655,
    GPKG_DGIWG_CRS_EPSG_32656,
    GPKG_DGIWG_CRS_EPSG_32657,
    GPKG_DGIWG_CRS_EPSG_32658,
    GPKG_DGIWG_CRS_EPSG_32659,
    GPKG_DGIWG_CRS_EPSG_32660,
    GPKG_DGIWG_CRS_EPSG_32701,
    GPKG_DGIWG_CRS_EPSG_32702,
    GPKG_DGIWG_CRS_EPSG_32703,
    GPKG_DGIWG_CRS_EPSG_32704,
    GPKG_DGIWG_CRS_EPSG_32705,
    GPKG_DGIWG_CRS_EPSG_32706,
    GPKG_DGIWG_CRS_EPSG_32707,
    GPKG_DGIWG_CRS_EPSG_32708,
    GPKG_DGIWG_CRS_EPSG_32709,
    GPKG_DGIWG_CRS_EPSG_32710,
    GPKG_DGIWG_CRS_EPSG_32711,
    GPKG_DGIWG_CRS_EPSG_32712,
    GPKG_DGIWG_CRS_EPSG_32713,
    GPKG_DGIWG_CRS_EPSG_32714,
    GPKG_DGIWG_CRS_EPSG_32715,
    GPKG_DGIWG_CRS_EPSG_32716,
    GPKG_DGIWG_CRS_EPSG_32717,
    GPKG_DGIWG_CRS_EPSG_32718,
    GPKG_DGIWG_CRS_EPSG_32719,
    GPKG_DGIWG_CRS_EPSG_32720,
    GPKG_DGIWG_CRS_EPSG_32721,
    GPKG_DGIWG_CRS_EPSG_32722,
    GPKG_DGIWG_CRS_EPSG_32723,
    GPKG_DGIWG_CRS_EPSG_32724,
    GPKG_DGIWG_CRS_EPSG_32725,
    GPKG_DGIWG_CRS_EPSG_32726,
    GPKG_DGIWG_CRS_EPSG_32727,
    GPKG_DGIWG_CRS_EPSG_32728,
    GPKG_DGIWG_CRS_EPSG_32729,
    GPKG_DGIWG_CRS_EPSG_32730,
    GPKG_DGIWG_CRS_EPSG_32731,
    GPKG_DGIWG_CRS_EPSG_32732,
    GPKG_DGIWG_CRS_EPSG_32733,
    GPKG_DGIWG_CRS_EPSG_32734,
    GPKG_DGIWG_CRS_EPSG_32735,
    GPKG_DGIWG_CRS_EPSG_32736,
    GPKG_DGIWG_CRS_EPSG_32737,
    GPKG_DGIWG_CRS_EPSG_32738,
    GPKG_DGIWG_CRS_EPSG_32739,
    GPKG_DGIWG_CRS_EPSG_32740,
    GPKG_DGIWG_CRS_EPSG_32741,
    GPKG_DGIWG_CRS_EPSG_32742,
    GPKG_DGIWG_CRS_EPSG_32743,
    GPKG_DGIWG_CRS_EPSG_32744,
    GPKG_DGIWG_CRS_EPSG_32745,
    GPKG_DGIWG_CRS_EPSG_32746,
    GPKG_DGIWG_CRS_EPSG_32747,
    GPKG_DGIWG_CRS_EPSG_32748,
    GPKG_DGIWG_CRS_EPSG_32749,
    GPKG_DGIWG_CRS_EPSG_32750,
    GPKG_DGIWG_CRS_EPSG_32751,
    GPKG_DGIWG_CRS_EPSG_32752,
    GPKG_DGIWG_CRS_EPSG_32753,
    GPKG_DGIWG_CRS_EPSG_32754,
    GPKG_DGIWG_CRS_EPSG_32755,
    GPKG_DGIWG_CRS_EPSG_32756,
    GPKG_DGIWG_CRS_EPSG_32757,
    GPKG_DGIWG_CRS_EPSG_32758,
    GPKG_DGIWG_CRS_EPSG_32759,
    GPKG_DGIWG_CRS_EPSG_32760
};

/**
 * Coordinate Reference Systems
 */
@interface GPKGDgiwgCoordinateReferenceSystems : NSObject

/**
 * Get a CRS by type
 *
 * @param type
 *            CRS type
 * @return CRS
 */
+(GPKGDgiwgCoordinateReferenceSystems *) fromType: (enum GPKGDgiwgCoordinateReferenceSystem) type;

/**
 * Get the type
 *
 * @return type
 */
-(enum GPKGDgiwgCoordinateReferenceSystem) type;

/**
 * Get the authority
 *
 * @return authority
 */
-(NSString *) authority;

/**
 * Get the code
 *
 * @return code
 */
-(int) code;

/**
 * Get the authority and code
 *
 * @return authority:code
 */
-(NSString *) authorityAndCode;

/**
 * Get the name
 *
 * @return name
 */
-(NSString *) name;

/**
 * Get the CRS type
 *
 * @return CRS type
 */
-(enum CRSType) crsType;

/**
 * Get the dimension
 *
 * @return dimension
 */
-(int) dimension;

/**
 * Get the Well-Known Text
 *
 * @return well-known text
 */
-(NSString *) wkt;

/**
 * Get the description
 *
 * @return description
 */
-(NSString *) theDescription;

/**
 * Get the bounds
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) bounds;

/**
 * Get the WGS84 bounds extent
 *
 * @return bounding box
 */
-(GPKGBoundingBox *) wgs84Bounds;

/**
 * Get the data types
 *
 * @return data types
 */
-(NSArray<NSNumber *> *) dataTypes;

/**
 * Get the data type names
 *
 * @return data type names
 */
-(NSArray<NSString *> *) dataTypeNames;

/**
 * Is the CRS Type
 *
 * @param type
 *            crs type
 * @return true if type
 */
-(BOOL) isCRSType: (enum CRSType) type;

/**
 * Is valid for the Data Type
 *
 * @param dataType
 *            data type
 * @return true if valid for data type
 */
-(BOOL) isDataType: (enum GPKGDgiwgDataType) dataType;

/**
 * Get the contents data types
 *
 * @return contents data types
 */
-(NSDictionary<NSNumber *, NSArray<NSNumber *> *> *) contentsDataTypes;

/**
 * Get the tiles data types
 *
 * @return tiles data types
 */
-(NSArray<NSNumber *> *) tilesDataTypes;

/**
 * Has tiles data types
 *
 * @return true if has tiles data types
 */
-(BOOL) hasTilesDataTypes;

/**
 * Get the features data types
 *
 * @return features data types
 */
-(NSArray<NSNumber *> *) featuresDataTypes;

/**
 * Has features data types
 *
 * @return true if has features data types
 */
-(BOOL) hasFeaturesDataTypes;

/**
 * Get the data types for the contents data type
 *
 * @param contentsDataType
 *            contents data type
 * @return data types
 */
-(NSArray<NSNumber *> *) dataTypes: (enum GPKGContentsDataType) contentsDataType;

/**
 * Create a Spatial Reference System
 *
 * @return Spatial Reference System
 */
-(GPKGSpatialReferenceSystem *) createSpatialReferenceSystem;

/**
 * Validate the CRS for tiles and get the SRS
 *
 * @return srs
 */
-(GPKGSpatialReferenceSystem *) createTilesSpatialReferenceSystem;

/**
 * Validate the CRS for features and get the SRS
 *
 * @return srs
 */
-(GPKGSpatialReferenceSystem *) createFeaturesSpatialReferenceSystem;

/**
 * Create a Lambert Conic Conformal 1SP Spatial Reference System
 *
 * @param epsg
 *            Lambert Conic Conformal 1SP EPSG
 * @param name
 *            CRS name
 * @param crsType
 *            CRS type
 * @param geoDatum
 *            {@link GeoDatums#WGS84}, {@link GeoDatums#ETRS89}, or
 *            {@link GeoDatums#NAD83}
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
 * @return Spatial Reference System
 */
+(GPKGSpatialReferenceSystem *) createLambertConicConformal1SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andScaleFactor: (double) scaleFactor andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing;

/**
 * Create a Lambert Conic Conformal 2SP Spatial Reference System
 *
 * @param epsg
 *            Lambert Conic Conformal 2SP EPSG
 * @param name
 *            CRS name
 * @param crsType
 *            CRS type
 * @param geoDatum
 *            {@link GeoDatums#WGS84}, {@link GeoDatums#ETRS89}, or
 *            {@link GeoDatums#NAD83}
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
 * @return Spatial Reference System
 */
+(GPKGSpatialReferenceSystem *) createLambertConicConformal2SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andStandardParallel1: (double) standardParallel1 andStandardParallel2: (double) standardParallel2 andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing;

/**
 * Get the coordinate reference system for the EPSG code
 *
 * @param epsg
 *            EPSG code
 * @return crs
 */
+(GPKGDgiwgCoordinateReferenceSystems *) coordinateReferenceSystemWithEPSG: (int) epsg;

/**
 * Get the coordinate reference system for the spatial reference system
 *
 * @param srs
 *            spatial reference system
 * @return crs
 */
+(GPKGDgiwgCoordinateReferenceSystems *) coordinateReferenceSystemWithSRS: (GPKGSpatialReferenceSystem *) srs;

/**
 * Get the coordinate reference system for the authority and code
 *
 * @param authority
 *            authority
 * @param code
 *            code
 * @return crs
 */
+(GPKGDgiwgCoordinateReferenceSystems *) coordinateReferenceSystemWithAuthority: (NSString *) authority andCode: (int) code;

/**
 * Get the supported coordinate reference systems for the data type
 *
 * @param dataType
 *            data type
 * @return coordinate reference systems
 */
+(NSArray<GPKGDgiwgCoordinateReferenceSystems *> *) coordinateReferenceSystemsForType: (enum GPKGDgiwgDataType) dataType;

/**
 * Get the supported coordinate reference systems for the contents data type
 *
 * @param dataType
 *            data type
 * @return coordinate reference systems
 */
+(NSArray<GPKGDgiwgCoordinateReferenceSystems *> *) coordinateReferenceSystemsForContentsType: (enum GPKGContentsDataType) dataType;

@end
