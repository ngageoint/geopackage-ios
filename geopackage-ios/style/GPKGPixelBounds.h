//
//  GPKGPixelBounds.h
//  geopackage-ios
//
//  Created by Brian Osborn on 4/6/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Expanded pixel bounds from a point or location. Stored in directional left,
 * up, right, and down pixels
 */
@interface GPKGPixelBounds : NSObject

/**
 * Pixels left of the location
 */
@property (nonatomic) double left;

/**
 * Pixels up of the location
 */
@property (nonatomic) double up;

/**
 * Pixels right of the location
 */
@property (nonatomic) double right;

/**
 * Pixels down of the location
 */
@property (nonatomic) double down;

/**
 * Create
 *
 * @return new pixel bounds
 */
+(GPKGPixelBounds *) create;

/**
 * Create
 *
 * @param length
 *            length in all directions
 *
 * @return new pixel bounds
 */
+(GPKGPixelBounds *) createWithLength: (double) length;

/**
 * Create
 *
 * @param width
 *            length both left and right
 * @param height
 *            height both up and down
 *
 * @return new pixel bounds
 */
+(GPKGPixelBounds *) createWithWidth: (double) width andHeight: (double) height;

/**
 * Initialize
 *
 * @param left
 *            left length
 * @param up
 *            up length
 * @param right
 *            right length
 * @param down
 *            down length
 *
 * @return new pixel bounds
 */
+(GPKGPixelBounds *) createWithLeft: (double) left andUp: (double) up andRight: (double) right andDown: (double) down;

/**
 * Initialize
 *
 * @return new pixel bounds
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param length
 *            length in all directions
 *
 * @return new pixel bounds
 */
-(instancetype) initWithLength: (double) length;

/**
 * Initialize
 *
 * @param width
 *            length both left and right
 * @param height
 *            height both up and down
 *
 * @return new pixel bounds
 */
-(instancetype) initWithWidth: (double) width andHeight: (double) height;

/**
 * Initialize
 *
 * @param left
 *            left length
 * @param up
 *            up length
 * @param right
 *            right length
 * @param down
 *            down length
 *
 * @return new pixel bounds
 */
-(instancetype) initWithLeft: (double) left andUp: (double) up andRight: (double) right andDown: (double) down;

/**
 * Expand the left pixels if greater than the current value
 *
 * @param left
 *            left pixels
 */
-(void) expandLeft: (double) left;

/**
 * Expand the up pixels if greater than the current value
 *
 * @param up
 *            up pixels
 */
-(void) expandUp: (double) up;

/**
 * Expand the right pixels if greater than the current value
 *
 * @param right
 *            right pixels
 */
-(void) expandRight: (double) right;

/**
 * Expand the down pixels if greater than the current value
 *
 * @param down
 *            down pixels
 */
-(void) expandDown: (double) down;

/**
 * Expand the width pixels if greater than the current values
 *
 * @param width
 *            width pixels
 */
-(void) expandWidth: (double) width;

/**
 * Expand the height pixels if greater than the current values
 *
 * @param height
 *            height pixels
 */
-(void) expandHeight: (double) height;

/**
 * Expand the length pixels in all directions
 *
 * @param length
 *            length pixels
 */
-(void) expandLength: (double) length;

/**
 * Get the total pixel width
 *
 * @return pixel width
 */
-(double) width;

/**
 * Get the total pixel height
 *
 * @return pixel height
 */
-(double) height;

/**
 * Get the pixel area
 *
 * @return pixel area
 */
-(double) area;

@end
