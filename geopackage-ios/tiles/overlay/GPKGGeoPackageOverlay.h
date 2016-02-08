//
//  GPKGGeoPackageOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GPKGTileDao.h"
#import "GPKGBoundedOverlay.h"

/**
 *  GeoPackage Tile Overlay
 */
@interface GPKGGeoPackageOverlay : GPKGBoundedOverlay

/**
 *  Coordinate
 */
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

/**
 *  The projected rectangle that encompasses the overlay. (required) (read-only)
 *
 *  @return map rectangle
 */
- (MKMapRect)boundingMapRect;

/**
 *  The approximate center point of the overlay area. (required) (read-only)
 *
 *  @return center coordinate
 */
- (CLLocationCoordinate2D)coordinate;

/**
 *  Initialize
 *
 *  @param tileDao tile dao
 *
 *  @return new tile dao
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao;

/**
 *  Initialize
 *
 *  @param tileDao tile dao
 *  @param width   tile width
 *  @param height  tile height
 *
 *  @return new tile dao
 */
-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (int) width andHeight: (int) height;

@end
