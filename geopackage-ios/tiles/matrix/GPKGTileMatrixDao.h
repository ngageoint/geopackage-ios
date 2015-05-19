//
//  GPKGTileMatrixDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTileMatrix.h"
#import "GPKGContents.h"

@interface GPKGTileMatrixDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(GPKGContents *) getContents: (GPKGTileMatrix *) tileMatrix;

@end
