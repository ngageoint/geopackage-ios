//
//  GPKGCoverageDataResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGTileMatrix.h"

@interface GPKGCoverageDataResults : NSObject

/**
 *  Initialize
 *
 *  @param values coverage data results
 *  @param tileMatrix tile matrix
 *
 *  @return new coverage data results
 */
-(instancetype) initWithValues: (NSArray *) values andTileMatrix: (GPKGTileMatrix *) tileMatrix;

/**
 * Get the double array of coverage data values stored as [row][column]
 *
 * @return coverage data values
 */
-(NSArray *) values;

/**
 * Get the tile matrix used to find the coverage data values
 *
 * @return tile matrix
 */
-(GPKGTileMatrix *) tileMatrix;

/**
 * Get the results height
 *
 * @return height
 */
-(int) height;

/**
 * Get the results width
 *
 * @return width
 */
-(int) width;

/**
 * Get the coverage data value at the row and column
 *
 * @param row
 *            row index
 * @param column
 *            column index
 * @return coverage data value
 */
-(NSDecimalNumber *) valueAtRow: (int) row andColumn: (int) column;

/**
 * Get the zoom level of the results
 *
 * @return zoom level
 */
-(NSNumber *) zoomLevel;

@end
