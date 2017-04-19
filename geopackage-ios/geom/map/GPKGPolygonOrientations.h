//
//  GPKGPolygonOrientations.h
//  geopackage-ios
//
//  Created by Brian Osborn on 4/18/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Orientation types of polygon exterior and hole rings
 */
enum GPKGPolygonOrientation{
    GPKG_PO_COUNTERCLOCKWISE,
    GPKG_PO_CLOCKWISE,
    GPKG_PO_UNSPECIFIED
};

@interface GPKGPolygonOrientations : NSObject

@end
