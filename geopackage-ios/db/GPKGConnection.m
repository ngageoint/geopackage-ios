//
//  GPKGConnection.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/7/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGConnection.h"
#import <sqlite3.h>
#import "GPKGSqlUtils.h"
#import "GPKGGeoPackageConstants.h"

@interface GPKGConnection()

@property (nonatomic) sqlite3 *database;

@end

@implementation GPKGConnection

-(instancetype)initWithDatabaseFilename:(NSString *) filename{
    self = [super init];
    if(self){
        self.filename = filename;
        self.name = [[filename lastPathComponent] stringByDeletingPathExtension];
        
        // Open the database.
        sqlite3 *sqlite3Database;
        int openDatabaseResult = sqlite3_open([filename UTF8String], &sqlite3Database);
        if(openDatabaseResult != SQLITE_OK){
            [NSException raise:@"Open Database Failure" format:@"Failed to open database: %@, Error: %s", filename, sqlite3_errmsg(sqlite3Database)];
        }else{
            self.database = sqlite3Database;
        }
    }

    return self;
}

-(void)close{
    @synchronized(self) {
        [GPKGSqlUtils closeDatabase:self.database];
    }
}

-(GPKGResultSet *) rawQuery:(NSString *) statement{
    return [self rawQuery:statement andArgs:nil];
}

-(GPKGResultSet *) rawQuery:(NSString *) statement andArgs: (NSArray *) args{
    GPKGResultSet * resultSet = nil;
    @synchronized(self) {
        resultSet = [GPKGSqlUtils queryWithDatabase:self.database andStatement:statement andArgs:args];
    }
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
    GPKGResultSet * resultSet = nil;
    @synchronized(self) {
        resultSet = [GPKGSqlUtils queryWithDatabase:self.database
                                        andDistinct:false andTable:table
                                         andColumns:columns
                                           andWhere:where
                                       andWhereArgs:whereArgs
                                         andGroupBy:groupBy
                                          andHaving:having
                                         andOrderBy:orderBy
                                           andLimit:limit];
    }
    return resultSet;
}

-(int) count:(NSString *) statement{
    return [self count:statement andArgs:nil];
}

-(int) count:(NSString *) statement andArgs: (NSArray *) args{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils countWithDatabase:self.database andStatement:statement andArgs:args];
    }
    return count;
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils countWithDatabase:self.database andTable:table andWhere:where];
    }
    return count;
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils countWithDatabase:self.database andTable:table andWhere:where andWhereArgs: whereArgs];
    }
    return count;
}

-(long long) insert:(NSString *) statement{
    long long id = -1;;
    @synchronized(self) {
        id = [GPKGSqlUtils insertWithDatabase:self.database andStatement:statement];
    }
    return id;
}

-(int) update:(NSString *) statement{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils updateWithDatabase:self.database andStatement:statement];
    }
    return count;
}

-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils updateWithDatabase:self.database andTable:table andValues:values andWhere:where];
    }
    return count;
}

-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils updateWithDatabase:self.database andTable:table andValues:values andWhere:where andWhereArgs:whereArgs];
    }
    return count;
}

-(long long) insertWithTable: (NSString *) table andValues: (GPKGContentValues *) values{
    long long id = -1;;
    @synchronized(self) {
        id = [GPKGSqlUtils insertWithDatabase:self.database andTable:table andValues:values];
    }
    return id;
}

-(int) delete:(NSString *) statement{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils deleteWithDatabase:self.database andStatement:statement];
    }
    return count;
}

-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils deleteWithDatabase:self.database andTable:table andWhere:where];
    }
    return count;
}

-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    @synchronized(self) {
        count = [GPKGSqlUtils deleteWithDatabase:self.database andTable:table andWhere:where andWhereArgs:whereArgs];
    }
    return count;
}

-(void) exec:(NSString *) statement{
    @synchronized(self) {
        [GPKGSqlUtils execWithDatabase:self.database andStatement:statement];
    }
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
