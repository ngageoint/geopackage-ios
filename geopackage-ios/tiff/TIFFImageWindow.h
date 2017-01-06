//
//  TIFFImageWindow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/4/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIFFFileDirectory.h"

@interface TIFFImageWindow : NSObject

/**
 * Min x
 */
@property int minX;

/**
 * Min y
 */
@property int minY;

/**
 * Max x
 */
@property int maxX;

/**
 * Max y
 */
@property int maxY;

/**
 * Initialize
 *
 * @param minX min x (inclusive)
 * @param minY min y (inclusive)
 * @param maxX max x (exclusive)
 * @param maxY max y (exclusive)
 */
-(instancetype) initWithMinX: (int) minX andMinY: (int) minY andMaxX: (int) maxX andMaxY: (int) maxY;

/**
 * Initialize for a single coordinate
 *
 * @param x x coordinate
 * @param y y coordinate
 */
-(instancetype) initWithX: (int) x andY: (int) y;

/**
 * Initialize, full image size
 *
 * @param fileDirectory file directory
 * @param y y coordinate
 */
-(instancetype) initWithFileDirectory: (TIFFFileDirectory *) fileDirectory;

@end
