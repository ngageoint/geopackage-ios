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
    GPKGDbConnection *connection = [self.connectionPool resultConnection];
    GPKGResultSet *resultSet = [GPKGSqlUtils queryWithDatabase:connection andStatement:statement andArgs:args];
    return resultSet;
}

-(GPKGResultSet *) queryWithTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andWhereArgs: (NSArray *) whereArgs
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                  andOrderBy: (NSString *) orderBy{
    return [self queryWithDistinct:NO andTable:table andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                    andTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andWhereArgs: (NSArray *) whereArgs
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                  andOrderBy: (NSString *) orderBy{
    return [self queryWithDistinct:distinct
                     andTable:table
                     andColumns:columns
                     andWhere:where
                     andWhereArgs:whereArgs
                     andGroupBy:groupBy
                     andHaving:having
                     andOrderBy:orderBy
                     andLimit:nil];
}

-(GPKGResultSet *) queryWithTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andWhereArgs: (NSArray *) whereArgs
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    return [self queryWithDistinct:NO andTable:table andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryWithDistinct: (BOOL) distinct
                            andTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andWhereArgs: (NSArray *) whereArgs
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    GPKGDbConnection *connection = [self.connectionPool resultConnection];
    GPKGResultSet *resultSet = [GPKGSqlUtils queryWithDatabase:connection
                                        andDistinct:distinct
                                        andTable:table
                                         andColumns:columns
                                           andWhere:where
                                       andWhereArgs:whereArgs
                                         andGroupBy:groupBy
                                          andHaving:having
                                         andOrderBy:orderBy
                                           andLimit:limit];
    return resultSet;
}

-(NSString *) querySQLWithTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                  andOrderBy: (NSString *) orderBy{
    return [self querySQLWithDistinct:NO andTable:table andColumns:columns andWhere:where andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(NSString *) querySQLWithDistinct: (BOOL) distinct
                    andTable: (NSString *) table
                  andColumns: (NSArray<NSString *> *) columns
                    andWhere: (NSString *) where
                  andGroupBy: (NSString *) groupBy
                   andHaving: (NSString *) having
                  andOrderBy: (NSString *) orderBy{
    return [self querySQLWithDistinct:distinct
                     andTable:table
                     andColumns:columns
                     andWhere:where
                     andGroupBy:groupBy
                     andHaving:having
                     andOrderBy:orderBy
                     andLimit:nil];
}

-(NSString *) querySQLWithTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    return [self querySQLWithDistinct:NO andTable:table andColumns:columns andWhere:where andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(NSString *) querySQLWithDistinct: (BOOL) distinct
                          andTable: (NSString *) table
                          andColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                          andGroupBy: (NSString *) groupBy
                           andHaving: (NSString *) having
                          andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    return [GPKGSqlUtils querySQLWithDistinct:distinct
                                        andTable:table
                                         andColumns:columns
                                           andWhere:where
                                         andGroupBy:groupBy
                                          andHaving:having
                                         andOrderBy:orderBy
                                           andLimit:limit];
}

-(int) count:(NSString *) statement{
    return [self count:statement andArgs:nil];
}

-(int) count:(NSString *) statement andArgs: (NSArray *) args{
    GPKGDbConnection *connection = [self.connectionPool connection];
    int count = [GPKGSqlUtils countWithDatabase:connection andStatement:statement andArgs:args];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) countWithTable: (NSString *) table{
    return [self countWithTable:table andWhere:nil];
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where{
    return [self countWithTable:table andWhere:where andWhereArgs:nil];
}

-(int) countWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithTable:table andColumn:nil andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithTable: (NSString *) table andColumn: (NSString *) column{
    return [self countWithTable:table andDistinct:NO andColumn:column];
}

-(int) countWithTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column{
    return [self countWithTable:table andDistinct:distinct andColumn:column andWhere:nil andWhereArgs:nil];
}

-(int) countWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countWithTable:table andDistinct:NO andColumn:column andWhere:where andWhereArgs:whereArgs];
}

-(int) countWithTable: (NSString *) table andDistinct: (BOOL) distinct andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection *connection = [self.connectionPool connection];
    int count = [GPKGSqlUtils countWithDatabase:connection andTable:table andDistinct:distinct andColumn:column andWhere:where andWhereArgs: whereArgs];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(NSNumber *) minWithTable: (NSString *) table andColumn: (NSString *) column{
    return [self minWithTable:table andColumn:column andWhere:nil andWhereArgs:nil];
}

-(NSNumber *) minWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection *connection = [self.connectionPool connection];
    NSNumber *min = [GPKGSqlUtils minWithDatabase:connection andTable:table andColumn:column andWhere:where andWhereArgs: whereArgs];
    [self.connectionPool releaseConnection:connection];
    return min;
}

-(NSNumber *) maxWithTable: (NSString *) table andColumn: (NSString *) column{
    return [self maxWithTable:table andColumn:column andWhere:nil andWhereArgs:nil];
}

-(NSNumber *) maxWithTable: (NSString *) table andColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection *connection = [self.connectionPool connection];
    NSNumber *max = [GPKGSqlUtils maxWithDatabase:connection andTable:table andColumn:column andWhere:where andWhereArgs: whereArgs];
    [self.connectionPool releaseConnection:connection];
    return max;
}

-(void) beginTransaction{
    [self.connectionPool beginTransaction];
}

-(void) beginResettableTransaction{
    [self.connectionPool beginResettableTransaction];
}

-(void) commitTransaction{
    [self.connectionPool commitTransaction];
}

-(void) rollbackTransaction{
    [self.connectionPool rollbackTransaction];
}

-(BOOL) inTransaction{
    return [self.connectionPool inTransaction];
}

-(BOOL) enableForeignKeys{
    BOOL enabled = [self foreignKeys];
    if (!enabled) {
        NSArray<GPKGRow *> *violations = [self foreignKeyCheck];
        if(violations.count == 0){
            [self foreignKeysAsOn:YES];
            enabled = YES;
        }else{
            for(GPKGRow *violation in violations){
                NSLog(@"Foreign Key violation. Table: %@, Row Id: %@, Referred Table: %@, FK Index: %@",
                      [violation valueAtIndex:0],
                      [violation valueAtIndex:1],
                      [violation valueAtIndex:2],
                      [violation valueAtIndex:3]);
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

-(NSArray<GPKGRow *> *) foreignKeyCheck{
    return [GPKGSqlUtils foreignKeyCheckWithConnection:self];
}

-(NSArray<GPKGRow *> *) foreignKeyCheckOnTable: (NSString *) tableName{
    return [GPKGSqlUtils foreignKeyCheckOnTable:tableName withConnection:self];
}

-(long long) insert:(NSString *) statement{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    long long id = [GPKGSqlUtils insertWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
    return id;
}

-(int) update:(NSString *) statement{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    int count = [GPKGSqlUtils updateWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    int count = [GPKGSqlUtils updateWithDatabase:connection andTable:table andValues:values andWhere:where];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) updateWithTable: (NSString *) table andValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    int count = [GPKGSqlUtils updateWithDatabase:connection andTable:table andValues:values andWhere:where andWhereArgs:whereArgs];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(long long) insertWithTable: (NSString *) table andValues: (GPKGContentValues *) values{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    long long id = [GPKGSqlUtils insertWithDatabase:connection andTable:table andValues:values];
    [self.connectionPool releaseConnection:connection];
    return id;
}

-(int) delete:(NSString *) statement{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    int count = [GPKGSqlUtils deleteWithDatabase:connection andStatement:statement];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    int count = [GPKGSqlUtils deleteWithDatabase:connection andTable:table andWhere:where];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(int) deleteWithTable: (NSString *) table andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    int count = [GPKGSqlUtils deleteWithDatabase:connection andTable:table andWhere:where andWhereArgs:whereArgs];
    [self.connectionPool releaseConnection:connection];
    return count;
}

-(void) exec:(NSString *) statement{
    [self exec:statement asResettable:NO];
}

-(void) execResettable:(NSString *) statement{
    [self exec:statement asResettable:YES];
}

-(void) exec:(NSString *) statement asResettable: (BOOL) resettable{
    GPKGDbConnection *connection = [self.connectionPool writeConnection];
    [connection setResettable:resettable];
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

-(BOOL) viewExists: (NSString *) view{
    return [GPKGSQLiteMaster countWithConnection:self andType:GPKG_SMT_VIEW andTable:view] > 0;
}

-(BOOL) tableOrViewExists: (NSString *) name{
    return [GPKGSQLiteMaster countWithConnection:self andTypes:[NSArray arrayWithObjects:[NSNumber numberWithInt:GPKG_SMT_TABLE], [NSNumber numberWithInt:GPKG_SMT_VIEW], nil] andTable:name] > 0;
}

-(BOOL) columnExistsWithTableName: (NSString *) tableName andColumnName: (NSString *) columnName{
    
    BOOL exists = NO;
    
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
    GPKGDbConnection *connection = [self.connectionPool connection];
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
    GPKGDbConnection *connection = [self.connectionPool connection];
    NSArray<NSObject *> *result = [GPKGSqlUtils querySingleColumnResultsWithDatabase:connection andSql:sql andArgs:args andColumn:column andDataType:dataType andLimit:limit];
    [self.connectionPool releaseConnection:connection];
    return result;
}

-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self queryResultsWithSql:sql andArgs:args andDataTypes:nil andLimit:nil];
}

-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes{
    return [self queryResultsWithSql:sql andArgs:args andDataTypes:dataTypes andLimit:nil];
}

-(GPKGRow *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self querySingleRowResultsWithSql:sql andArgs:args andDataTypes:nil];
}

-(GPKGRow *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes{
    NSArray<GPKGRow *> *results = [self queryResultsWithSql:sql andArgs:args andDataTypes:dataTypes andLimit:[NSNumber numberWithInt:1]];
    GPKGRow *singleRow = nil;
    if(results.count > 0){
        singleRow = [results objectAtIndex:0];
    }
    return singleRow;
}

-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andLimit: (NSNumber *) limit{
    return [self queryResultsWithSql:sql andArgs:args andDataTypes:nil andLimit:limit];
}

-(NSArray<GPKGRow *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit{
    GPKGDbConnection *connection = [self.connectionPool connection];
    NSArray<GPKGRow *> *result = [GPKGSqlUtils queryResultsWithDatabase:connection andSql:sql andArgs:args andDataTypes:dataTypes andLimit:limit];
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
    return [GPKGConnection applicationIdOfNumber:[self applicationIdNumber]];
}

-(NSNumber *) applicationIdNumber{
    NSNumber *applicationId = (NSNumber *)[self querySingleResultWithSql:@"PRAGMA application_id" andArgs:nil andDataType:GPKG_DT_MEDIUMINT];
    if(applicationId != nil){
        applicationId = [NSNumber numberWithUnsignedInt:[applicationId intValue]];
    }
    return applicationId;
}

-(NSString *) applicationIdHex{
    NSString *hex = nil;
    NSNumber *applicationId = [self applicationIdNumber];
    if(applicationId != nil){
        hex = [NSString stringWithFormat:@"0x%02x", [applicationId intValue]];
    }
    return hex;
}

+(NSString *) applicationIdOfNumber: (NSNumber *) applicationId{
    NSString *id = nil;
    if(applicationId != nil){
        if([applicationId intValue] == 0){
            id = GPKG_SQLITE_APPLICATION_ID;
        }else{
            int idInt = CFSwapInt32HostToBig([applicationId intValue]);
            NSData *idData = [NSData dataWithBytes:&idInt length:4];
            id = [[NSString alloc] initWithData:idData encoding:NSUTF8StringEncoding];
        }
    }
    return id;
}

-(void) setUserVersion{
    [self setUserVersion:(int)GPKG_USER_VERSION];
}

-(void) setUserVersion: (int) userVersion{
    [self exec:[NSString stringWithFormat:@"PRAGMA user_version = %d", userVersion]];
}

-(NSNumber *) userVersion{
    NSNumber *userVersion = (NSNumber *)[self querySingleResultWithSql:@"PRAGMA user_version" andArgs:nil andDataType:GPKG_DT_MEDIUMINT];
    if(userVersion != nil){
        userVersion = [NSNumber numberWithUnsignedInt:[userVersion intValue]];
    }
    return userVersion;
}

-(NSNumber *) userVersionMajor{
    NSNumber *major = nil;
    NSNumber *userVersion = [self userVersion];
    if (userVersion != nil) {
        major = [NSNumber numberWithInt:[userVersion intValue] / 10000];
    }
    return major;
}

-(NSNumber *) userVersionMinor{
    NSNumber *minor = nil;
    NSNumber *userVersion = [self userVersion];
    if (userVersion != nil) {
        minor = [NSNumber numberWithInt:([userVersion intValue] % 10000) / 100];
    }
    return minor;
}

-(NSNumber *) userVersionPatch{
    NSNumber *patch = nil;
    NSNumber *userVersion = [self userVersion];
    if (userVersion != nil) {
        patch = [NSNumber numberWithInt:[userVersion intValue] % 100];
    }
    return patch;
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
