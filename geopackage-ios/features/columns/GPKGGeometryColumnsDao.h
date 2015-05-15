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

@interface GPKGGeometryColumnsDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(GPKGGeometryColumns *) queryForTableName: (NSString *) tableName;

-(NSArray *) getFeatureTables;

@end
