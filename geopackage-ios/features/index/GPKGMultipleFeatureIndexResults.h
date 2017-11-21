//
//  GPKGMultipleFeatureIndexResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureIndexResults.h"

/**
 * Iterable Feature Index Results to iterate on feature rows from a combination of multiple
 * Feature Index Results
 */
@interface GPKGMultipleFeatureIndexResults : GPKGFeatureIndexResults

/**
 * Initializer
 *
 * @param results index results
 */
-(instancetype) initWithFeatureIndexResults: (GPKGFeatureIndexResults *) results;

/**
 * Initializer
 *
 * @param results1 index results 1
 * @param results2 index results 2
 */
-(instancetype) initWithFeatureIndexResults1: (GPKGFeatureIndexResults *) results1 andFeatureIndexResults2: (GPKGFeatureIndexResults *) results2;

/**
 * Initializer
 *
 * @param resultsArray array of feature index results
 */
-(instancetype) initWithFeatureIndexResultsArray: (NSArray<GPKGFeatureIndexResults *> *) resultsArray;

@end
