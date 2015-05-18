//
//  GPKGTileMatrixSetDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileMatrixSetDao.h"
#import "GPKGContentsDao.h"
#import "GPKGSpatialReferenceSystemDao.h"

@implementation GPKGTileMatrixSetDao

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGSpatialReferenceSystemDao * dao = [self getSpatialReferenceSystemDao];
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[dao queryForId:tileMatrixSet.srsId];
    return srs;
}

-(GPKGContents *) getContents: (GPKGTileMatrixSet *) tileMatrixSet{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGContents *contents = (GPKGContents *)[dao queryForId:tileMatrixSet.tableName];
    return contents;
}

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

@end
