//
//  GPKGElevationImage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGElevationImage_h
#define geopackage_ios_GPKGElevationImage_h

#import <Foundation/Foundation.h>

/**
 *  Elevation image interface
 */
@protocol GPKGElevationImage <NSObject>

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

#endif
