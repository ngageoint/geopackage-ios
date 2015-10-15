//
//  GPKGFeatureIndexResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/15/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGResultSet.h"


/**
 *  Feature Index Results fast enumeration to iterate on feature rows in a for loop
 */
@interface GPKGFeatureIndexResults : NSObject <NSFastEnumeration>

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

/**
 *  Get the count of results
 *
 *  @return count
 */
-(int) count;

/**
 *  Close the results
 */
-(void) close;

@end
