//
//  GPKGSqlUtils.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/14/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGResultSet.h"
#import <sqlite3.h>
#import "GPKGContentValues.h"

@interface GPKGSqlUtils : NSObject

+(void) execWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

+(GPKGResultSet *) queryWithDatabase: (sqlite3 *) database
                            andDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                            andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit;

+(int) countWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

+(int) countWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where;

+(int) countWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

+(int) countWithDatabase: (sqlite3 *) database andCountStatement: (NSString *) countStatement;

+(int) countWithDatabase: (sqlite3 *) database andCountStatement: (NSString *) countStatement andArgs: (NSArray *) args;

+(long long) insertWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

+(long long) insertWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (GPKGContentValues *) values;

+(int) updateWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

+(int) updateWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

+(int) updateWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where;

+(int) updateWithDatabase: (sqlite3 *) database andTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

+(int) deleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement;

+(int) deleteWithDatabase: (sqlite3 *) database andStatement: (NSString *) statement andArgs: (NSArray *) args;

+(int) deleteWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where;

+(int) deleteWithDatabase: (sqlite3 *) database andTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

+(void) closeStatement: (sqlite3_stmt *) statment;

+(void) closeResultSet: (GPKGResultSet *) resultSet;

+(void) closeDatabase: (sqlite3 *) database;

+(NSString *) getSqlValueString: (NSObject *) value;

@end
