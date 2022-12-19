//
//  GPKGIcons.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGIconRow.h"

/**
 * Icons for a single feature geometry or feature table default
 */
@interface GPKGIcons : NSObject

/**
 * Table icons flag
 */
@property (nonatomic) BOOL tableIcons;

/**
 * Initialize
 *
 * @return new icons
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param tableIcons table icons
 * @return new icons
 */
-(instancetype) initAsTableIcons: (BOOL) tableIcons;

/**
 * Set the default icon
 *
 * @param iconRow default icon
 */
-(void) setDefaultIcon: (GPKGIconRow *) iconRow;

/**
 * Set the icon for the geometry type
 *
 * @param iconRow      icon row
 * @param geometryType geometry type
 */
-(void) setIcon: (GPKGIconRow *) iconRow forGeometryType: (enum SFGeometryType) geometryType;

/**
 * Get the default icon
 *
 * @return default icon
 */
-(GPKGIconRow *) defaultIcon;

/**
 * Get an unmodifiable mapping between specific geometry types and icons
 *
 * @return geometry types to icon mapping
 */
-(NSDictionary<NSNumber *, GPKGIconRow *> *) allIcons;

/**
 * Get the icon, either the default or single geometry type icon
 *
 * @return icon
 */
-(GPKGIconRow *) icon;

/**
 * Get the icon for the geometry type
 *
 * @param geometryType geometry type
 * @return icon
 */
-(GPKGIconRow *) iconForGeometryType: (enum SFGeometryType) geometryType;

/**
 * Determine if this icons is empty
 *
 * @return true if empty, false if at least one icon
 */
-(BOOL) isEmpty;

/**
 * Determine if there is a default icon
 *
 * @return true if default icon exists
 */
-(BOOL) hasDefault;

@end
