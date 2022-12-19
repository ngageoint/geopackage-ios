//
//  GPKGFeatureStyle.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGStyleRow.h"
#import "GPKGIconRow.h"

/**
 * Feature Style, including a style and icon, for a single feature geometry
 */
@interface GPKGFeatureStyle : NSObject

/**
 * Style
 */
@property (nonatomic, strong) GPKGStyleRow *style;

/**
 * Icon
 */
@property (nonatomic, strong) GPKGIconRow *icon;

/**
 * Initialize
 *
 * @return new feature style
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param style style row
 *
 * @return new feature style
 */
-(instancetype) initWithStyle: (GPKGStyleRow *) style;

/**
 * Initialize
 *
 * @param icon  icon row
 *
 * @return new feature style
 */
-(instancetype) initWithIcon: (GPKGIconRow *) icon;

/**
 * Initialize
 *
 * @param style style row
 * @param icon  icon row
 *
 * @return new feature style
 */
-(instancetype) initWithStyle: (GPKGStyleRow *) style andIcon: (GPKGIconRow *) icon;

/**
 * Check if the feature style has a style row
 *
 * @return true if has style row
 */
-(BOOL) hasStyle;

/**
 * Check if the feature style has an icon row
 *
 * @return true if has icon row
 */
-(BOOL) hasIcon;

/**
 * Determine if an icon exists and should be used. Returns false when an
 * icon does not exist or when both a table level icon and row level style
 * exist.
 *
 * @return true if the icon exists and should be used over a style
 */
-(BOOL) useIcon;

@end
