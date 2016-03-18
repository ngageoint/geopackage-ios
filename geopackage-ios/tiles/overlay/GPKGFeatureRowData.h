//
//  GPKGFeatureRowData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeometryData.h"

/**
 * Represents the values of a single feature row
 */
@interface GPKGFeatureRowData : NSObject

/**
 *  Initializer
 *
 *  @param values         value mapping
 *  @param geometryColumn geometry column name
 *
 *  @return new instance
 */
-(instancetype) initWithValues: (NSDictionary *) values andGeometryColumnName: (NSString *) geometryColumn;

/**
 *  Get the values
 *
 *  @return values
 */
-(NSDictionary *) getValues;

/**
 *  Get the geometry column name
 *
 *  @return geometry column name
 */
-(NSString *) getGeometryColumn;

/**
 *  Get the geometry data
 *
 *  @return geometry data
 */
-(GPKGGeometryData *) getGeometryData;

/**
 *  Get the geometry
 *
 *  @return geometry
 */
-(WKBGeometry *) getGeometry;

/**
 *  Build a JSON compatible object
 *
 *  @return JSON compatiable object
 */
-(NSObject *) jsonCompatible;

/**
 *  Build a JSON compatible object
 *
 *  @param includePoints true to include point geometries, but no other geometry types
 *
 *  @return JSON compatiable object
 */
-(NSObject *) jsonCompatibleWithPoints: (BOOL) includePoints;

/**
 *  Build a JSON compatible object
 *
 *  @param includeGeometries true to include all geometries, false for no geometries
 *
 *  @return JSON compatiable object
 */
-(NSObject *) jsonCompatibleWithGeometries: (BOOL) includeGeometries;

/**
 *  Build a JSON compatible object
 *
 *  @param includePoints     true to include point geometries, ignored if includeGeometries is true
 *  @param includeGeometries true to include all geometry types
 *
 *  @return JSON compatiable object
 */
-(NSObject *) jsonCompatibleWithPoints: (BOOL) includePoints andGeometries: (BOOL) includeGeometries;

@end
