//
//  GPKGDgiwgCoordinateReferenceSystems.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/11/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGDgiwgCoordinateReferenceSystems.h"
#import "PROJProjectionConstants.h"

@implementation GPKGDgiwgCoordinateReferenceSystems

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataType
 *            data type
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self initWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self initWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:[GPKGBoundingBox worldWGS84] andDataTypes:dataTypes];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self initWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self initWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:wgs84Bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self initWithType:type andEPSG:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param epsgCode
 *            EPSG code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andEPSG: (int) epsgCode andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self initWithType:type andAuthority:PROJ_AUTHORITY_EPSG andCode:epsgCode andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataType
 *            data type
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self initWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self initWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:[GPKGBoundingBox worldWGS84] andDataTypes:dataTypes];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self initWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    return [self initWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:wgs84Bounds andWGS84Bounds:wgs84Bounds andDataTypes:dataTypes];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataType
 *            data type
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataType: (enum GPKGDgiwgDataType) dataType{
    return [self initWithType:type andAuthority:authority andCode:code andName:name andCRS:crsType andDimension:dimension andWKT:wkt andDescription:description andBounds:bounds andWGS84Bounds:wgs84Bounds andDataTypes:[NSArray arrayWithObject:[NSNumber numberWithInt:dataType]]];
}

/**
 * Initialize with EPSG code and world WGS84 bounds
 *
 * @param type
 *            type
 * @param authority
 *            authority
 * @param code
 *            code
 * @param name
 *            name
 * @param crsType
 *            CRS type
 * @param dimension
 *            1-3 dimensional
 * @param wkt
 *            Well-Known Text
 * @param description
 *            description
 * @param bounds
 *            bounds
 * @param wgs84Bounds
 *            WGS84 bounds
 * @param dataTypes
 *            data types
 */
-(instancetype) initWithType: (enum GPKGDgiwgCoordinateReferenceSystem) type andAuthority: (NSString *) authority andCode: (int) code andName: (NSString *) name andCRS: (enum CRSType) crsType andDimension: (int) dimension andWKT: (NSString *) wkt andDescription: (NSString *) description andBounds: (GPKGBoundingBox *) bounds andWGS84Bounds: (GPKGBoundingBox *) wgs84Bounds andDataTypes: (NSArray<NSNumber *> *) dataTypes{
    self = [super init];
    if(self != nil){
        // TODO
    }
    return self;
}

/**
 * Initialize for UTM Zones
 *
 * @param epsgCode
 *            UTM Zone EPSG
 */
-(instancetype) initWithEPSG: (int) epsgCode{
    self = [super init];
    if(self != nil){
        // TODO
    }
    return self;
}



// TODO

@end
