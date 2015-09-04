//
//  GPKGFeatureTilePointIcon.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Point icon in place of a drawn circle
 */
@interface GPKGFeatureTilePointIcon : NSObject

/**
 *  X pixel offset
 */
@property (nonatomic) double xOffset;

/**
 *  Y pixel offset
 */
@property (nonatomic) double yOffset;

/**
 *  Initialize
 *
 *  @param icon icon image
 *
 *  @return new feature tile point icon
 */
-(instancetype) initWithIcon: (UIImage *) icon;

/**
 *  Pin the icon to the point, lower middle on the point
 */
-(void) pinIcon;

/**
 *  Center the icon on the point
 */
-(void) centerIcon;

/**
 *  Get the icon image
 *
 *  @return icon image
 */
-(UIImage *) getIcon;

/**
 *  Get the icon width
 *
 *  @return icon width
 */
-(int) getWidth;

/**
 *  Get the icon height
 *
 *  @return icon height
 */
-(int) getHeight;

@end
