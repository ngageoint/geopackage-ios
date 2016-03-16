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

@end
