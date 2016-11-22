//
//  GPKGElevationImage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/18/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GPKGTileRow.h"

/**
 * Elevation image, stores the tile row image
 */
@interface GPKGElevationImage : NSObject

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
 * Get the width
 *
 * @return width
 */
-(int) width;

/**
 * Get the height
 *
 * @return height
 */
-(int) height;

@end
