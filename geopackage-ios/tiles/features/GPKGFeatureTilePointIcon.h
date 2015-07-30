//
//  GPKGFeatureTilePointIcon.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GPKGFeatureTilePointIcon : NSObject

@property (nonatomic) double xOffset;
@property (nonatomic) double yOffset;

-(instancetype) initWithIcon: (UIImage *) icon;

-(void) pinIcon;

-(void) centerIcon;

-(UIImage *) getIcon;

-(int) getWidth;

-(int) getHeight;

@end
