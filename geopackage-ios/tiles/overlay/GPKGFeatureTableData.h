//
//  GPKGFeatureTableData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureRowData.h"

/**
 * Represents a collection of rows from a feature table
 */
@interface GPKGFeatureTableData : NSObject

/**
 *  Initializer
 *
 *  @param name  table name
 *  @param count feature count
 *
 *  @return new instance
 */
-(instancetype) initWithName: (NSString *) name andCount: (int) count;

/**
 *  Initializer
 *
 *  @param name  table name
 *  @param count feature count
 *  @param rows  feature rows
 *
 *  @return new instance
 */
-(instancetype) initWithName: (NSString *) name andCount: (int) count andRows: (NSArray<GPKGFeatureRowData *> *) rows;

/**
 *  Get the table name
 *
 *  @return table name
 */
-(NSString *) getName;

/**
 *  Get the feature row count
 *
 *  @return count of rows
 */
-(int) getCount;

/**
 *  Get the feature row data
 *
 *  @return feature rows
 */
-(NSArray<GPKGFeatureRowData *> *) getRows;

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
