//
//  GPKGGeoPackageCache.h
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
@interface GPKGGeoPackageCache : NSObject

/**
 *  Close quietly flag
 */
@property (nonatomic) BOOL closeQuietly;

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
 *  Get the cached GeoPackage or open the GeoPackage without caching it
 *
 *  @param name GeoPackage name
 *
 *  @return open GeoPackage
 */
-(GPKGGeoPackage *) getOrNoCacheOpen: (NSString *) name;

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
 *  Determine if the cache has the GeoPackage name
 *
 *  @param name GeoPackage name
 *
 *  @return true if has cached GeoPackage
 */
-(BOOL) has: (NSString *) name;

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
 *  Add the collection of GeoPackages
 *
 *  @param geoPackages GeoPackages
 */
-(void) addAll: (NSArray<GPKGGeoPackage *> *) geoPackages;

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

/**
 * Close the GeoPackage
 *
 * @param geoPackage
 *            GeoPackage
 */
-(void) closeGeoPackage: (GPKGGeoPackage *) geoPackage;

/**
 * Close the GeoPackage if it is cached (same GeoPackage instance)
 *
 * @param geoPackage
 *            GeoPackage
 * @return true if closed
 */
-(BOOL) closeGeoPackageIfCached: (GPKGGeoPackage *) geoPackage;

/**
 * Close the GeoPackage if it is not cached (GeoPackage not cached or
 * different instance)
 *
 * @param geoPackage
 *            GeoPackage
 * @return true if closed
 */
-(BOOL) closeGeoPackageIfNotCached: (GPKGGeoPackage *) geoPackage;

@end
