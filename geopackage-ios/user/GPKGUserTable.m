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
 *  Columns
 */
@property (nonatomic, strong) GPKGUserColumns *userColumns;

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

-(instancetype) initWithColumns: (GPKGUserColumns *) columns{
    self = [super init];
    if(self != nil){
        self.userColumns = columns;
        self.constraints = [[NSMutableArray alloc] init];
        self.typedContraints = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(instancetype) initWithUserTable: (GPKGUserTable *) userTable{
    self = [super init];
    if(self != nil){

        self.userColumns = [userTable.columns mutableCopy];
        self.constraints = [[NSMutableArray alloc] init];
        self.typedContraints = [[NSMutableDictionary alloc] init];
        for(GPKGConstraint *constraint in userTable.constraints){
            [self addConstraint:[constraint mutableCopy]];
        }
        self.contents = userTable.contents;
        
    }
    return self;
}

-(NSString *) dataType{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGUserColumns *) createUserColumnsWithColumns: (NSArray<GPKGUserColumn *> *) columns{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGUserColumns *) createUserColumnsWithNames: (NSArray<NSString *> *) columnNames{
    return [self createUserColumnsWithColumns:[self columnsWithNames:columnNames]];
}

-(GPKGUserColumns *) userColumns{
    return _userColumns;
}

-(int) columnIndexWithColumnName: (NSString *) columnName{
    return [self.userColumns columnIndexWithColumnName:columnName];
}

-(NSArray<NSString *> *) columnNames{
    return [self.userColumns columnNames];
}

-(NSString *) columnNameWithIndex: (int) index{
    return [self.userColumns columnNameWithIndex:index];
}

-(NSArray<GPKGUserColumn *> *) columns{
    return [self.userColumns columns];
}

-(NSArray<GPKGUserColumn *> *) columnsWithNames: (NSArray<NSString *> *) columnNames{
    NSMutableArray<GPKGUserColumn *> *columns = [NSMutableArray array];
    for(NSString *columnName in columnNames){
        [columns addObject:[self columnWithColumnName:columnName]];
    }
    return columns;
}

-(GPKGUserColumn *) columnWithIndex: (int) index{
    return [self.userColumns columnWithIndex:index];
}

-(GPKGUserColumn *) columnWithColumnName: (NSString *) columnName{
    return [self.userColumns columnWithColumnName:columnName];
}

-(BOOL) hasColumnWithColumnName: (NSString *) columnName{
    return [self.userColumns hasColumnWithColumnName:columnName];
}

-(int) columnCount{
    return [self.userColumns columnCount];
}

-(NSString *) tableName{
    return self.userColumns.tableName;
}

-(void) setTableName: (NSString *) tableName{
    [self.userColumns setTableName:tableName];
}

-(BOOL) hasPkColumn{
    return [self.userColumns hasPkColumn];
}

-(int) pkIndex{
    return [self.userColumns pkIndex];
}

-(GPKGUserColumn *) pkColumn{
    return [self.userColumns pkColumn];
}

-(NSString *) pkColumnName{
    return [self.userColumns pkColumnName];
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
    return _constraints;
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
    return [self.userColumns columnsOfType:type];
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
    [self.userColumns addColumn:column];
}

-(void) renameColumn: (GPKGUserColumn *) column toColumn: (NSString *) newColumnName{
    [self.userColumns renameColumn:column toColumn:newColumnName];
}

-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    [self.userColumns renameColumnWithName:columnName toColumn:newColumnName];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [self.userColumns renameColumnWithIndex:index toColumn:newColumnName];
}

-(void) dropColumn: (GPKGUserColumn *) column{
    [self.userColumns dropColumn:column];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [self.userColumns dropColumnWithName:columnName];
}

-(void) dropColumnWithIndex: (int) index{
    [self.userColumns dropColumnWithIndex:index];
}

-(void) alterColumn: (GPKGUserColumn *) column{
    [self.userColumns alterColumn:column];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserTable *userTable = [[[self class] allocWithZone:zone] initWithUserTable:self];
    return userTable;
}

@end
