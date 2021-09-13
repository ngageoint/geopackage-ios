//
//  GPKGOAPIFeatureGenerator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPKGFeatureGenerator.h"
#import "OAFCollection.h"

/**
 * OGC API Features Generator
 */
@interface GPKGOAPIFeatureGenerator : GPKGFeatureGenerator

/**
 * The optional limit parameter limits the number of items that are
 * presented in the response document.
 */
@property (nonatomic, strong) NSNumber *limit;

/**
 * Either a date-time or a period string that adheres to RFC 3339
 */
@property (nonatomic, strong) NSString *time;

/**
 * Time period string that adheres to RFC 3339
 */
@property (nonatomic, strong) NSString *period;

/**
 * Total limit of number of items to request
 */
@property (nonatomic, strong) NSNumber *totalLimit;

/**
 * Download attempts per feature request
 */
@property (nonatomic) int downloadAttempts;

/**
 * Initialize
 *
 * @param geoPackage
 *            GeoPackage
 * @param tableName
 *            table name
 * @param server
 *            server url
 * @param id
 *            collection identifier
 *
 *  @return new OAPI feature generator
 */
-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (NSString *) tableName andServer: (NSString *) server andId: (NSString *) id;

/**
 * Get the server
 *
 * @return server
 */
-(NSString *) server;

/**
 * Get the collection id
 *
 * @return collection id
 */
-(NSString *) id;

/**
 * Set the time
 *
 * @param time
 *            time
 */
-(void) setTimeFromDate: (NSDate *) time;

/**
 * Set the time period
 *
 * @param period
 *            period
 */
-(void) setPeriodFromDate: (NSDate *) period;

/**
 * Get the supported projections
 *
 * @return projections
 */
-(PROJProjections *) projections;

/**
 * Get the supported projections
 *
 * @param url
 *            URL
 * @return projections
 */
-(PROJProjections *) projectionsForURL: (NSString *) url;

/**
 * Get the supported projections
 *
 * @param collection
 *            collection
 * @return projections
 */
-(PROJProjections *) projectionsForCollection: (OAFCollection *) collection;

/**
 * Determine if the projection should be requested from the server
 *
 * @param projection
 *            projection
 * @return true to request the projection (non null and non default)
 */
-(BOOL) requestProjection: (PROJProjection *) projection;

/**
 * Check if the projection is a default projection
 *
 * @param projection
 *            projection
 * @return true if default projection
 */
-(BOOL) isDefaultProjection: (PROJProjection *) projection;

/**
 * Collection request
 *
 * @return collection
 */
-(OAFCollection *) collectionRequest;

@end
