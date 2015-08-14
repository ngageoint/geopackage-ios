//
//  GPKGMapPointOptions.h
//  Pods
//
//  Created by Brian Osborn on 8/14/15.
//
//

#import <Foundation/Foundation.h>
@import MapKit;

@interface GPKGMapPointOptions : NSObject

@property (nonatomic) MKPinAnnotationColor pinColor;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGPoint imageCenterOffset;
@property (nonatomic) BOOL draggable;

- (id)init;

-(void) pinImage;

-(void) centerImage;

@end
