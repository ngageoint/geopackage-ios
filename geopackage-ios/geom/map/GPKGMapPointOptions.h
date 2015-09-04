//
//  GPKGMapPointOptions.h
//  Pods
//
//  Created by Brian Osborn on 8/14/15.
//
//

#import <Foundation/Foundation.h>
#import "GPKGMapPointInitializer.h"
@import MapKit;

/**
 *  Map Point options including style and atributes
 */
@interface GPKGMapPointOptions : NSObject

/**
 *  Standard pin annotation color
 */
@property (nonatomic) MKPinAnnotationColor pinColor;

/**
 *  Icon image, replacing the use of a pin color
 */
@property (nonatomic, strong) UIImage *image;

/**
 *  Image center offset when drawing the image icon
 */
@property (nonatomic) CGPoint imageCenterOffset;

/**
 *  True if the icon is draggable
 */
@property (nonatomic) BOOL draggable;

/**
 *  Map point initializer for callbacks
 */
@property (nonatomic, strong) NSObject<GPKGMapPointInitializer> * initializer;

/**
 *  Initialize
 *
 *  @return new map point options
 */
- (id)init;

/**
 *  Pin the image so the middle bottom of the image is drawn at the location
 */
-(void) pinImage;

/**
 *  Center the image so it is drawn with the center at the location
 */
-(void) centerImage;

@end
