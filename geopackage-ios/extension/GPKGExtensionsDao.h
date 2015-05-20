//
//  GPKGExtensionsDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGExtensions.h"

@interface GPKGExtensionsDao : GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(int) deleteByExtension: (NSString *) extensionName;

-(int) deleteByExtension: (NSString *) extensionName andTable: (NSString *) tableName;

-(int) deleteByExtension: (NSString *) extensionName andTable: (NSString *) tableName andColumnName: (NSString *) columnName;

-(GPKGResultSet *) queryByExtension: (NSString *) extensionName;

-(GPKGResultSet *) queryByExtension: (NSString *) extensionName andTable: (NSString *) tableName;

-(GPKGResultSet *) queryByExtension: (NSString *) extensionName andTable: (NSString *) tableName andColumnName: (NSString *) columnName;

@end
