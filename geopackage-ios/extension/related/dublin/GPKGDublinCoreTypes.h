//
//  GPKGDublinCoreTypes.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Dublin Core Metadata Initiative term types
 */
enum GPKGDublinCoreType{
    
    /**
     * A point or period of time associated with an event in the lifecycle of
     * the resource.
     */
    GPKG_DCM_DATE,
    
    /**
     * An account of the resource.
     */
    GPKG_DCM_DESCRIPTION,
    
    /**
     * The file format, physical medium, or dimensions of the resource.
     */
    GPKG_DCM_FORMAT,
    
    /**
     * An unambiguous reference to the resource within a given context.
     */
    GPKG_DCM_IDENTIFIER,
    
    /**
     * A related resource from which the described resource is derived.
     */
    GPKG_DCM_SOURCE,
    
    /**
     * A name given to the resource.
     */
    GPKG_DCM_TITLE
    
};

/**
 *  Dublin Core Metadata Type names
 */
extern NSString * const GPKG_DCM_DATE_NAME;
extern NSString * const GPKG_DCM_DESCRIPTION_NAME;
extern NSString * const GPKG_DCM_FORMAT_NAME;
extern NSString * const GPKG_DCM_IDENTIFIER_NAME;
extern NSString * const GPKG_DCM_SOURCE_NAME;
extern NSString * const GPKG_DCM_TITLE_NAME;

/**
 *  Dublin Core Metadata Synonym names
 */
extern NSString * const GPKG_DCM_CONTENT_TYPE_NAME;
extern NSString * const GPKG_DCM_ID_NAME;

@interface GPKGDublinCoreTypes : NSObject

/**
 *  Get the name of the Dublin Core Metadata type
 *
 *  @param dublinCoreType Dublin Core Metadata type
 *
 *  @return Dublin Core Metadata type name
 */
+(NSString *) name: (enum GPKGDublinCoreType) dublinCoreType;

/**
 *  Get the Dublin Core Metadata type from the name
 *
 *  @param name Dublin Core Metadata type name
 *
 *  @return Dublin Core Metadata type
 */
+(enum GPKGDublinCoreType) fromName: (NSString *) name;

/**
 *  Get the synonymous column names
 *
 *  @param dublinCoreType Dublin Core Metadata type
 *
 *  @return synonyms
 */
+(NSArray<NSString *> *) synonyms: (enum GPKGDublinCoreType) dublinCoreType;

@end
