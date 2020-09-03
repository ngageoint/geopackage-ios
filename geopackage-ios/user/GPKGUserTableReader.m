//
//  GPKGUserTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGSQLiteMaster.h"
#import "GPKGTableInfo.h"

@implementation GPKGUserTableReader

-(instancetype) initWithTable: (NSString *) tableName{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
    }
    return self;
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGUserColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGUserTable *) readTableWithConnection: (GPKGConnection *) db{
    
    NSMutableArray<GPKGUserColumn *> *columns = [[NSMutableArray alloc] init];
    
    GPKGTableInfo *tableInfo = [GPKGTableInfo infoWithConnection:db andTable:self.tableName];
    if(tableInfo == nil){
        [NSException raise:@"No Table" format:@"Table does not exist: %@", self.tableName];
    }
    
    GPKGTableConstraints *constraints = [GPKGSQLiteMaster queryForConstraintsWithConnection:db andTable:self.tableName];
    
    for(GPKGTableColumn *tableColumn in [tableInfo columns]){
        if((int)[tableColumn dataType] < 0){
            NSLog(@"Unexpected column data type: '%@', column: %@", [tableColumn type], tableColumn.name);
        }
        GPKGUserColumn *column = [self createColumnWithTableColumn:tableColumn];
        [column setAutoincrement:NO];
        
        GPKGColumnConstraints *columnConstraints = [constraints columnConstraintsForColumn:column.name];
        if(columnConstraints != nil && [columnConstraints hasConstraints]){
            [column clearConstraintsWithReset:NO];
            [column addColumnConstraints:columnConstraints];
        }
        
        [columns addObject:column];
    }
    
    GPKGUserTable *table = [self createTableWithName:self.tableName andColumns:columns];
    
    [table addConstraints:[constraints tableConstraints]];
    
    return table;
}

@end
