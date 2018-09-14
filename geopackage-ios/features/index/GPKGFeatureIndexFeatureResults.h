//
//  GPKGFeatureIndexFeatureResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResultSetResults.h"
#import "GPKGFeatureDao.h"

/**
 * Iterable Feature Index Results to iterate on feature results from a feature
 * DAO
 */
@interface GPKGFeatureIndexFeatureResults : GPKGFeatureIndexResultSetResults

/**
 *  Initialize
 *
 *  @param featureDao feature dao
 *  @param results result set
 *
 *  @return feature index feature results
 */
-(instancetype) initWithDao: (GPKGFeatureDao *) featureDao andResults: (GPKGResultSet *) results;

@end
