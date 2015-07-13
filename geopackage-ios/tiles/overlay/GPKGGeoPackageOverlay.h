//
//  GPKGGeoPackageOverlay.h
//  geopackage-ios
//
//  Created by Brian Osborn on 7/1/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "GPKGTileDao.h"

@interface GPKGGeoPackageOverlay : MKTileOverlay

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (MKMapRect)boundingMapRect;
- (CLLocationCoordinate2D)coordinate;

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao;

-(instancetype) initWithTileDao: (GPKGTileDao *) tileDao andWidth: (int) width andHeight: (int) height;

@end
