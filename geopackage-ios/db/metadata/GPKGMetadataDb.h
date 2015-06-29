//
//  GPKGMetadataDb.h
//  geopackage-ios
//
//  Created by Brian Osborn on 6/29/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGGeoPackageMetadataDao.h"
#import "GPKGTableMetadataDao.h"
#import "GPKGGeometryMetadataDao.h"

@interface GPKGMetadataDb : NSObject

-(instancetype) init;

-(void) close;

-(GPKGGeoPackageMetadataDao *) getGeoPackageMetadataDao;

-(GPKGTableMetadataDao *) getTableMetadataDao;

-(GPKGGeometryMetadataDao *) getGeometryMetadataDao;

+(BOOL) deleteMetadataFile;

@end
