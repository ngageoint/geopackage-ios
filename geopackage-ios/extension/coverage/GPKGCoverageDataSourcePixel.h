//
//  GPKGCoverageDataSourcePixel.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/9/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Contains values relevant to a source pixel location when finding a coverage data value
 */
@interface GPKGCoverageDataSourcePixel : NSObject

/**
 * Pixel value of where the pixel fits into the source
 */
@property (nonatomic) float pixel;

/**
 * Min pixel value
 */
@property (nonatomic) int min;

/**
 * Max pixel value
 */
@property (nonatomic) int max;

/**
 * Offset between the two pixels
 */
@property (nonatomic) float offset;

/**
 *  Initialize
 *
 *  @param pixel pixel value
 *  @param min min value
 *  @param max max value
 *  @param offset pixel offset
 *
 *  @return new value source pixel
 */
-(instancetype) initWithPixel: (float) pixel andMin: (int) min andMax: (int) max andOffset: (float) offset;

@end
