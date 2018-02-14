//
//  GPKGCoverageDataPngImage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGCoverageDataImage.h"
#import <UIKit/UIKit.h>
#import "GPKGTileRow.h"

/**
 * Coverage Data PNG image
 */
@interface GPKGCoverageDataPngImage : NSObject<GPKGCoverageDataImage>

/**
 *  Initialize
 *
 *  @param tileRow tile row
 *
 *  @return new instance
 */
-(instancetype) initWithTileRow: (GPKGTileRow *) tileRow;

/**
 * Get the image
 *
 * @return image
 */
-(UIImage *) image;

/**
 * Get the image data
 *
 * @return image data
 */
-(NSData *) imageData;

/**
 * Get the pixel at the coordinate
 *
 * @param x x coordinate
 * @param y y coordinate
 * @return pixel value
 */
-(unsigned short) pixelAtX: (int) x andY: (int) y;

@end
