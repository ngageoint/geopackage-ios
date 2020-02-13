//
//  GPKGFeatureIndexerIdResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/13/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGResultSet.h"
#import "GPKGFeatureIndexerIdQuery.h"

/**
 * Feature Indexer Id result set to filter on matching queried ids
 */
@interface GPKGFeatureIndexerIdResultSet : GPKGResultSet

/**
 *  Initialize
 *
 *  @param resultSet result set
 *  @param idQuery     id query
 *
 *  @return new feature indexer id result set
 */
-(instancetype) initWithResults: (GPKGResultSet *) resultSet andIdQuery: (GPKGFeatureIndexerIdQuery *) idQuery;

@end
