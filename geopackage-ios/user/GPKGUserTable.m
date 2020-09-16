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
 * Constraints
 */
@property (nonatomic, strong) GPKGConstraints *constraints;

@end

@implementation GPKGUserTable

-(instancetype) initWithColumns: (GPKGUserColumns *) columns{
    self = [super init];
    if(self != nil){
        self.userColumns = columns;
        self.constraints = [[GPKGConstraints alloc] init];
    }
    return self;
}

-(instancetype) initWithUserTable: (GPKGUserTable *) userTable{
    self = [super init];
    if(self != nil){

        self.userColumns = [userTable.userColumns mutableCopy];
        self.constraints = [userTable mutableCopy];
        self.contents = userTable.contents;
        
    }
    return self;
}

-(NSString *) dataType{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString *) dataTypeWithDefault: (NSString *) defaultType{
    NSString *dataType = nil;
    if(_contents != nil){
        dataType = _contents.dataType;
    }
    if(dataType == nil){
        dataType = defaultType;
    }
    return dataType;
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
    return _userColumns.tableName;
}

-(void) setTableName: (NSString *) tableName{
    [self.userColumns setTableName:tableName];
}

-(BOOL) hasIdColumn{
    return [self.userColumns hasIdColumn];
}

-(int) idIndex{
    return [self.userColumns idIndex];
}

-(GPKGUserColumn *) idColumn{
    return [self.userColumns idColumn];
}

-(NSString *) idColumnName{
    return [self.userColumns idColumnName];
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
    [_constraints add:constraint];
}

-(void) addConstraintArray: (NSArray<GPKGConstraint *> *) constraints{
    [_constraints addArray:constraints];
}

-(void) addConstraints: (GPKGConstraints *) constraints{
    [self addConstraintArray:[constraints all]];
}

-(BOOL) hasConstraints{
    return [_constraints has];
}

-(BOOL) hasConstraintsOfType: (enum GPKGConstraintType) type{
    return [_constraints hasType:type];
}

-(GPKGConstraints *) constraints{
    return _constraints;
}

-(NSArray<GPKGConstraint *> *) constraintsOfType: (enum GPKGConstraintType) type{
    return [_constraints ofType:type];
}

-(NSArray<GPKGConstraint *> *) clearConstraints{
    return [_constraints clear];
}

-(NSArray<GPKGConstraint *> *) clearConstraintsOfType: (enum GPKGConstraintType) type{
    return [_constraints clearType:type];
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

-(BOOL) isPkModifiable{
    return _userColumns.pkModifiable;
}

-(void) setPkModifiable: (BOOL) pkModifiable{
    [_userColumns setPkModifiable:pkModifiable];
}

-(BOOL) isValueValidation{
    return _userColumns.valueValidation;
}

-(void) setValueValidation: (BOOL) valueValidation{
    [_userColumns setValueValidation:valueValidation];
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
