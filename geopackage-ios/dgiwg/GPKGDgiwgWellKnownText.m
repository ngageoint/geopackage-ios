//
//  GPKGDgiwgWellKnownText.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgWellKnownText.h"
#import "GPKGIOUtils.h"
#import "GPKGUTMZone.h"
#import "CRSKeyword.h"
#import "CRSPrimeMeridians.h"

NSString * const GPKG_DGIWG_RESOURCES_WKT = @"dgiwg.wkt";

@implementation GPKGDgiwgWellKnownText

static NSString *CRS_NAME = @"CRS_NAME";
static NSString *CRS_TYPE = @"CRS_TYPE";
static NSString *BASE_NAME = @"BASE_NAME";
static NSString *REFERENCE_NAME = @"REFERENCE_NAME";
static NSString *ELLIPSOID_NAME = @"ELLIPSOID_NAME";
static NSString *SEMI_MAJOR_AXIS = @"SEMI_MAJOR_AXIS";
static NSString *INVERSE_FLATTENING = @"INVERSE_FLATTENING";
static NSString *PRIME_MERIDIAN_NAME = @"PRIME_MERIDIAN_NAME";
static NSString *IRM_LONGITUDE = @"IRM_LONGITUDE";
static NSString *LATITUDE_OF_ORIGIN = @"LATITUDE_OF_ORIGIN";
static NSString *CENTRAL_MERIDIAN = @"CENTRAL_MERIDIAN";
static NSString *SCALE_FACTOR = @"SCALE_FACTOR";
static NSString *FALSE_EASTING = @"FALSE_EASTING";
static NSString *FALSE_NORTHING = @"FALSE_NORTHING";
static NSString *STANDARD_PARALLEL_1 = @"STANDARD_PARALLEL_1";
static NSString *STANDARD_PARALLEL_2 = @"STANDARD_PARALLEL_2";
static NSString *IDENTIFIER_UNIQUE_ID = @"IDENTIFIER_UNIQUE_ID";
static NSString *ZONE = @"ZONE";
static NSString *DIRECTION = @"DIRECTION";

static NSString *EPSG_3035 = @"EPSG_3035";
static NSString *EPSG_3395 = @"EPSG_3395";
static NSString *EPSG_3855 = @"EPSG_3855";
static NSString *EPSG_3857 = @"EPSG_3857";
static NSString *EPSG_3978 = @"EPSG_3978";
static NSString *EPSG_4326 = @"EPSG_4326";
static NSString *EPSG_4979 = @"EPSG_4979";
static NSString *EPSG_5041 = @"EPSG_5041";
static NSString *EPSG_5042 = @"EPSG_5042";
static NSString *EPSG_9518 = @"EPSG_9518";
static NSString *EPSG_UTM_ZONE = @"EPSG_UTM_ZONE";
static NSString *EPSG_LAMBERT_CONFORMAL_CONIC_1SP = @"EPSG_LAMBERT_CONFORMAL_CONIC_1SP";
static NSString *EPSG_LAMBERT_CONFORMAL_CONIC_2SP = @"EPSG_LAMBERT_CONFORMAL_CONIC_2SP";

static NSString *LAMBERT_CONFORMAL_CONIC_1SP_DESCRIPTION = @"LAMBERT_CONFORMAL_CONIC_1SP_DESCRIPTION";
static NSString *LAMBERT_CONFORMAL_CONIC_2SP_DESCRIPTION = @"LAMBERT_CONFORMAL_CONIC_2SP_DESCRIPTION";

+(NSString *) readProperty: (NSString *) propertyName{
    NSMutableString *propertiesFile = [NSMutableString stringWithString:GPKG_DGIWG_RESOURCES_WKT];
    NSString *propertiesPath = [GPKGIOUtils propertyListPathWithName:propertiesFile];
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:propertiesPath];
    NSString *value = [properties objectForKey:propertyName];
    if(value == nil){
        [NSException raise:@"DGIWG WKT" format:@"Failed to find DGIWG CRS WKT for property: %@, in resource: %@", propertyName, propertiesFile];
    }
    return value;
}

