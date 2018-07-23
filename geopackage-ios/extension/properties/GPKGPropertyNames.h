//
//  GPKGPropertyNames.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/23/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * An entity responsible for making contributions to the resource
 */
extern NSString * const GPKG_PE_CONTRIBUTOR;

/**
 * The spatial or temporal topic of the resource, the spatial applicability
 * of the resource, or the jurisdiction under which the resource is relevant
 */
extern NSString * const GPKG_PE_COVERAGE;

/**
 * Date Created - Date of creation of the resource
 */
extern NSString * const GPKG_PE_CREATED;

/**
 * An entity primarily responsible for making the resource
 */
extern NSString * const GPKG_PE_CREATOR;

/**
 * A point or period of time associated with an event in the lifecycle of
 * the resource
 */
extern NSString * const GPKG_PE_DATE;

/**
 * An account of the resource
 */
extern NSString * const GPKG_PE_DESCRIPTION;

/**
 * An unambiguous reference to the resource within a given context
 */
extern NSString * const GPKG_PE_IDENTIFIER;

/**
 * A legal document giving official permission to do something with the
 * resource
 */
extern NSString * const GPKG_PE_LICENSE;

/**
 * Date Modified - Date on which the resource was changed
 */
extern NSString * const GPKG_PE_MODIFIED;

/**
 * An entity responsible for making the resource available
 */
extern NSString * const GPKG_PE_PUBLISHER;

/**
 * A related resource that is referenced, cited, or otherwise pointed to by
 * the described resource
 */
extern NSString * const GPKG_PE_REFERENCES;

/**
 * A related resource
 */
extern NSString * const GPKG_PE_RELATION;

/**
 * A related resource from which the described resource is derived
 */
extern NSString * const GPKG_PE_SOURCE;

/**
 * Spatial Coverage - Spatial characteristics of the resource
 */
extern NSString * const GPKG_PE_SPATIAL;

/**
 * The topic of the resource
 */
extern NSString * const GPKG_PE_SUBJECT;

/**
 * A tag or label of the resource
 */
extern NSString * const GPKG_PE_TAG;

/**
 * Temporal Coverage - Temporal characteristics of the resource
 */
extern NSString * const GPKG_PE_TEMPORAL;

/**
 * A name given to the resource
 */
extern NSString * const GPKG_PE_TITLE;

/**
 * The nature or genre of the resource
 */
extern NSString * const GPKG_PE_TYPE;

/**
 * The set of identifiers constructed according to the generic syntax for
 * Uniform Resource Identifiers as specified by the Internet Engineering
 * Task Force
 */
extern NSString * const GPKG_PE_URI;

/**
 * Date Valid - Date (often a range) of validity of a resource
 */
extern NSString * const GPKG_PE_VALID;

/**
 * A version of the resource
 */
extern NSString * const GPKG_PE_VERSION;

@interface GPKGPropertyNames : NSObject

@end
