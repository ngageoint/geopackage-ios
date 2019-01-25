//
//  GPKGFeatureStyle.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureStyle.h"

@implementation GPKGFeatureStyle

-(instancetype) init{
    self = [self initWithStyle:nil andIcon:nil];
    return self;
}

-(instancetype) initWithStyle: (GPKGStyleRow *) style{
    self = [self initWithStyle:style andIcon:nil];
    return self;
}

-(instancetype) initWithIcon: (GPKGIconRow *) icon{
    self = [self initWithStyle:nil andIcon:icon];
    return self;
}

-(instancetype) initWithStyle: (GPKGStyleRow *) style andIcon: (GPKGIconRow *) icon{
    self = [super init];
    if(self != nil){
        self.style = style;
        self.icon = icon;
    }
    return self;
}

-(BOOL) hasStyle{
    return self.style != nil;
}

-(BOOL) hasIcon{
    return self.icon != nil;
}

@end
