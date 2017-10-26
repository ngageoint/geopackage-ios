//
//  GPKGFeatureIndexResultSetResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureIndexResults.h"
#import "GPKGResultSet.h"

/**
 * Feature Index Results Result Set implementation
 */
@interface GPKGFeatureIndexResultSetResults : GPKGFeatureIndexResults

/**
 *  Initialize
 *
 *  @param results result set
 *
 *  @return feature index results
 */
-(instancetype) initWithResults: (GPKGResultSet *) results;

/**
 *  Get the results
 *
 *  @return results
 */
-(GPKGResultSet *) getResults;

@end
