//
//  GPKGCoverageDataImage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/3/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#ifndef geopackage_ios_GPKGCoverageDataImage_h
#define geopackage_ios_GPKGCoverageDataImage_h

#import <Foundation/Foundation.h>

/**
 *  Coverage Data image interface
 */
@protocol GPKGCoverageDataImage <NSObject>

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
