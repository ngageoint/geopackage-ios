//
//  GPKGOverlayFactory.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
#import "GPKGTileDao.h"

@interface GPKGOverlayFactory : NSObject

+(MKTileOverlay *) getTileOverlayWithTileDao: (GPKGTileDao *) tileDao;

@end
