//
//  GPKGPixelBounds.m
//  geopackage-ios
//
//  Created by Brian Osborn on 4/6/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGPixelBounds.h"

@implementation GPKGPixelBounds

+(GPKGPixelBounds *) create{
    return [[GPKGPixelBounds alloc] init];
}

+(GPKGPixelBounds *) createWithLength: (double) length{
    return [[GPKGPixelBounds alloc] initWithLength:length];
}

+(GPKGPixelBounds *) createWithWidth: (double) width andHeight: (double) height{
    return [[GPKGPixelBounds alloc] initWithWidth:width andHeight:height];
}

+(GPKGPixelBounds *) createWithLeft: (double) left andUp: (double) up andRight: (double) right andDown: (double) down{
    return [[GPKGPixelBounds alloc] initWithLeft:left andUp:up andRight:right andDown:down];
}

-(instancetype) init{
    self = [super init];
    return self;
}

-(instancetype) initWithLength: (double) length{
    self = [self initWithWidth:length andHeight:length];
    return self;
}

-(instancetype) initWithWidth: (double) width andHeight: (double) height{
    self = [self initWithLeft:width andUp:height andRight:width andDown:height];
    return self;
}

-(instancetype) initWithLeft: (double) left andUp: (double) up andRight: (double) right andDown: (double) down{
    self = [self init];
    if(self != nil){
        _left = left;
        _up = up;
        _right = right;
        _down = down;
    }
    return self;
}

-(void) expandLeft: (double) left{
    _left = MAX(_left, left);
}

-(void) expandUp: (double) up{
    _up = MAX(_up, up);
}

-(void) expandRight: (double) right{
    _right = MAX(_right, right);
}

-(void) expandDown: (double) down{
    _down = MAX(_down, down);
}

-(void) expandWidth: (double) width{
    [self expandLeft:width];
    [self expandRight:width];
}

-(void) expandHeight: (double) height{
    [self expandUp:height];
    [self expandDown:height];
}

-(void) expandLength: (double) length{
    [self expandWidth:length];
    [self expandHeight:length];
}

@end
