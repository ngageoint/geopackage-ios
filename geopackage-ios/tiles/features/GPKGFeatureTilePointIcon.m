//
//  GPKGFeatureTilePointIcon.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTilePointIcon.h"

@interface GPKGFeatureTilePointIcon ()

@property (nonatomic) UIImage * icon;
@property (nonatomic) int width;
@property (nonatomic) int height;

@end

@implementation GPKGFeatureTilePointIcon

-(instancetype) initWithIcon: (UIImage *) icon{
    self = [super init];
    if(self != nil){
        self.icon = icon;
        self.width = icon.size.width;
        self.height = icon.size.height;
    }
    return self;
}

-(void) pinIcon{
    self.xOffset = self.width / 2.0;
    self.yOffset = self.height;
}

-(void) centerIcon{
    self.xOffset = self.width / 2.0;
    self.yOffset = self.height / 2.0;
}

-(UIImage *) getIcon{
    return self.icon;
}

-(int) getWidth{
    return self.width;
}

-(int) getHeight{
    return self.height;
}

@end
