//
//  GPKGIconCache.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGIconRow.h"

/**
 * Default max number of icon images to retain in cache
 */
static int DEFAULT_ICON_CACHE_SIZE = 100;

/**
 * Icon Cache of icon images
 */
@interface GPKGIconCache : NSObject

/**
 *  Screen scale, default is 1.0
 */
@property (nonatomic) float scale;

/**
 *  Initialize, created with cache size of DEFAULT_ICON_CACHE_SIZE
 *
 *  @return new icon cache
 */
-(instancetype) init;

/**
 *  Initialize
 *
 *  @param size max icon images to retain in the cache
 *
 *  @return new icon cache
 */
-(instancetype) initWithSize: (int) size;

/**
 * Get the cached image for the icon row or nil if not cached
 *
 * @param iconRow icon row
 * @return icon image or nil
 */
-(UIImage *) imageForRow: (GPKGIconRow *) iconRow;

/**
 * Get the cached image for the icon row id or nil if not cached
 *
 * @param iconRowId icon row id
 * @return icon image or nil
 */
-(UIImage *) imageForId: (int) iconRowId;

/**
 * Get the cached image for the icon row id or nil if not cached
 *
 * @param iconRowId icon row id
 * @return icon image or nil
 */
-(UIImage *) imageForIdNumber: (NSNumber *) iconRowId;

/**
 * Cache the icon image for the icon row
 *
 * @param image  icon image
 * @param iconRow icon row
 * @return previous cached icon image or nil
 */
-(UIImage *) putImage: (UIImage *) image forRow: (GPKGIconRow *) iconRow;

/**
 * Cache the icon image for the icon row id
 *
 * @param image    icon image
 * @param iconRowId icon row id
 * @return previous cached icon image or nil
 */
-(UIImage *) putImage: (UIImage *) image forId: (int) iconRowId;

/**
 * Cache the icon image for the icon row id
 *
 * @param image    icon image
 * @param iconRowId icon row id
 * @return previous cached icon image or nil
 */
-(UIImage *) putImage: (UIImage *) image forIdNumber: (NSNumber *) iconRowId;

/**
 * Remove the cached image for the icon row
 *
 * @param iconRow icon row
 * @return removed icon image or nil
 */
-(UIImage *) removeForRow: (GPKGIconRow *) iconRow;

/**
 * Remove the cached image for the icon row id
 *
 * @param iconRowId icon row id
 * @return removed icon image or nil
 */
-(UIImage *) removeForId: (int) iconRowId;

/**
 * Remove the cached image for the icon row id
 *
 * @param iconRowId icon row id
 * @return removed icon image or nil
 */
-(UIImage *) removeForIdNumber: (NSNumber *) iconRowId;

/**
 * Clear the cache
 */
-(void) clear;

/**
 * Resize the cache
 *
 * @param maxSize max size
 */
-(void) resizeWithSize: (int) maxSize;

/**
 * Create or retrieve from cache an icon image for the icon row
 *
 * @param icon    icon row
 * @return icon image
 */
-(UIImage *) createIconForRow: (GPKGIconRow *) icon;

/**
 * Create an icon image for the icon row without caching
 *
 * @param icon    icon row
 * @return icon image
 */
+(UIImage *) createIconNoCacheForRow: (GPKGIconRow *) icon;

/**
 * Create or retrieve from cache an icon image for the icon row
 *
 * @param icon      icon row
 * @param iconCache icon cache
 * @return icon image
 */
+(UIImage *) createIconForRow: (GPKGIconRow *) icon fromCache: (GPKGIconCache *) iconCache;

@end
