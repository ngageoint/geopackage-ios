//
//  GPKGFeatureIndexListResults.h
//  geopackage-ios
//
//  Created by Brian Osborn on 10/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResults.h"

/**
 * Feature Index Results Feature Row list implementation
 */
@interface GPKGFeatureIndexListResults : GPKGFeatureIndexResults

/**
 * Initializer
 */
-(instancetype) init;

/**
 * Initializer
 *
 * @param row feature row
 */
-(instancetype) initWithFeatureRow: (GPKGFeatureRow *) row;

/**
 * Initializer
 *
 * @param rows feature rows
 */
-(instancetype) initWithFeatureRows: (NSArray<GPKGFeatureRow *> *) rows;

/**
 * Add a feature row
 *
 * @param row feature row
 */
-(void) addRow: (GPKGFeatureRow *) row;

/**
 * Add feature rows
 *
 * @param rows feature rows
 */
-(void) addRows: (NSArray<GPKGFeatureRow *> *) rows;

@end
