//
//  GPKGUserTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTable.h"
#import "GPKGUtils.h"

@interface GPKGUserTable()

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

/**
 *  Constraints
 */
@property (nonatomic, strong) NSMutableArray<GPKGConstraint *> *constraints;

/**
 * Type Constraints
 */
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<GPKGConstraint *> *> *typedContraints;

@end

@implementation GPKGUserTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super init];
    if(self != nil){
        self.nameToIndex = [[NSMutableDictionary alloc] init];
        self.constraints = [[NSMutableArray alloc] init];
        self.typedContraints = [[NSMutableDictionary alloc] init];
        self.tableName = tableName;
        self.columns = [NSMutableArray arrayWithArray:columns];
        
        [self updateColumns];
    }
    return self;
}

-(instancetype) initWithUserTable: (GPKGUserTable *) userTable{
    self = [super init];
    if(self != nil){

        self.tableName = userTable.tableName;
        self.columnNames = [NSMutableArray arrayWithArray:userTable.columnNames];
        self.columns = [[NSMutableArray alloc] init];
        for(GPKGUserColumn *column in userTable.columns){
            GPKGUserColumn *copiedColumn = [column mutableCopy];
            [_columns addObject:copiedColumn];
        }
        self.nameToIndex = [NSMutableDictionary dictionaryWithDictionary:userTable.nameToIndex];
        self.pkIndex = userTable.pkIndex;
        
        self.constraints = [[NSMutableArray alloc] init];
        self.typedContraints = [[NSMutableDictionary alloc] init];
        for(GPKGConstraint *constraint in userTable.constraints){
            [self addConstraint:[constraint mutableCopy]];
        }
        self.contents = userTable.contents;
        
    }
    return self;
}

-(void) updateColumns{
    
    [self.nameToIndex removeAllObjects];
    
    NSMutableSet<NSNumber *> *indices = [[NSMutableSet alloc] init];
    
    // Check for missing indices and duplicates
    NSMutableArray<GPKGUserColumn *> *needsIndex = [[NSMutableArray alloc] init];
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
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"index" ascending:true];
    self.columns = [NSMutableArray arrayWithArray:[self.columns sortedArrayUsingDescriptors:@[sort]]];
    
    self.pkIndex = -1;
    self.columnNames = [[NSMutableArray alloc] initWithCapacity:self.columns.count];
    
    for (int index = 0; index < self.columns.count; index++) {
        
        GPKGUserColumn *column = [self.columns objectAtIndex:index];
        
        if(column.index != index){
            [NSException raise:@"No Column" format:@"No column found at index: %d, Table Name: %@", index, self.tableName];
        }
        
        if(column.primaryKey){
            if(self.pkIndex != -1){
                [NSException raise:@"Multiple Primary Keys" format:@"More than one primary key column was found for table '%@'. Index %d and %d", self.tableName, self.pkIndex, index];
            }
            self.pkIndex = index;
        }
        
        NSString *columnName = column.name;
        [_columnNames addObject:columnName];
        [self.nameToIndex setObject:[NSNumber numberWithInt:index] forKey:columnName];
    }
    
}

-(NSString *) dataType{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) duplicateCheckWithIndex: (int) index andPreviousIndex: (NSNumber *) previousIndex andColumn: (NSString *) column{
    if(previousIndex != nil){
        [NSException raise:@"Duplicate Column" format:@"More than one %@ column was found for table '%@'. Index %@ and %d", column, self.tableName, previousIndex, index];
    }
}

-(void) typeCheckWithExpected: (enum GPKGDataType) expected andColumn: (GPKGUserColumn *) column{
    enum GPKGDataType actual = column.dataType;
    if(actual != expected){
        [NSException raise:@"Unexpected Data Type" format:@"Unexpected %@ column data type was found for table '%@', expected: %@, actual: %@", column.name, self.tableName, [GPKGDataTypes name:expected], column.type];
    }
}

-(void) missingCheckWithIndex: (NSNumber *) index andColumn: (NSString *) column{
    if(index == nil){
        [NSException raise:@"Missing Column" format:@"No %@ column was found for table '%@'", column, self.tableName];
    }
}

-(int) getColumnIndexWithColumnName: (NSString *) columnName{
    NSNumber * index = [GPKGUtils objectForKey:columnName inDictionary:self.nameToIndex];
    if(index == nil){
        [NSException raise:@"No Column" format:@"Column does not exists in table '%@', column: %@", self.tableName, columnName];
    }
    return [index intValue];
}

