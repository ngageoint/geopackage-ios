//
//  GPKGTileGrid.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGTileGrid : NSObject

@property (nonatomic) int minX;
@property (nonatomic) int maxX;
@property (nonatomic) int minY;
@property (nonatomic) int maxY;

-(instancetype) initWithMinX: (int) minX andMaxX: (int) maxX andMinY: (int) minY andMaxY: (int) maxY;

-(int) count;

@end
