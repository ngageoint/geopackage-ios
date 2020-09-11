//
//  GPKGGeometryIndexTableCreator.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGTableCreator.h"

@interface GPKGGeometryIndexTableCreator : GPKGTableCreator

// TODO

/**
 *  Create Table Index table
 *
 *  @return tables created
 */
-(int) createTableIndex;

/**
 *  Create Geometry Index table
 *
 *  @return tables created
 */
-(int) createGeometryIndex;

/**
 * Create Geometry Index table column indexes
 *
 * @return executed statements
 */
-(int) indexGeometryIndex;

/**
 * Un-index (drop) Geometry Index table column indexes
 *
 * @return executed statements
 */
-(int) unindexGeometryIndex;

@end
