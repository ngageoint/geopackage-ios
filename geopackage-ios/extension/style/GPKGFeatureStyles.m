//
//  GPKGFeatureStyles.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureStyles.h"

@implementation GPKGFeatureStyles

-(instancetype) init{
    self = [self initWithStyles:nil andIcons:nil];
    return self;
}

-(instancetype) initWithStyles: (GPKGStyles *) styles{
    self = [self initWithStyles:styles andIcons:nil];
    return self;
}

-(instancetype) initWithIcons: (GPKGIcons *) icons{
    self = [self initWithStyles:nil andIcons:icons];
    return self;
}

-(instancetype) initWithStyles: (GPKGStyles *) styles andIcons: (GPKGIcons *) icons{
    self = [super init];
    if(self != nil){
        self.styles = styles;
        self.icons = icons;
    }
    return self;
}

@end