-(NSArray<NSString *> *) columnNames{
    return _columnNames;
}

-(NSString *) getColumnNameWithIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:self.columnNames];
}

-(NSArray<GPKGUserColumn *> *) columns{
    return _columns;
}

-(GPKGUserColumn *) getColumnWithIndex: (int) index{
    return [GPKGUtils objectAtIndex:index inArray:self.columns];
}

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName{
    return [self getColumnWithIndex:[self getColumnIndexWithColumnName:columnName]];
}

-(BOOL) hasColumnWithColumnName: (NSString *) columnName{
    return [self.nameToIndex objectForKey:columnName] != nil;
}

-(int) columnCount{
    return (int)[self.columns count];
}

-(BOOL) hasPkColumn{
    return self.pkIndex >= 0;
}

-(int) pkIndex{
    return _pkIndex;
}

-(GPKGUserColumn *) getPkColumn{
    GPKGUserColumn * column = nil;
    if([self hasPkColumn]){
        column = [GPKGUtils objectAtIndex:self.pkIndex inArray:self.columns];
    }
    return column;
}

-(void) addConstraint: (GPKGConstraint *) constraint{
    [GPKGUtils addObject:constraint toArray:_constraints];
    NSNumber *typeNumber = [NSNumber numberWithInteger:constraint.type];
    NSMutableArray<GPKGConstraint *> *typeConstraints = [self.typedContraints objectForKey:typeNumber];
    if(typeConstraints == nil){
        typeConstraints = [[NSMutableArray alloc] init];
        [self.typedContraints setObject:typeConstraints forKey:typeNumber];
    }
    [typeConstraints addObject:constraint];
}

-(void) addConstraints: (NSArray<GPKGConstraint *> *) constraints{
    for(GPKGConstraint *constraint in constraints){
        [self addConstraint:constraint];
    }
}

-(BOOL) hasConstraints{
    return self.constraints.count > 0;
}

-(NSArray<GPKGConstraint *> *) constraints{
    return self.constraints;
}

-(NSArray<GPKGConstraint *> *) constraintsForType: (enum GPKGConstraintType) type{
    NSArray<GPKGConstraint *> *constraints = [self.typedContraints objectForKey:[NSNumber numberWithInteger:type]];
    if(constraints == nil){
        constraints = [[NSArray alloc] init];
    }
    return constraints;
}

-(NSArray<GPKGConstraint *> *) clearConstraints{
    NSArray<GPKGConstraint *> *constraintsCopy = [NSArray arrayWithArray:self.constraints];
    [_constraints removeAllObjects];
    [_typedContraints removeAllObjects];
    return constraintsCopy;
}

-(NSArray *) columnsOfType: (enum GPKGDataType) type{
    NSMutableArray * columnsOfType = [[NSMutableArray alloc] init];
    for(GPKGUserColumn *column in self.columns){
        if(column.dataType == type){
            [columnsOfType addObject:column];
        }
    }
    return columnsOfType;
}

-(void) setContents:(GPKGContents *)contents{
    _contents = contents;
    if(contents != nil){
        [self validateContents:contents];
    }
}

/**
 * Validate that the set contents are valid
 *
 * @param contents
 *            contents
 */
-(void) validateContents: (GPKGContents *) contents{
    
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
    [self renameColumnWithIndex:[self getColumnIndexWithColumnName:columnName] toColumn:newColumnName];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [[_columns  objectAtIndex:index] setName:newColumnName];
    [self updateColumns];
}

-(void) dropColumn: (GPKGUserColumn *) column{
    [self dropColumnWithIndex:column.index];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [self dropColumnWithIndex:[self getColumnIndexWithColumnName:columnName]];
}

-(void) dropColumnWithIndex: (int) index{
    [_columns removeObjectAtIndex:index];
    for(GPKGUserColumn *column in _columns){
        [column resetIndex];
    }
    [self updateColumns];
}

-(void) alterColumn: (GPKGUserColumn *) column{
    GPKGUserColumn *existingColumn = [self getColumnWithColumnName:column.name];
    [column setIndex:existingColumn.index];
    [_columns replaceObjectAtIndex:column.index withObject:column];
}

-(void) addColumnWithoutUpdate: (GPKGUserColumn *) column{
    [_columns addObject:column];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserTable *userTable = [[GPKGUserTable alloc] initWithUserTable:self];
    return userTable;
}

@end
