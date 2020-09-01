//
//  GPKGFeatureIndexRTreeResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/13/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResults.h"
#import "GPKGRTreeIndexTableDao.h"

/**
 * Iterable Feature Index Results to iterate on feature rows retrieved from
 * RTree results
 */
@interface GPKGFeatureIndexRTreeResults : GPKGFeatureIndexResults

/**
 *  Initialize
 *
 *  @param dao RTree index table dao
 *  @param results result set
 *
 *  @return feature index RTree results
 */
-(instancetype) initWithDao: (GPKGRTreeIndexTableDao *) dao andResults: (GPKGResultSet *) results;

@end