+(NSString *) epsg3035{
    return [self readProperty:EPSG_3035];
}

+(NSString *) epsg3395{
    return [self readProperty:EPSG_3395];
}

+(NSString *) epsg3855{
    return [self readProperty:EPSG_3855];
}

+(NSString *) epsg3857{
    return [self readProperty:EPSG_3857];
}

+(NSString *) epsg3978{
    return [self readProperty:EPSG_3978];
}

+(NSString *) epsg4326{
    return [self readProperty:EPSG_4326];
}

+(NSString *) epsg4979{
    return [self readProperty:EPSG_4979];
}

+(NSString *) epsg5041{
    return [self readProperty:EPSG_5041];
}

+(NSString *) epsg5042{
    return [self readProperty:EPSG_5042];
}

+(NSString *) epsg9518{
    return [self readProperty:EPSG_9518];
}

+(NSString *) utmZone: (int) epsg{
    
    int zone = [GPKGUTMZone zone:epsg];
    NSString *direction = [GPKGUTMZone latDirection:epsg];
    int centralMeridian = [GPKGUTMZone centralMeridian:zone];
    int falseNorthing = [GPKGUTMZone falseNorthing:epsg];
    
    NSString *wkt = [NSString stringWithString:[self readProperty:EPSG_UTM_ZONE]];
    
    wkt = [self replace:ZONE withInt:zone inString:wkt];
    wkt = [self replace:DIRECTION withString:direction inString:wkt];
    wkt = [self replace:CENTRAL_MERIDIAN withDouble:centralMeridian inString:wkt];
    wkt = [self replace:FALSE_NORTHING withDouble:falseNorthing inString:wkt];
    wkt = [self replace:IDENTIFIER_UNIQUE_ID withInt:epsg inString:wkt];
    
    return wkt;
}

+(NSString *) lambertConicConformal1SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andScaleFactor: (double) scaleFactor andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing{
    
    NSString *propertyWKT = [NSString stringWithString:[self readProperty:EPSG_LAMBERT_CONFORMAL_CONIC_1SP]];
    NSString *wkt = [self lambertConicConformalWithWKT:propertyWKT andEPSG:epsg andName:name andCRS:crsType andGeoDatum:geoDatum andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];
    
    wkt = [self replace:SCALE_FACTOR withDouble:scaleFactor inString:wkt];
    
    return wkt;
}

+(NSString *) lambertConicConformal2SPWithEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andStandardParallel1: (double) standardParallel1 andStandardParallel2: (double) standardParallel2 andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing{
    
    NSString *propertyWKT = [NSString stringWithString:[self readProperty:EPSG_LAMBERT_CONFORMAL_CONIC_2SP]];
    NSString *wkt = [self lambertConicConformalWithWKT:propertyWKT andEPSG:epsg andName:name andCRS:crsType andGeoDatum:geoDatum andLatitudeOfOrigin:latitudeOfOrigin andCentralMeridian:centralMeridian andFalseEasting:falseEasting andFalseNorthing:falseNorthing];
    
    wkt = [self replace:STANDARD_PARALLEL_1 withDouble:standardParallel1 inString:wkt];
    wkt = [self replace:STANDARD_PARALLEL_2 withDouble:standardParallel2 inString:wkt];
    
    return wkt;
}

/**
 * Get Lambert Conic Conformal well-known text
 *
 * @param wkt
 *            starting well-known text
 * @param epsg
 *            Lambert Conic Conformal EPSG
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
 * @param falseEasting
 *            false easting
 * @param falseNorthing
 *            false northing
 * @return well-known text
 */
