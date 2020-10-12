//
//  GPKGResultSet.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGResultSet.h"
#import "GPKGSqlUtils.h"
#import "GPKGUtils.h"

@interface GPKGResultSet ()

@property (nonatomic) BOOL hasNext;

@end

@implementation GPKGResultSet

-(instancetype) initWithStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection{
    self = [super init];
    if(self){
        self.statement = statement;
        self.count = count;
        self.connection = connection;
    
        int totalColumns = sqlite3_column_count(statement);

        NSMutableArray<NSString *> *statementColumns = [[NSMutableArray alloc] init];
        NSMutableDictionary<NSString *, NSNumber *> *statementColumnIndex = [[NSMutableDictionary alloc] init];
        
        for (int i=0; i<totalColumns; i++){
            char *columnName = (char *)sqlite3_column_name(statement, i);
            NSString * column = [NSString stringWithUTF8String:columnName];
            [GPKGUtils addObject:column toArray:statementColumns];
            [statementColumnIndex setValue:[NSNumber numberWithInt:i] forKey:column];
        }
        
        self.columnNames = statementColumns;
        self.columnIndex = statementColumnIndex;
        self.hasNext = YES;
    }
    
    return self;
}

-(instancetype) initWithResultSet: (GPKGResultSet *) resultSet{
    self = [super init];
    if(self){
        self.statement = resultSet.statement;
        self.count = resultSet.count;
        self.connection = resultSet.connection;
        self.columnNames = resultSet.columnNames;
        self.columnIndex = resultSet.columnIndex;
        self.columns = resultSet.columns;
        self.hasNext = resultSet.hasNext;
    }
    return self;
}

-(BOOL) moveToNext{
    if(self.hasNext){
        self.hasNext = sqlite3_step(self.statement) == SQLITE_ROW;
    }
    return self.hasNext;
}

-(BOOL) moveToFirst{
    self.hasNext = YES;
    return sqlite3_reset(self.statement);
}

-(BOOL) moveToPosition: (int) position{
    for(int i = 0; i <= position; i++){
        if(![self moveToNext]){
            return NO;
        }
    }
    return YES;
}

-(void) close{
    [self closeStatement];
    [self.connection releaseConnection];
    self.connection = nil;
}

-(void) closeStatement{
    [GPKGSqlUtils closeStatement:self.statement];
    self.statement = nil;
}

-(int) columnCount{
    return (int) _columnNames.count;
}

-(NSArray<NSObject *> *) row{
     NSMutableArray *rowValues = [[NSMutableArray alloc] init];
    [self rowPopulateValues:rowValues];
    return rowValues;
}

-(void) rowPopulateValues: (NSMutableArray *) values{
    
    NSUInteger totalColumns = [self.columnNames count];
    
    for (int i=0; i<totalColumns; i++){
        NSObject * value = [self valueWithIndex:i];
        [GPKGUtils addObject:value toArray:values];
    }

}

-(NSObject *) valueWithIndex: (int) index{
    
    NSObject * value = nil;
    
    int type = [self type:index];
    
    switch (type) {
        case SQLITE_TEXT:;
            value = [self stringWithIndex:index];
            break;
            
        case SQLITE_INTEGER:;
            value = [self longWithIndex:index];
            break;
            
        case SQLITE_FLOAT:;
            value = [self doubleWithIndex:index];
            break;
            
        case SQLITE_NULL:
            break;
            
        case SQLITE_BLOB:
            value = [self blobWithIndex:index];
            break;
            
        default:
            break;
    }
    
    return value;
}

-(NSObject *) valueWithColumnName: (NSString *) columnName{
    return [self valueWithIndex:[self columnIndexWithName:columnName]];
}

-(int) columnIndexWithName: (NSString *) columnName{
    NSNumber * index = [self.columnIndex valueForKey: columnName];
    if(index == nil){
        [NSException raise:@"No Column" format:@"Failed to find column index for column name: %@", columnName];
    }
    return [index intValue];
}

-(int) type: (int) columnIndex{
    return sqlite3_column_type(self.statement, columnIndex);
}

-(NSString *) stringWithIndex: (int) columnIndex{
    NSString * value = nil;
    char *dbDataAsChars = (char *)sqlite3_column_text(self.statement, columnIndex);
    if (dbDataAsChars != NULL) {
        value = [NSString  stringWithUTF8String:dbDataAsChars];
    }
    return value;
}

-(NSNumber *) intWithIndex: (int) columnIndex{
    int intValue = sqlite3_column_int(self.statement, columnIndex);
    return [NSNumber numberWithInt: intValue];
}

-(NSData *) blobWithIndex: (int) columnIndex{
    NSData *blobValue = [[NSData alloc] initWithBytes:sqlite3_column_blob(self.statement, columnIndex) length:sqlite3_column_bytes(self.statement,  columnIndex)];
    return blobValue;
}

-(NSNumber *) longWithIndex: (int) columnIndex{
    sqlite3_int64 intValue = sqlite3_column_int64(self.statement, columnIndex);
    return [NSNumber numberWithLongLong:intValue];
}

-(NSNumber *) doubleWithIndex: (int) columnIndex{
    double doubleValue = sqlite3_column_double(self.statement, columnIndex);
    return [NSNumber numberWithDouble: doubleValue];
}

-(int) countAndClose{
    [self close];
    return _count;
}

-(void) setColumnsFromTable: (GPKGUserTable *) table{
    if([[table columnNames] isEqualToArray:_columnNames]){
        _columns = [table userColumns];
    }else{
        _columns = [table createUserColumnsWithNames:_columnNames];
    }
}

-(NSNumber *) id{
    NSNumber *id = nil;

    if(_columns == nil){
        [NSException raise:@"No User Columns" format:@"No user columns set in the result set. columns: [%@]", [_columnNames componentsJoinedByString:@", "]];
    }
    
    GPKGUserColumn *pkColumn = [_columns pkColumn];
    if(pkColumn == nil){
        NSMutableString *error = [NSMutableString stringWithString:@"No id column in "];
        if(_columns.custom){
            [error appendString:@"custom specified table columns. "];
        }
        [error appendFormat:@"table: %@", _columns.tableName];
        if(_columns.custom){
            [error appendFormat:@", columns: [%@]", [[_columns columnNames] componentsJoinedByString:@", "]];
        }
        [NSException raise:@"No Id Column" format:error, nil];
    }
    
    NSObject *objectValue = [self valueWithColumnName:pkColumn.name];
    if(objectValue != nil){
        if([objectValue isKindOfClass:[NSNumber class]]){
            id = (NSNumber *) objectValue;
        }else{
            [NSException raise:@"Non Number Id" format:@"Id value was not a number. table: %@, index: %d, name: %@, value: %@", _columns.tableName, pkColumn.index, pkColumn.name, objectValue];
        }
    }
    
    return id;
}

@end
