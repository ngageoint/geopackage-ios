//
//  GPKGGeometryColumnsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGBaseDao.h"
#import "GPKGGeometryColumns.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGContents.h"

@interface GPKGGeometryColumnsDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(GPKGGeometryColumns *) queryForTableName: (NSString *) tableName;

-(NSArray *) getFeatureTables;

-(GPKGSpatialReferenceSystem *) getSrs: (GPKGGeometryColumns *) geometryColumns;

-(GPKGContents *) getContents: (GPKGGeometryColumns *) geometryColumns;

@end
