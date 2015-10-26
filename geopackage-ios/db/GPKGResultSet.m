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

@implementation GPKGResultSet

-(instancetype) initWithStatement:(sqlite3_stmt *) statement andCount: (int) count andConnection: (GPKGDbConnection *) connection{
    self = [super init];
    if(self){
        self.statement = statement;
        self.count = count;
        self.connection = connection;
    
        int totalColumns = sqlite3_column_count(statement);

        NSMutableArray *statementColumns = [[NSMutableArray alloc] init];
        NSMutableDictionary *statementColumnIndex = [[NSMutableDictionary alloc] init];
        
        for (int i=0; i<totalColumns; i++){
            char *columnName = (char *)sqlite3_column_name(statement, i);
            NSString * column = [NSString stringWithUTF8String:columnName];
            [GPKGUtils addObject:column toArray:statementColumns];
            [statementColumnIndex setValue:[NSNumber numberWithInt:i] forKey:column];
        }
        
        self.columns = statementColumns;
        self.columnIndex = statementColumnIndex;
    }
    
    return self;
}

-(BOOL) moveToNext{
    return sqlite3_step(self.statement) == SQLITE_ROW;
}

-(BOOL) moveToFirst{
    return sqlite3_reset(self.statement);
}

-(BOOL) moveToPosition: (int) position{
    for(int i = 0; i < position; i++){
        if(![self moveToNext]){
            return false;
        }
    }
    return true;
}

-(void) close{
    [GPKGSqlUtils closeStatement:self.statement];
    [self.connection releaseConnection];
}

-(NSArray *) getRow{
     NSMutableArray *rowValues = [[NSMutableArray alloc] init];
    [self getRowPopulateValues:rowValues andColumnTypes:nil];
    return rowValues;
}

-(void) getRowPopulateValues: (NSMutableArray *) values andColumnTypes: (NSMutableArray *) types{
    
    NSUInteger totalColumns = [self.columns count];
    
    for (int i=0; i<totalColumns; i++){

        if(types != nil){
            [GPKGUtils addObject:[NSNumber numberWithInt:[self getType:i]] toArray:types];
        }
        
        NSObject * value = [self getValueWithIndex:i];
        [GPKGUtils addObject:value toArray:values];
    }

}

-(NSObject *) getValueWithIndex: (int) index{
    
    NSObject * value = nil;
    
    int type = [self getType:index];
    
    switch (type) {
        case SQLITE_TEXT:;
            value = [self getString:index];
            break;
            
        case SQLITE_INTEGER:;
            value = [self getLong:index];
            break;
            
        case SQLITE_FLOAT:;
            value = [self getDouble:index];
            break;
            
        case SQLITE_NULL:
            break;
            
        case SQLITE_BLOB:
            value = [self getBlob:index];
            break;
            
        default:
            break;
    }
    
    return value;
}

-(int) getColumnIndexWithName: (NSString *) columnName{
    NSNumber * index = [self.columnIndex valueForKey: columnName];
    if(index == nil){
        [NSException raise:@"No Column" format:@"Failed to find column index for column name: %@", columnName];
    }
    return [index intValue];
}

-(int) getType: (int) columnIndex{
    return sqlite3_column_type(self.statement, columnIndex);
}

-(NSString *) getString: (int) columnIndex{
    NSString * value = nil;
    char *dbDataAsChars = (char *)sqlite3_column_text(self.statement, columnIndex);
    if (dbDataAsChars != NULL) {
        value = [NSString  stringWithUTF8String:dbDataAsChars];
    }
    return value;
}

-(NSNumber *) getInt: (int) columnIndex{
    int intValue = sqlite3_column_int(self.statement, columnIndex);
    return [NSNumber numberWithInt: intValue];
}

-(NSData *) getBlob: (int) columnIndex{
    NSData *blobValue = [[NSData alloc] initWithBytes:sqlite3_column_blob(self.statement, columnIndex) length:sqlite3_column_bytes(self.statement,  columnIndex)];
    return blobValue;
}

-(NSNumber *) getLong: (int) columnIndex{
    sqlite3_int64 intValue = sqlite3_column_int64(self.statement, columnIndex);
    return [NSNumber numberWithLongLong:intValue];
}

-(NSNumber *) getDouble: (int) columnIndex{
    double doubleValue = sqlite3_column_double(self.statement, columnIndex);
    return [NSNumber numberWithDouble: doubleValue];
}

@end
