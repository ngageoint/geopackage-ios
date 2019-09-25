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
#import "GPKGConnectionFunction.h"
#import "GPKGAlterTable.h"
#import "GPKGSQLiteMaster.h"

@interface GPKGConnection()

@property (nonatomic, strong) GPKGConnectionPool *connectionPool;

@end

@implementation GPKGConnection

-(instancetype)initWithDatabaseFilename:(NSString *) filename{
    return [self initWithDatabaseFilename:filename andName:nil];
}

-(instancetype)initWithDatabaseFilename:(NSString *) filename andName:(NSString *) name{
    self = [super init];
    if(self){
        self.filename = filename;
        if(name == nil){
            name = [[filename lastPathComponent] stringByDeletingPathExtension];
        }
        self.name = name;
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

-(NSNumber *) minWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection * connection = [self.connectionPool getConnection];
    NSNumber * min = [GPKGSqlUtils minWithDatabase:connection andTable:table andColumn:column andWhere:where andWhereArgs: whereArgs];
    [self.connectionPool releaseConnection:connection];
    return min;
}

-(NSNumber *) maxWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection * connection = [self.connectionPool getConnection];
    NSNumber * max = [GPKGSqlUtils maxWithDatabase:connection andTable:table andColumn:column andWhere:where andWhereArgs: whereArgs];
    [self.connectionPool releaseConnection:connection];
    return max;
}

-(void) beginTransaction{
    [self.connectionPool beginTransaction];
}

-(void) commitTransaction{
    [self.connectionPool commitTransaction];
}

-(void) rollbackTransaction{
    [self.connectionPool rollbackTransaction];
}

-(BOOL) enableForeignKeys{
    BOOL enabled = [self foreignKeys];
    if (!enabled) {
        NSArray<NSArray<NSObject *> *> *violations = [self foreignKeyCheck];
        if(violations.count == 0){
            [self foreignKeysAsOn:YES];
            enabled = YES;
        }else{
            for(NSArray<NSObject *> *violation in violations){
                NSLog(@"Foreign Key violation. Table: %@, Row Id: %@, Referred Table: %@, FK Index: %@",
                      [violation objectAtIndex:0],
                      [violation objectAtIndex:1],
                      [violation objectAtIndex:2],
                      [violation objectAtIndex:3]);
            }
        }
    }
    return enabled;
}

-(BOOL) foreignKeys{
    return [GPKGSqlUtils foreignKeysWithConnection:self];
}

-(BOOL) foreignKeysAsOn: (BOOL) on{
    return [GPKGSqlUtils foreignKeysAsOn:on withConnection:self];
}

-(NSArray<NSArray<NSObject *> *> *) foreignKeyCheck{
    return [GPKGSqlUtils foreignKeyCheckWithConnection:self];
}

-(NSArray<NSArray<NSObject *> *> *) foreignKeyCheckOnTable: (NSString *) tableName{
    return [GPKGSqlUtils foreignKeyCheckOnTable:tableName withConnection:self];
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

-(void) execAllConnectionStatement: (NSString *) statement{
    [self.connectionPool execAllConnectionStatement:statement];
}

-(void) execPersistentAllConnectionStatement: (NSString *) statement asName: (NSString *) name{
    [self.connectionPool execPersistentAllConnectionStatement:statement asName:name];
}

-(NSString *) removePersistentAllConnectionStatementWithName: (NSString *) name{
    return [self.connectionPool removePersistentAllConnectionStatementWithName:name];
}

-(BOOL) tableExists: (NSString *) table{
    return [GPKGSQLiteMaster countWithConnection:self andType:GPKG_SMT_TABLE andTable:table] > 0;
}

-(BOOL) columnExistsWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    
    BOOL exists = false;
    
    GPKGTableInfo *tableInfo = [GPKGTableInfo infoWithConnection:self andTable:tableName];
    if(tableInfo != nil){
        exists = [tableInfo hasColumn:columnName];
    }
    
    return exists;
}

