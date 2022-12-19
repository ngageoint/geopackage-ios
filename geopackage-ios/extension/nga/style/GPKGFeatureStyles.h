//
//  GPKGFeatureStyles.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyles.h"
#import "GPKGIcons.h"

/**
 * Feature Styles, including styles and icons, for a single feature geometry or
 * feature table default
 */
@interface GPKGFeatureStyles : NSObject

/**
 * Styles
 */
@property (nonatomic, strong) GPKGStyles *styles;

/**
 * Icons
 */
@property (nonatomic, strong) GPKGIcons *icons;

/**
 * Initialize
 *
 * @return new feature styles
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param styles styles
 *
 * @return new feature styles
 */
-(instancetype) initWithStyles: (GPKGStyles *) styles;

/**
 * Initialize
 *
 * @param icons  icons
 *
 * @return new feature styles
 */
-(instancetype) initWithIcons: (GPKGIcons *) icons;

/**
 * Initialize
 *
 * @param styles styles
 * @param icons  icons
 *
 * @return new feature styles
 */
-(instancetype) initWithStyles: (GPKGStyles *) styles andIcons: (GPKGIcons *) icons;

@end
