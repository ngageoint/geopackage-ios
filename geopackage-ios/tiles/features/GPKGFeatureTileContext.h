//
//  GPKGFeatureTileContext.h
//  geopackage-ios
//
//  Created by Brian Osborn on 2/14/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * Feature Tile Context for creating layered tiles to draw ordered features.
 * Draw Order: polygons, lines, points, icons
 */
@interface GPKGFeatureTileContext : NSObject

/**
 *  Initialize
 *
 *  @param tileWidth  tile width
 *  @param tileHeight tile height
 *
 *  @return new feature tile context
 */
-(instancetype) initWithWidth: (int) tileWidth andHeight: (int) tileHeight;

/**
 * Get the polygon context
 *
 * @return polygon context
 */
-(CGContextRef) polygonContext;

/**
 * Get the line context
 *
 * @return line context
 */
-(CGContextRef) lineContext;

/**
 * Get the point context
 *
 * @return point context
 */
-(CGContextRef) pointContext;

/**
 * Get the icon context
 *
 * @return icon context
 */
-(CGContextRef) iconContext;

/**
 * Create the final image from the layers, resets the layers
 *
 * @return image
 */
-(UIImage *) createImage;

/**
 * Recycle the layered contexts
 */
-(void) recycle;

@end
