//
//  GPKGConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGConnection.h"
#import <sqlite3.h>
#import "GPKGDbConnection.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGConnectionPool.h"
#import "GPKGSqlUtils.h"

@interface GPKGConnection()

@property (nonatomic, strong) GPKGConnectionPool *connectionPool;

@end

@implementation GPKGConnection

-(instancetype)initWithDatabaseFilename:(NSString *) filename{
    self = [super init];
    if(self){
        self.filename = filename;
        self.name = [[filename lastPathComponent] stringByDeletingPathExtension];
        self.connectionPool = [[GPKGConnectionPool alloc] initWithDatabaseFilename:filename];
    }

    return self;
}

-(void)close{
    [self.connectionPool close];
}

-(GPKGResultSet *) rawQuery:(NSString *) statement{
    return [self rawQuery:statement andArgs:nil];
}

-(GPKGResultSet *) rawQuery:(NSString *) statement andArgs: (NSArray *) args{
    GPKGDbConnection * connection = [self.connectionPool getResultConnection];
    GPKGResultSet * resultSet = [GPKGSqlUtils queryWithDatabase:connection andStatement:statement andArgs:args];
    return resultSet;
}

-(GPKGResultSet *) queryWithTable: (NSString *) table
                  andColumns: (NSArray *) columns
                    andWhere: (NSString *) where
                  andWhereArgs: (NSArray *) whereArgs
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                  andOrderBy: (NSString *) orderBy{
    return [self queryWithTable:table
                     andColumns:columns
                     andWhere:where
                     andWhereArgs:whereArgs
                     andGroupBy:groupBy
                     andHaving:having
                     andOrderBy:orderBy
                     andLimit:nil];
}

-(GPKGResultSet *) queryWithTable: (NSString *) table
                          andColumns: (NSArray *) columns
                            andWhere: (NSString *) where
                          andWhereArgs: (NSArray *) whereArgs
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    GPKGDbConnection * connection = [self.connectionPool getResultConnection];
    GPKGResultSet * resultSet = [GPKGSqlUtils queryWithDatabase:connection
                                        andDistinct:false andTable:table
                                         andColumns:columns
                                           andWhere:where
                                       andWhereArgs:whereArgs
                                         andGroupBy:groupBy
                                          andHaving:having
                                         andOrderBy:orderBy
                                           andLimit:limit];
    return resultSet;
}

-(int) count:(NSString *) statement{
    return [self count:statement andArgs:nil];
}

-(int) count:(NSString *) statement andArgs: (NSArray *) args{
    GPKGDbConnection * connection = [self.connectionPool getConnection];
    int count = [GPKGSqlUtils countWithDatabase:connection andStatement:statement andArgs:args];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where{
    GPKGDbConnection * connection = [self.connectionPool getConnection];
    int count = [GPKGSqlUtils countWithDatabase:connection andTable:table andWhere:where];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection * connection = [self.connectionPool getConnection];
    int count = [GPKGSqlUtils countWithDatabase:connection andTable:table andWhere:where andWhereArgs: whereArgs];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(long long) insert:(NSString *) statement{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    long long id = [GPKGSqlUtils insertWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
    return id;
}

-(int) update:(NSString *) statement{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    int count = [GPKGSqlUtils updateWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    int count = [GPKGSqlUtils updateWithDatabase:connection andTable:table andValues:values andWhere:where];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    int count = [GPKGSqlUtils updateWithDatabase:connection andTable:table andValues:values andWhere:where andWhereArgs:whereArgs];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(long long) insertWithTable: (NSString *) table andValues: (GPKGContentValues *) values{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    long long id = [GPKGSqlUtils insertWithDatabase:connection andTable:table andValues:values];
    [self.connectionPool releaseConnection:connection];
    return id;
}

-(int) delete:(NSString *) statement{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    int count = [GPKGSqlUtils deleteWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    int count = [GPKGSqlUtils deleteWithDatabase:connection andTable:table andWhere:where];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    int count = [GPKGSqlUtils deleteWithDatabase:connection andTable:table andWhere:where andWhereArgs:whereArgs];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(void) exec:(NSString *) statement{
    GPKGDbConnection * connection = [self.connectionPool getWriteConnection];
    [GPKGSqlUtils execWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
}

-(BOOL) tableExists: (NSString *) table{
    int count = [self countWithTable:@"sqlite_master" andWhere:[NSString stringWithFormat:@"type ='table' and name = '%@'", table]];
    BOOL found = count > 0;
    return found;
}

-(void) setApplicationId{
    [self setApplicationId:GPKG_APPLICATION_ID];
}

-(void) setApplicationId: (NSString *) applicationId{
    NSData *bytes = [applicationId dataUsingEncoding:NSUTF8StringEncoding];
    int applicationIdData = CFSwapInt32BigToHost(*(int*)([bytes bytes]));
    [self exec:[NSString stringWithFormat:@"PRAGMA application_id = %d", applicationIdData]];
}

-(void) dropTable: (NSString *) table{
    [self exec:[NSString stringWithFormat:@"drop table if exists %@", table]];
}

@end
