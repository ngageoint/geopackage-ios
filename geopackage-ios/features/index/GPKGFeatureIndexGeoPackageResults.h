//
//  GPKGFeatureIndexGeoPackageResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/12/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureTableIndex.h"
#import "GPKGFeatureIndexResults.h"

/**
 * Feature Index Results to enumerate on feature rows
 * retrieved from GeoPackage index extension results
 */
@interface GPKGFeatureIndexGeoPackageResults : GPKGFeatureIndexResults

/**
 *  Initialize
 *
 *  @param featureTableIndex feature table index
 *  @param results result set
 *
 *  @return feature index geopackage results
 */
-(instancetype) initWithFeatureTableIndex: (GPKGFeatureTableIndex *) featureTableIndex andResults: (GPKGResultSet *) results;

@end
