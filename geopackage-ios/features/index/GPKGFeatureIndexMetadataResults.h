//
//  GPKGFeatureIndexMetadataResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureIndexer.h"
#import "GPKGFeatureIndexResults.h"

/**
 * Feature Index Results to enumerate on feature rows
 * retrieved from Metadata index results
 */
@interface GPKGFeatureIndexMetadataResults : GPKGFeatureIndexResults

/**
 *  Initialize
 *
 *  @param featureIndexer feature indexer
 *  @param results result set
 *
 *  @return feature index metadata results
 */
-(instancetype) initWithFeatureTableIndex: (GPKGFeatureIndexer *) featureIndexer andResults: (GPKGResultSet *) results;

@end
