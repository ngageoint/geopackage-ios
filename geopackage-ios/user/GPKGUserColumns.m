//
//  GPKGUserColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserColumns.h"
#import "GPKGUtils.h"

@interface GPKGUserColumns()

/**
 *  Array of column names
 */
@property (nonatomic, strong) NSMutableArray<NSString *> *columnNames;

/**
 *  Array of columns
 */
@property (nonatomic, strong) NSMutableArray<GPKGUserColumn *> *columns;

/**
 *  Mapping between column names and their index
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *nameToIndex;

/**
 *  Primary key column index
 */
@property (nonatomic) int pkIndex;

@end

@implementation GPKGUserColumns

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
        self.columns = [NSMutableArray arrayWithArray:columns];
        self.custom = custom;
        self.nameToIndex = [NSMutableDictionary dictionary];
        self.pkModifiable = NO;
        self.valueValidation = YES;
    }
    return self;
}

-(instancetype) initWithUserColumns: (GPKGUserColumns *) userColumns{
    self = [super init];
    if(self != nil){
        self.tableName = userColumns.tableName;
        self.columnNames = [NSMutableArray arrayWithArray:userColumns.columnNames];
        self.columns = [NSMutableArray array];
        for(GPKGUserColumn *column in userColumns.columns){
            GPKGUserColumn *copiedColumn = [column mutableCopy];
            [_columns addObject:copiedColumn];
        }
        self.nameToIndex = [NSMutableDictionary dictionaryWithDictionary:userColumns.nameToIndex];
        self.pkIndex = userColumns.pkIndex;
        self.pkModifiable = userColumns.pkModifiable;
        self.valueValidation = userColumns.valueValidation;
    }
    return self;
}

-(void) updateColumns{
    
    [self.nameToIndex removeAllObjects];
    
    if(!self.custom){
    
        NSMutableSet<NSNumber *> *indices = [NSMutableSet set];
        
        // Check for missing indices and duplicates
        NSMutableArray<GPKGUserColumn *> *needsIndex = [NSMutableArray array];
        for (GPKGUserColumn *column in self.columns) {
            if ([column hasIndex]) {
                NSNumber *index = [NSNumber numberWithInt:column.index];
                if([indices containsObject:index]){
                    [NSException raise:@"Duplicate Index" format:@"Duplicate index: %@, Table Name: %@", index, self.tableName];
                }else{
                    [indices addObject:index];
                }
            } else {
                [needsIndex addObject:column];
            }
        }
        
        // Update columns that need an index
        int currentIndex = -1;
        for (GPKGUserColumn *column in needsIndex) {
            while([indices containsObject:[NSNumber numberWithInt:++currentIndex]]){
            }
            [column setIndex:currentIndex];
        }
        
        // Sort the columns by index
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES];
        self.columns = [NSMutableArray arrayWithArray:[self.columns sortedArrayUsingDescriptors:@[sort]]];
    
    }
        
    self.pkIndex = -1;
    self.columnNames = [NSMutableArray arrayWithCapacity:self.columns.count];
    
    for (int index = 0; index < self.columns.count; index++) {
        
        GPKGUserColumn *column = [self.columns objectAtIndex:index];
        NSString *columnName = column.name;
        NSString * lowerCaseColumnName = [columnName lowercaseString];
        
        if(!self.custom){
        
            if(column.index != index){
                [NSException raise:@"No Column" format:@"No column found at index: %d, Table Name: %@", index, self.tableName];
            }
            
            if([self.nameToIndex objectForKey:lowerCaseColumnName]){
                [NSException raise:@"Duplicate Column" format:@"Duplicate column found at index: %d, Table Name: %@, Name: %@", index, self.tableName, columnName];
            }
            
        }
        
        if(column.primaryKey){
            if(self.pkIndex != -1){
                NSMutableString *error = [NSMutableString stringWithString:@"More than one primary key column was found for "];
                if(self.custom){
                    [error appendString:@"custom specified table columns"];
                }else{
                    [error appendString:@"table"];
                }
                [error appendFormat:@". table: %@, index1: %d, index2: %d", self.tableName, self.pkIndex, index];
                if(self.custom){
                    [error appendFormat:@", columns: [%@]", [self.columnNames componentsJoinedByString:@", "]];
                }
                [NSException raise:@"Multiple Primary Keys" format:error, nil];
            }
            self.pkIndex = index;
        }
        
        [_columnNames addObject:columnName];
        [self.nameToIndex setObject:[NSNumber numberWithInt:index] forKey:lowerCaseColumnName];
    }
    
}

-(void) duplicateCheckWithIndex: (int) index andPreviousIndex: (NSNumber *) previousIndex andColumn: (NSString *) column{
    if(previousIndex != nil){
        NSLog(@"More than one %@ column was found for table '%@'. Index %@ and %d", column, self.tableName, previousIndex, index);
    }
}

