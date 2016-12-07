//
//  GPKGElevationTileValues.h
//  geopackage-ios
//
//  Created by Brian Osborn on 12/6/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPKGElevationTileValues : NSObject

@property (nonatomic, strong) NSMutableArray *tilePixels;
@property (nonatomic, strong) NSMutableArray *tileElevations;
@property (nonatomic, strong) NSMutableArray *tilePixelsFlat;
@property (nonatomic, strong) NSMutableArray *tileElevationsFlat;

@end