+(NSString *) lambertConicConformalWithWKT: (NSString *) wkt andEPSG: (int) epsg andName: (NSString *) name andCRS: (enum CRSType) crsType andGeoDatum: (enum CRSGeoDatumType) geoDatum andLatitudeOfOrigin: (double) latitudeOfOrigin andCentralMeridian: (double) centralMeridian andFalseEasting: (double) falseEasting andFalseNorthing: (double) falseNorthing{
    
    NSString *crsKeyword;
    switch(crsType){
        case CRS_TYPE_GEODETIC:
            crsKeyword = [[CRSKeyword keywordOfType:CRS_KEYWORD_GEODCRS] name];
            break;
        case CRS_TYPE_GEOGRAPHIC:
            crsKeyword = [[CRSKeyword keywordOfType:CRS_KEYWORD_GEOGCS] name];
            break;
        default:
            [NSException raise:@"Invalid Lambert Conformal" format:@"Invalid Lambert Conformal CRS type: %@", [CRSTypes name:crsType]];
    }
    
    CRSGeoDatums *datum = [CRSGeoDatums fromType:geoDatum];
    
    switch(geoDatum){
        case CRS_DATUM_WGS84:
        case CRS_DATUM_ETRS89:
        case CRS_DATUM_NAD83:
            break;
        default:
            [NSException raise:@"Invalid Lambert Conformal" format:@"Invalid Lambert Conformal datum: %@", datum != nil ? [datum name] : nil];
    }
    
    CRSEllipsoids *ellipsoids = [datum ellipsoid];
    CRSPrimeMeridians *primeMeridian = [CRSPrimeMeridians fromType:CRS_PM_GREENWICH];
    
    wkt = [self replace:CRS_NAME withString:name inString:wkt];
    wkt = [self replace:CRS_TYPE withString:crsKeyword inString:wkt];
    wkt = [self replace:BASE_NAME withString:[datum code] inString:wkt];
    wkt = [self replace:REFERENCE_NAME withString:[datum name] inString:wkt];
    wkt = [self replace:ELLIPSOID_NAME withString:[ellipsoids name] inString:wkt];
    wkt = [self replace:SEMI_MAJOR_AXIS withDouble:[ellipsoids equatorRadius] inString:wkt];
    wkt = [self replace:INVERSE_FLATTENING withDouble:[ellipsoids reciprocalFlattening] inString:wkt];
    wkt = [self replace:PRIME_MERIDIAN_NAME withString:[primeMeridian name] inString:wkt];
    wkt = [self replace:IRM_LONGITUDE withDouble:[primeMeridian offsetFromGreenwichDegrees] inString:wkt];
    wkt = [self replace:LATITUDE_OF_ORIGIN withDouble:latitudeOfOrigin inString:wkt];
    wkt = [self replace:CENTRAL_MERIDIAN withDouble:centralMeridian inString:wkt];
    wkt = [self replace:FALSE_EASTING withDouble:falseEasting inString:wkt];
    wkt = [self replace:FALSE_NORTHING withDouble:falseNorthing inString:wkt];
    wkt = [self replace:IDENTIFIER_UNIQUE_ID withInt:epsg inString:wkt];
    
    return wkt;
}

+(NSString *) lambertConicConformal1SPDescription{
    return [self readProperty:LAMBERT_CONFORMAL_CONIC_1SP_DESCRIPTION];
}

+(NSString *) lambertConicConformal2SPDescription{
    return [self readProperty:LAMBERT_CONFORMAL_CONIC_2SP_DESCRIPTION];
}

+(NSString *) replace: (NSString *) property withString: (NSString *) replacement inString: (NSString *) string{
    return [string stringByReplacingOccurrencesOfString:[self readProperty:property] withString:replacement];
}

+(NSString *) replace: (NSString *) property withInt: (int) replacement inString: (NSString *) string{
    return [self replace:property withString:[NSString stringWithFormat:@"%d", replacement] inString:string];
}

+(NSString *) replace: (NSString *) property withDouble: (double) replacement inString: (NSString *) string{
    return [self replace:property withString:[NSString stringWithFormat:@"%f", replacement] inString:string];
}

@end
