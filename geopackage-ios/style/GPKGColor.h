//
//  GPKGColor.h
//  geopackage-ios
//
//  Created by Brian Osborn on 1/14/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Color representation with support for hex, RBG, arithmetic RBG, and integer
 * colors
 */
@interface GPKGColor : NSObject

/**
 * Pixel value of where the pixel fits into the source
 */
@property (nonatomic) float pixel;

@end
