//
//  GPKGFeatureTilePointIcon.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface GPKGFeatureTilePointIcon : NSObject

@property (nonatomic) double xOffset;
@property (nonatomic) double yOffset;

-(instancetype) initWithIcon: (CGImageRef) icon;

-(void) pinIcon;

-(void) centerIcon;

-(CGImageRef) getIcon;

-(int) getWidth;

-(int) getHeight;

@end
