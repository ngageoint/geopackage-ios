//
//  GPKGStyles.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGStyleRow.h"

/**
 * Styles for a single feature geometry or feature table default
 */
@interface GPKGStyles : NSObject

/**
 * Table styles flag
 */
@property (nonatomic) BOOL tableStyles;

/**
 * Initialize
 *
 * @return new styles
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param tableStyles table styles
 * @return new styles
 */
-(instancetype) initAsTableStyles: (BOOL) tableStyles;

/**
 * Set the default style
 *
 * @param styleRow default style
 */
-(void) setDefaultStyle: (GPKGStyleRow *) styleRow;

/**
 * Set the style for the geometry type
 *
 * @param styleRow     style row
 * @param geometryType geometry type
 */
-(void) setStyle: (GPKGStyleRow *) styleRow forGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default style
 *
 * @return default style
 */
-(GPKGStyleRow *) defaultStyle;

/**
 * Get an unmodifiable mapping between specific geometry types and styles
 *
 * @return geometry types to style mapping
 */
-(NSDictionary<NSNumber *, GPKGStyleRow *> *) allStyles;

/**
 * Get the style, either the default or single geometry type style
 *
 * @return style
 */
-(GPKGStyleRow *) style;

/**
 * Get the style for the geometry type
 *
 * @param geometryType geometry type
 * @return style
 */
-(GPKGStyleRow *) styleForGeometryType: (enum SFGeometryType) geometryType;

/**
 * Determine if this styles is empty
 *
 * @return true if empty, false if at least one style
 */
-(BOOL) isEmpty;

/**
 * Determine if there is a default style
 *
 * @return true if default style exists
 */
-(BOOL) hasDefault;

@end
