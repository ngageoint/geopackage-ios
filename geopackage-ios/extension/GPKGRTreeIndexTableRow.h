//
//  GPKGRTreeIndexTableRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomRow.h"

@class GPKGRTreeIndexExtension;

@interface GPKGRTreeIndexTableRow : GPKGUserCustomRow

/**
 * Initialize
 *
 * @param userCustomRow
 *            user custom row to copy
 *
 *  @return new rtree index table row
 */
-(instancetype) initWithUserCustomRow: (GPKGUserCustomRow *) userCustomRow;

/**
 * Get the ID
 *
 * @return ID
 */
-(int) id;

/**
 * Get the ID number
 *
 * @return ID number
 */
-(NSNumber *) idNumber;

/**
 * Get the min x
 *
 * @return min x
 */
-(double) minX;

/**
 * Get the max x
 *
 * @return max x
 */
-(double) maxX;

/**
 * Get the min y
 *
 * @return min y
 */
-(double) minY;

/**
 * Get the max y
 *
 * @return max y
 */
-(double) maxY;

@end
