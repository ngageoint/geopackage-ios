//
//  GPKGSpatialReferenceSystemDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGBaseDao.h"
#import "GPKGSpatialReferenceSystem.h"

@interface GPKGSpatialReferenceSystemDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(GPKGSpatialReferenceSystem *) createWgs84;

-(GPKGSpatialReferenceSystem *) createUndefinedCartesian;

-(GPKGSpatialReferenceSystem *) createUndefinedGeographic;

-(GPKGSpatialReferenceSystem *) createWebMercator;

-(GPKGSpatialReferenceSystem *) getOrCreateWithSrsId: (NSNumber*) srsId;

-(int) deleteCascade: (GPKGSpatialReferenceSystem *) srs;

-(int) deleteCascadeWithCollection: (NSArray *) srsCollection;

-(int) deleteCascadeWhere: (NSString *) where;

-(int) deleteByIdCascade: (NSNumber *) id;

-(int) deleteIdsCascade: (NSArray *) idCollection;

-(GPKGResultSet *) getContents: (GPKGSpatialReferenceSystem *) srs;

-(GPKGResultSet *) getGeometryColumns: (GPKGSpatialReferenceSystem *) srs;

//-(GPKGTileMatrixSet *) getTileMatrixSet: (GPKGSpatialReferenceSystem *) srs;

@end
