//
//  GPKGFeatureTileContext.m
//  geopackage-ios
//
//  Created by Brian Osborn on 2/14/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureTileContext.h"

@interface GPKGFeatureTileContext ()

@property (nonatomic) int tileWidth;
@property (nonatomic) int tileHeight;
@property (nonatomic, strong) NSMutableDictionary *layeredContext;

@end

@implementation GPKGFeatureTileContext

/**
 *  Polygon layer index
 */
static int POLYGON_LAYER = 0;

/**
 *  Line layer index
 */
static int LINE_LAYER = 1;

/**
 *  Point layer index
 */
static int POINT_LAYER = 2;

/**
 *  Icon layer index
 */
static int ICON_LAYER = 3;

-(instancetype) initWithWidth: (int) tileWidth andHeight: (int) tileHeight{
    self = [super init];
    if(self != nil){
        self.tileWidth = tileWidth;
        self.tileHeight = tileHeight;
        self.layeredContext = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(CGContextRef) polygonContext{
    return [self contextForLayer:POLYGON_LAYER];
}

-(CGContextRef) lineContext{
    return [self contextForLayer:LINE_LAYER];
}

-(CGContextRef) pointContext{
    return [self contextForLayer:POINT_LAYER];
}

-(CGContextRef) iconContext{
    return [self contextForLayer:ICON_LAYER];
}

-(UIImage *) createImage{

    UIImage *image = nil;
    CGContextRef imageContext = NULL;
    
    for (int layer = 0; layer < 4; layer++) {
        
        NSNumber *layerNumber = [NSNumber numberWithInt:layer];
        NSObject *contextObject = [self.layeredContext objectForKey:layerNumber];
        
        if(contextObject != nil){
            
            CGContextRef context = (__bridge CGContextRef) contextObject;
            
            if(imageContext == NULL){
                imageContext = context;
            }else{
                CGImageRef imageRef = CGBitmapContextCreateImage(context);
                CGContextDrawImage(imageContext, CGRectMake(0, 0, self.tileWidth, self.tileHeight), imageRef);
                CGContextRelease(context);
                CGImageRelease(imageRef);
            }
            
            [self.layeredContext removeObjectForKey:layerNumber];
        }
        
    }
    
    if(imageContext != NULL){
        CGImageRef imageRef = CGBitmapContextCreateImage(imageContext);
        image = [UIImage imageWithCGImage:imageRef];
        CGContextRelease(imageContext);
        CGImageRelease(imageRef);
    }
    
    return image;
}

-(void) recycle{
    for (int layer = 0; layer < 4; layer++) {
        NSNumber *layerNumber = [NSNumber numberWithInt:layer];
        NSObject *contextObject = [self.layeredContext objectForKey:layerNumber];
        if(contextObject != nil){
            CGContextRef context = (__bridge CGContextRef) contextObject;
            CGContextRelease(context);
            [self.layeredContext removeObjectForKey:layerNumber];
        }
    }
}

-(CGContextRef) contextForLayer: (int) layer{
    CGContextRef context;
    NSNumber *layerNumber = [NSNumber numberWithInt:layer];
    NSObject *contextObject = [self.layeredContext objectForKey:layerNumber];
    if(contextObject != nil){
        context = (__bridge CGContextRef) contextObject;
    }else{
        CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        context = CGBitmapContextCreate(NULL, self.tileWidth, self.tileHeight, 8, 0, colorSpace, kCGImageAlphaPremultipliedLast);
        CGColorSpaceRelease(colorSpace);
        [self.layeredContext setObject:(__bridge id)context forKey:layerNumber];
    }
    
    return context;
}

@end
