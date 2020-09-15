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
@property (nonatomic, strong) GPKGUserColumns *columns;

/**
 * Constraints
 */
@property (nonatomic, strong) GPKGConstraints *contraints;

@end

@implementation GPKGUserTable

-(instancetype) initWithColumns: (GPKGUserColumns *) columns{
    self = [super init];
    if(self != nil){
        self.columns = columns;
        self.constraints = [[GPKGConstraints alloc] init];
    }
    return self;
}

-(instancetype) initWithUserTable: (GPKGUserTable *) userTable{
    self = [super init];
    if(self != nil){

        self.columns = [userTable.columns mutableCopy];
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
    return _columns;
}

-(int) columnIndexWithColumnName: (NSString *) columnName{
    return [self.columns columnIndexWithColumnName:columnName];
}

-(NSArray<NSString *> *) columnNames{
    return [self.columns columnNames];
}

-(NSString *) columnNameWithIndex: (int) index{
    return [self.columns columnNameWithIndex:index];
}

-(NSArray<GPKGUserColumn *> *) columns{
    return [self.columns columns];
}

-(NSArray<GPKGUserColumn *> *) columnsWithNames: (NSArray<NSString *> *) columnNames{
    NSMutableArray<GPKGUserColumn *> *columns = [NSMutableArray array];
    for(NSString *columnName in columnNames){
        [columns addObject:[self columnWithColumnName:columnName]];
    }
    return columns;
}

-(GPKGUserColumn *) columnWithIndex: (int) index{
    return [self.columns columnWithIndex:index];
}

-(GPKGUserColumn *) columnWithColumnName: (NSString *) columnName{
    return [self.columns columnWithColumnName:columnName];
}

-(BOOL) hasColumnWithColumnName: (NSString *) columnName{
    return [self.columns hasColumnWithColumnName:columnName];
}

-(int) columnCount{
    return [self.columns columnCount];
}

-(NSString *) tableName{
    return _columns.tableName;
}

-(void) setTableName: (NSString *) tableName{
    [self.columns setTableName:tableName];
}

-(BOOL) hasIdColumn{
    return [self.columns hasIdColumn];
}

-(int) idIndex{
    return [self.columns idIndex];
}

-(GPKGUserColumn *) idColumn{
    return [self.columns idColumn];
}

-(NSString *) idColumnName{
    return [self.columns idColumnName];
}

-(BOOL) hasPkColumn{
    return [self.columns hasPkColumn];
}

-(int) pkIndex{
    return [self.columns pkIndex];
}

-(GPKGUserColumn *) pkColumn{
    return [self.columns pkColumn];
}

-(NSString *) pkColumnName{
    return [self.columns pkColumnName];
}

-(void) addConstraint: (GPKGConstraint *) constraint{
    [_contraints add:constraint];
}

-(void) addConstraintArray: (NSArray<GPKGConstraint *> *) constraints{
    [_contraints addArray:constraints];
}

-(void) addConstraints: (GPKGConstraints *) constraints{
    [self addConstraintArray:[constraints all]];
}

-(BOOL) hasConstraints{
    return [_contraints has];
}

-(BOOL) hasConstraintsOfType: (enum GPKGConstraintType) type{
    return [_contraints hasType:type];
}

-(GPKGConstraints *) constraints{
    return _constraints;
}

-(NSArray<GPKGConstraint *> *) constraintsOfType: (enum GPKGConstraintType) type{
    return [_constraints getType:type];
}

-(NSArray<GPKGConstraint *> *) clearConstraints{
    return [_constraints clear];
}

-(NSArray<GPKGConstraint *> *) clearConstraintsOfType: (enum GPKGConstraintType) type{
    return [_constraints clearType:type];
}

-(NSArray *) columnsOfType: (enum GPKGDataType) type{
    return [self.columns columnsOfType:type];
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
    return _columns.pkModifiable;
}

-(void) setPkModifiable: (BOOL) pkModifiable{
    [_columns setPkModifiable:pkModifiable];
}

-(BOOL) isValueValidation{
    return _columns.valueValidation;
}

-(void) setValueValidation: (BOOL) valueValidation{
    [_columns setValueValidation:valueValidation];
}

-(void) addColumn: (GPKGUserColumn *) column{
    [self.columns addColumn:column];
}

-(void) renameColumn: (GPKGUserColumn *) column toColumn: (NSString *) newColumnName{
    [self.columns renameColumn:column toColumn:newColumnName];
}

-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    [self.columns renameColumnWithName:columnName toColumn:newColumnName];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [self.columns renameColumnWithIndex:index toColumn:newColumnName];
}

-(void) dropColumn: (GPKGUserColumn *) column{
    [self.columns dropColumn:column];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [self.columns dropColumnWithName:columnName];
}

-(void) dropColumnWithIndex: (int) index{
    [self.columns dropColumnWithIndex:index];
}

-(void) alterColumn: (GPKGUserColumn *) column{
    [self.columns alterColumn:column];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserTable *userTable = [[[self class] allocWithZone:zone] initWithUserTable:self];
    return userTable;
}

@end
