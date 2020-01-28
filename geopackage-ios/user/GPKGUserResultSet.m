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
@property (nonatomic, strong) GPKGUserColumns *columns;

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
    return [_columns columnIndexWithColumnName:columnName];
}

-(NSNumber *) id{
    NSNumber *id = nil;
    
    GPKGUserColumn *pkColumn = [_columns pkColumn];
    if(pkColumn == nil){
        NSMutableString *error = [NSMutableString stringWithString:@"No primary key column in "];
        if(_columns.custom){
            [error appendString:@"custom specified table columns. "];
        }
        [error appendFormat:@"table: %@", _columns.tableName];
        if(_columns.custom){
            [error appendFormat:@", columns: [%@]", [[_columns columnNames] componentsJoinedByString:@", "]];
        }
        [NSException raise:@"No PK Column" format:error, nil];
    }
    
    NSObject *objectValue = [self valueWithColumn:pkColumn];
    if([objectValue isKindOfClass:[NSNumber class]]){
        id = (NSNumber *) objectValue;
    }else{
        [NSException raise:@"Non Number PK" format:@"Primary Key value was not a number. table: %@, index: %d, name: %@, value: %@", _columns.tableName, pkColumn.index, pkColumn.name, objectValue];
    }
    
    return id;
}

-(GPKGUserTable *) table{
    return _table;
}

-(GPKGUserColumns *) columns{
    return _columns;
}

@end
