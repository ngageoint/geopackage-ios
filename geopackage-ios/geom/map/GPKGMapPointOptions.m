//
//  GPKGMapPointOptions.m
//  Pods
//
//  Created by Brian Osborn on 8/14/15.
//
//

#import "GPKGMapPointOptions.h"

@implementation GPKGMapPointOptions

- (id)init{
    self = [super init];
    if (self) {
        self.pinTintColor = [UIColor purpleColor];
        self.pinColor = MKPinAnnotationColorPurple;
    }
    return self;
}

-(void) pinImage{
    if(self.image != nil){
        self.imageCenterOffset = CGPointMake(0, -self.image.size.height / 2);
    }
}

-(void) centerImage{
    self.imageCenterOffset = CGPointMake(0, 0);
}

-(void) anchorWithU: (double) anchorU andV: (double) anchorV{
    float x = -self.image.size.width / 2 + (anchorU * self.image.size.width);
    float y = -self.image.size.height / 2 + ((1.0 - anchorV) * self.image.size.height);
    self.imageCenterOffset = CGPointMake(x, y);
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGMapPointOptions *copy = [[GPKGMapPointOptions alloc] init];
    [copy setPinTintColor:_pinTintColor];
    [copy setPinColor:_pinColor];
    [copy setImage:_image];
    [copy setImageCenterOffset:_imageCenterOffset];
    [copy setDraggable:_draggable];
    [copy setInitializer:_initializer];
    return copy;
}

@end
