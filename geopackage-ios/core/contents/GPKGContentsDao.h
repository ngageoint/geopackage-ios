//
//  GPKGContentsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/18/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGContents.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGGeometryColumns.h"
#import "GPKGTileMatrixSet.h"

@interface GPKGContentsDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(int) deleteCascade: (GPKGContents *) contents;

-(int) deleteCascade: (GPKGContents *) contents andUserTable: (BOOL) userTable;

-(int) deleteCascadeWithCollection: (NSArray *) contentsCollection;

-(int) deleteCascadeWithCollection: (NSArray *) contentsCollection andUserTable: (BOOL) userTable;

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andUserTable: (BOOL) userTable;

-(int) deleteByIdCascade: (NSNumber *) id;

-(int) deleteByIdCascade: (NSNumber *) id andUserTable: (BOOL) userTable;

-(int) deleteIdsCascade: (NSArray *) idCollection;

-(int) deleteIdsCascade: (NSArray *) idCollection andUserTable: (BOOL) userTable;

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGContents *) contents;

-(GPKGGeometryColumns *) getGeometryColumns: (GPKGContents *) contents;

-(GPKGTileMatrixSet *) getTileMatrixSet: (GPKGContents *) contents;

-(GPKGResultSet *) getTileMatrix: (GPKGContents *) contents;

@end
