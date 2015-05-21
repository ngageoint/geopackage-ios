//
//  GPKGUserTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"

@implementation GPKGUserTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super init];
    if(self != nil){
    
        self.tableName = tableName;
        self.columns = columns;
    
        NSNumber * pk = nil;
    
        NSMutableSet * indices = [[NSMutableSet alloc]init];
    
        // Build the column name array for queries, find the primary key and geometry
        NSMutableArray * tempColumnNames = [NSMutableArray arrayWithCapacity:[columns count]];
        NSMutableDictionary * tempNameToIndex = [NSMutableDictionary dictionaryWithCapacity:[columns count]];
        for(GPKGUserColumn * column in columns){
        
            int index = column.index;
            NSNumber * indexNumber = [NSNumber numberWithInt:index];
        
            if(column.primaryKey){
                if(pk != nil){
                    [NSException raise:@"Multiple Primary Keys" format:@"More than one primary key column was found for table '%@'. Index %@ and %d", tableName, pk, index];
                }
                pk = indexNumber;
            }
        
            // Check for duplicate indices
            if([indices containsObject:indexNumber]){
                [NSException raise:@"Duplicate Index" format:@"Duplicate index: %d, Table Name: %@", index, tableName];
            }
            [indices addObject:indexNumber];
            
            [tempColumnNames replaceObjectAtIndex:index withObject:column.name];
            [tempNameToIndex setObject:indexNumber forKey:column.name];
        }
        self.columnNames = tempColumnNames;
        self.nameToIndex = tempNameToIndex;
        
        if(pk == nil){
            [NSException raise:@"No Primary Key" format:@"No primary key column was found for table '%@'", tableName];
        }
        self.pkIndex = [pk intValue];
        
        // Verify the columns have ordered indices without gaps
        for(int i = 0; i < [columns count]; i++){
            if(![indices containsObject:[NSNumber numberWithInt:i]]){
                [NSException raise:@"Missing Column" format:@"No column found at index: %d, Table Name: %@", i, tableName];
            }
        }
        
        // Sort the columns by index
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:true];
        columns = [columns sortedArrayUsingDescriptors:@[sort]];
    }
    return self;
}

-(void) duplicateCheckWithIndex: (int) index andPreviousIndex: (NSNumber *) previousIndex andColumn: (NSString *) column{
    if(previousIndex != nil){
        [NSException raise:@"Duplicate Column" format:@"More than one %@ column was found for table '%@'. Index %@ and %d", column, self.tableName, previousIndex, index];
    }
}

-(void) typeCheckWithExpected: (enum GPKGDataType) expected andColumn: (GPKGUserColumn *) column{
    enum GPKGDataType actual = column.dataType;
    if(actual != expected){
        [NSException raise:@"Unexpected Data Type" format:@"Unexpected %@ column data type was found for table '%@', expected: %@, actual: %@", column.name, self.tableName, [GPKGDataTypes name:expected], [column getTypeName]];
    }
}

-(void) missingCheckWithIndex: (NSNumber *) index andColumn: (NSString *) column{
    if(index == nil){
        [NSException raise:@"Missing Column" format:@"No %@ column was found for table '%@'", column, self.tableName];
    }
}

-(int) getColumnIndexWithColumnName: (NSString *) columnName{
    NSNumber * index = [self.nameToIndex objectForKey:columnName];
    if(index == nil){
        [NSException raise:@"No Column" format:@"Column does not exists in table '%@', column: %@", self.tableName, columnName];
    }
    return [index intValue];
}

-(NSString *) getColumnNameWithIndex: (int) index{
    return [self.columnNames objectAtIndex:index];
}

-(GPKGUserColumn *) getColumnWithIndex: (int) index{
    return [self.columns objectAtIndex:index];
}

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName{
    return [self getColumnWithIndex:[self getColumnIndexWithColumnName:columnName]];
}

-(int) columnCount{
    return (int)[self.columns count];
}

-(GPKGUserColumn *) getPkColumn{
    return [self.columns objectAtIndex:self.pkIndex];
}

-(void) addUniqueConstraint: (GPKGUserUniqueConstraint *) uniqueConstraint{
    [self.uniqueConstraints addObject:uniqueConstraint];
}

@end
