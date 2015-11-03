//
//  GPGKGeoPackageCache.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/3/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackageManager.h"

/**
 *  GeoPackage Cache to maintain opened GeoPackages
 */
@interface GPGKGeoPackageCache : NSObject

/**
 *  Initialize
 *
 *  @param manager geoPackage manager
 *
 *  @return new cache
 */
-(instancetype) initWithManager: (GPKGGeoPackageManager *) manager;

/**
 *  Get the cached GeoPackage or open and cache the GeoPackage
 *
 *  @param name GeoPackage name
 *
 *  @return open GeoPackage
 */
-(GPKGGeoPackage *) getOrOpen: (NSString *) name;

/**
 *  Get the names of the cached GeoPackages
 *
 *  @return cached GeoPackage names
 */
-(NSArray<NSString*> *) getNames;

/**
 *  Get the cached GeoPackages
 *
 *  @return cached GeoPackages
 */
-(NSArray<GPKGGeoPackage*> *) getGeoPackages;

/**
 *  Get the GeoPackage with name
 *
 *  @param name GeoPackage name
 *
 *  @return cached GeoPackage
 */
-(GPKGGeoPackage *) get: (NSString *) name;

/**
 *  Checks if the GeoPackage name exists in the cache
 *
 *  @param name GeoPackage name
 *
 *  @return true if exists
 */
-(BOOL) exists: (NSString *) name;

/**
 *  Close all GeoPackages in the cache
 */
-(void) closeAll;

/**
 *  Add a GeoPackage to the cache
 *
 *  @param geoPackage GeoPackage
 */
-(void) add: (GPKGGeoPackage *) geoPackage;

/**
 *  Remove the GeoPackage with the name but does not close it,
 *  callse close to close and remove
 *
 *  @param name GeoPackage name
 *
 *  @return removed GeoPackage
 */
-(GPKGGeoPackage *) remove: (NSString *) name;

/**
 *  Clears all cached GeoPackages but does not close them,
 *  call closeAll to close and clear all GeoPackages
 */
-(void) clear;

/**
 *  Close the GeoPackage with name
 *
 *  @param name GeoPackage name
 *
 *  @return true if found and closed
 */
-(BOOL) close: (NSString *) name;

/**
 *  Close GeoPackages not specified in the retain GeoPackage names
 *
 *  @param retain array of names to retain
 */
-(void) closeRetain: (NSArray *) retain;

/**
 *  Close GeoPackages with names
 *
 *  @param names GeoPackage names to close
 */
-(void) closeNames: (NSArray *) names;

@end
