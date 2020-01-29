//
//  GPKGUserResultSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/28/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserResultSet.h"

@interface GPKGUserResultSet ()

/**
 * Table
 */
@property (nonatomic, strong) GPKGUserTable *table;

/**
 * Columns
 */
@property (nonatomic, strong) GPKGUserColumns *columnsTemp;

@end

@implementation GPKGUserResultSet

-(instancetype) initWithTable: (GPKGUserTable *) table andStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection{
    return [self initWithTable:table andColumns:[table userColumns] andStatement:statement andCount:count andConnection:connection];
}

-(instancetype) initWithTable: (GPKGUserTable *) table andColumnNames: (NSArray<NSString *> *) columnNames andStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection{
    self = [super initWithStatement:statement andCount:count andConnection:connection];
    if(self != nil){
        GPKGUserColumns *userColumns = nil;
        if(columnNames != nil){
            userColumns = [table createUserColumnsWithNames:columnNames];
        }else{
            userColumns = [table userColumns];
        }
        self.table = table;
        self.columns = userColumns;
    }
    return self;
}

-(instancetype) initWithTable: (GPKGUserTable *) table andColumns: (GPKGUserColumns *) columns andStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection{
    self = [super initWithStatement:statement andCount:count andConnection:connection];
    if(self != nil){
        self.table = table;
        self.columns = columns;
    }
    return self;
}

-(NSObject *) valueWithColumn: (GPKGUserColumn *) column{
    return [super valueWithColumnName:column.name];
}

-(int) columnIndexWithName: (NSString *) columnName{
    return [_columnsTemp columnIndexWithColumnName:columnName];
}

-(NSNumber *) id{
    NSNumber *id = nil;
    
    GPKGUserColumn *pkColumn = [_columnsTemp pkColumn];
    if(pkColumn == nil){
        NSMutableString *error = [NSMutableString stringWithString:@"No primary key column in "];
        if(_columnsTemp.custom){
            [error appendString:@"custom specified table columns. "];
        }
        [error appendFormat:@"table: %@", _columnsTemp.tableName];
        if(_columnsTemp.custom){
            [error appendFormat:@", columns: [%@]", [[_columnsTemp columnNames] componentsJoinedByString:@", "]];
        }
        [NSException raise:@"No PK Column" format:error, nil];
    }
    
    NSObject *objectValue = [self valueWithColumn:pkColumn];
    if([objectValue isKindOfClass:[NSNumber class]]){
        id = (NSNumber *) objectValue;
    }else{
        [NSException raise:@"Non Number PK" format:@"Primary Key value was not a number. table: %@, index: %d, name: %@, value: %@", _columnsTemp.tableName, pkColumn.index, pkColumn.name, objectValue];
    }
    
    return id;
}

-(GPKGUserTable *) table{
    return _table;
}

-(GPKGUserColumns *) columns{
    return _columnsTemp;
}

@end