-(void) addColumnWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName andColumnDef: (NSString *) columndef{
    [GPKGAlterTable addColumn:columnName withDefinition:columndef toTable:tableName withConnection:self];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self querySingleResultWithSql:sql andArgs:args andColumn:0];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andDataType: (enum GPKGDataType) dataType{
    return [self querySingleResultWithSql:sql andArgs:args andColumn:0 andDataType:dataType];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column{
    return [self querySingleResultWithSql:sql andArgs:args andColumn:column andDataType:-1];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType{
    GPKGDbConnection *connection = [self.connectionPool getConnection];
    NSObject *result = [GPKGSqlUtils querySingleResultWithDatabase:connection andSql:sql andArgs:args andColumn:column andDataType:dataType];
    [self.connectionPool releaseConnection:connection];
    return result;
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self querySingleColumnResultsWithSql:sql andArgs:args andColumn:0 andDataType:-1 andLimit:nil];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataType: (enum GPKGDataType) dataType{
    return [self querySingleColumnResultsWithSql:sql andArgs:args andColumn:0 andDataType:dataType andLimit:nil];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column{
    return [self querySingleColumnResultsWithSql:sql andArgs:args andColumn:column andDataType:-1 andLimit:nil];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType{
    return [self querySingleColumnResultsWithSql:sql andArgs:args andColumn:column andDataType:dataType andLimit:nil];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andLimit: (NSNumber *) limit{
    return [self querySingleColumnResultsWithSql:sql andArgs:args andColumn:column andDataType:-1 andLimit:limit];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType andLimit: (NSNumber *) limit{
    GPKGDbConnection *connection = [self.connectionPool getConnection];
    NSArray<NSObject *> *result = [GPKGSqlUtils querySingleColumnResultsWithDatabase:connection andSql:sql andArgs:args andColumn:column andDataType:dataType andLimit:limit];
    [self.connectionPool releaseConnection:connection];
    return result;
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self queryResultsWithSql:sql andArgs:args andDataTypes:nil andLimit:nil];
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes{
    return [self queryResultsWithSql:sql andArgs:args andDataTypes:dataTypes andLimit:nil];
}

-(NSArray<NSObject *> *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self querySingleRowResultsWithSql:sql andArgs:args andDataTypes:nil];
}

-(NSArray<NSObject *> *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes{
    NSArray<NSArray<NSObject *> *> *results = [self queryResultsWithSql:sql andArgs:args andDataTypes:dataTypes andLimit:[NSNumber numberWithInt:1]];
    NSArray<NSObject *> *singleRow = nil;
    if(results.count > 0){
        singleRow = [results objectAtIndex:0];
    }
    return singleRow;
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andLimit: (NSNumber *) limit{
    return [self queryResultsWithSql:sql andArgs:args andDataTypes:nil andLimit:limit];
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit{
    GPKGDbConnection *connection = [self.connectionPool getConnection];
    NSArray<NSArray<NSObject *> *> *result = [GPKGSqlUtils queryResultsWithDatabase:connection andSql:sql andArgs:args andDataTypes:dataTypes andLimit:limit];
    [self.connectionPool releaseConnection:connection];
    return result;
}

-(void) setApplicationId{
    [self setApplicationId:GPKG_APPLICATION_ID];
}

-(void) setApplicationId: (NSString *) applicationId{
    NSData *bytes = [applicationId dataUsingEncoding:NSUTF8StringEncoding];
    int applicationIdData = CFSwapInt32BigToHost(*(int*)([bytes bytes]));
    [self exec:[NSString stringWithFormat:@"PRAGMA application_id = %d", applicationIdData]];
}

-(NSString *) applicationId{

    NSString * applicationId = nil;
    
    GPKGResultSet * result = [self rawQuery:[NSString stringWithFormat:@"PRAGMA application_id"]];
    @try{
        if([result moveToNext]){
            NSNumber * resultNumber = [result getInt:0];
            int applicationIdInt = CFSwapInt32HostToBig([resultNumber intValue]);
            NSData * applicationIdData = [NSData dataWithBytes:&applicationIdInt length:4];
            applicationId = [[NSString alloc] initWithData:applicationIdData encoding:NSUTF8StringEncoding];
        }
    }@finally{
        [result close];
    }
    
    return applicationId;
}

-(void) setUserVersion{
    [self setUserVersion:(int)GPKG_USER_VERSION];
}

-(void) setUserVersion: (int) userVersion{
    [self exec:[NSString stringWithFormat:@"PRAGMA user_version = %d", userVersion]];
}

-(int) userVersion{
    
    int userVersion = -1;
    
    GPKGResultSet * result = [self rawQuery:[NSString stringWithFormat:@"PRAGMA user_version"]];
    @try{
        if([result moveToNext]){
            userVersion = [[result getInt:0] intValue];
        }
    }@finally{
        [result close];
    }
    
    return userVersion;
}

-(void) dropTable: (NSString *) table{
    [GPKGSqlUtils dropTable:table withConnection:self];
}

-(void) addWriteFunction: (void *) function withName: (NSString *) name andNumArgs: (int) numArgs{
    GPKGConnectionFunction *connectionFunction = [[GPKGConnectionFunction alloc] initWithFunction:function withName:name andNumArgs:numArgs];
    [self addWriteFunction:connectionFunction];
}

-(void) addWriteFunction: (GPKGConnectionFunction *) function{
    [self.connectionPool addWriteFunction:function];
}

-(void) addWriteFunctions: (NSArray<GPKGConnectionFunction *> *) functions{
    [self.connectionPool addWriteFunctions:functions];
}

@end
