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

@end
