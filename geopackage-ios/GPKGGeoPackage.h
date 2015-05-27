//
//  GPKGGeoPackage.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "GPKGConnection.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGContentsDao.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGFeatureDao.h"

@interface GPKGGeoPackage : NSObject

-(instancetype) initWithConnection: (GPKGConnection *) database;

-(void)close;

-(NSString *)getName;

-(NSString *)getPath;

-(GPKGConnection *)getDatabase;

-(NSArray *)getFeatureTables;

-(GPKGSpatialReferenceSystemDao *) getSpatialReferenceSystemDao;

-(GPKGContentsDao *) getContentsDao;

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao;

-(GPKGFeatureDao *) getFeatureDaoWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns;

-(GPKGFeatureDao *) getFeatureDaoWithContents: (GPKGContents *) contents;

-(GPKGFeatureDao *) getFeatureDaoWithTableName: (NSString *) tableName;

@end