-(void) typeCheckWithExpected: (enum GPKGDataType) expected andColumn: (GPKGUserColumn *) column{
    enum GPKGDataType actual = column.dataType;
    if(actual != expected){
        NSLog(@"Unexpected %@ column data type was found for table '%@', expected: %@, actual: %@", column.name, self.tableName, [GPKGDataTypes name:expected], column.type);
    }
}

-(void) missingCheckWithIndex: (NSNumber *) index andColumn: (NSString *) column{
    if(index == nil){
        NSLog(@"No %@ column was found for table '%@'", column, self.tableName);
    }
}

-(int) columnIndexWithColumnName: (NSString *) columnName{
    return [[self columnIndexWithColumnName:columnName andRequired:YES] intValue];
}

-(NSNumber *) columnIndexWithColumnName: (NSString *) columnName andRequired: (BOOL) required{
    NSNumber *index = [GPKGUtils objectForKey:[columnName lowercaseString] inDictionary:self.nameToIndex];
    if(required && index == nil){
        NSMutableString *error = [NSMutableString stringWithString:@"Column does not exist in "];
        if(self.custom){
            [error appendString:@"custom specified table columns"];
        }else{
            [error appendString:@"table"];
        }
        [error appendFormat:@". table: %@, column: %@", self.tableName, columnName];
        if(self.custom){
            [error appendFormat:@", columns: [%@]", [self.columnNames componentsJoinedByString:@", "]];
        }
        [NSException raise:@"No Column" format:error, nil];
    }
    return index;
}

-(NSArray<NSString *> *) columnNames{
    return _columnNames;
}

-(NSString *) columnNameWithIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:self.columnNames];
}

-(NSArray<GPKGUserColumn *> *) columns{
    return _columns;
}

-(GPKGUserColumn *) columnWithIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:self.columns];
}

-(GPKGUserColumn *) columnWithColumnName: (NSString *) columnName{
    return [self columnWithIndex:[self columnIndexWithColumnName:columnName]];
}

-(BOOL) hasColumnWithColumnName: (NSString *) columnName{
    return [self.nameToIndex objectForKey:[columnName lowercaseString]] != nil;
}

-(int) columnCount{
    return (int)[self.columns count];
}

-(BOOL) hasIdColumn{
    return [self hasPkColumn];
}

-(int) idIndex{
    return [self pkIndex];
}

-(GPKGUserColumn *) idColumn{
    return [self pkColumn];
}

-(NSString *) idColumnName{
    return [self pkColumnName];
}

-(BOOL) hasPkColumn{
    return self.pkIndex >= 0;
}

-(int) pkIndex{
    return _pkIndex;
}

-(GPKGUserColumn *) pkColumn{
    GPKGUserColumn *column = nil;
    if([self hasPkColumn]){
        column = [GPKGUtils objectAtIndex:self.pkIndex inArray:self.columns];
    }
    return column;
}

-(NSString *) pkColumnName{
    NSString *name = nil;
    GPKGUserColumn *pkColumn = [self pkColumn];
    if(pkColumn != nil){
        name = pkColumn.name;
    }
    return name;
}

-(NSArray *) columnsOfType: (enum GPKGDataType) type{
    NSMutableArray * columnsOfType = [NSMutableArray array];
    for(GPKGUserColumn *column in self.columns){
        if(column.dataType == type){
            [columnsOfType addObject:column];
        }
    }
    return columnsOfType;
}

-(void) addColumn: (GPKGUserColumn *) column{
    [_columns addObject:column];
    [self updateColumns];
}

-(void) renameColumn: (GPKGUserColumn *) column toColumn: (NSString *) newColumnName{
    [self renameColumnWithName:column.name toColumn:newColumnName];
    [column setName:newColumnName];
}

-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    [self renameColumnWithIndex:[self columnIndexWithColumnName:columnName] toColumn:newColumnName];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [[_columns  objectAtIndex:index] setName:newColumnName];
    [self updateColumns];
}

-(void) dropColumn: (GPKGUserColumn *) column{
    [self dropColumnWithIndex:column.index];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [self dropColumnWithIndex:[self columnIndexWithColumnName:columnName]];
}

-(void) dropColumnWithIndex: (int) index{
    [_columns removeObjectAtIndex:index];
    for(GPKGUserColumn *column in _columns){
        [column resetIndex];
    }
    [self updateColumns];
}

-(void) alterColumn: (GPKGUserColumn *) column{
    GPKGUserColumn *existingColumn = [self columnWithColumnName:column.name];
    [column setIndex:existingColumn.index];
    [_columns replaceObjectAtIndex:column.index withObject:column];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserColumns *userColumns = [[[self class] allocWithZone:zone] initWithUserColumns:self];
    return userColumns;
}

@end
