//
//  GPKGTileMatrixSetDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGContents.h"

@interface GPKGTileMatrixSetDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(NSArray *) getTileTables;

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGTileMatrixSet *) tileMatrixSet;

-(GPKGContents *) getContents: (GPKGTileMatrixSet *) tileMatrixSet;

@end
