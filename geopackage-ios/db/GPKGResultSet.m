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
        self.hasNext = YES;
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
            return false;
        }
    }
    return true;
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

-(NSArray *) row{
     NSMutableArray *rowValues = [[NSMutableArray alloc] init];
    [self rowPopulateValues:rowValues andColumnTypes:nil];
    return rowValues;
}

-(void) rowPopulateValues: (NSMutableArray *) values andColumnTypes: (NSMutableArray *) types{
    
    NSUInteger totalColumns = [self.columns count];
    
    for (int i=0; i<totalColumns; i++){

        if(types != nil){
            [GPKGUtils addObject:[NSNumber numberWithInt:[self type:i]] toArray:types];
        }
        
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

@end
