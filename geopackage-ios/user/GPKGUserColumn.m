//
//  GPKGUserColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserColumn.h"
#import "GPKGRawConstraint.h"
#import "GPKGSqlUtils.h"

@implementation GPKGUserColumn

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey{
    return [self initWithIndex:index andName:name andType:[GPKGUserColumn nameOfDataType:dataType forColumn:name] andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
}

-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                      andType: (NSString *) type
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey{
    self = [super init];
    if(self != nil){
        _index = index;
        _name = name;
        _max = max;
        _notNull = notNull;
        _defaultValue = defaultValue;
        _primaryKey = primaryKey;
        _type = type;
        _dataType = dataType;
        _constraints = [[NSMutableArray alloc] init];
        
        [GPKGUserColumn validateDataType:dataType forColumn:name];
        [self validateMax];
        
        [self addDefaultConstraints];
    }
    return self;
}

-(instancetype) initWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [self initWithIndex:[tableColumn index] andName:[tableColumn name] andType:[tableColumn type] andDataType:[tableColumn dataType] andMax:[tableColumn max] andNotNull:[tableColumn notNull] andDefaultValue:[tableColumn defaultValue] andPrimaryKey:[tableColumn primaryKey]];
}

/**
 * Copy Initialize
 *
 * @param userColumn
 *            user column
 */
-(instancetype) initWithUserColumn: (GPKGUserColumn *) userColumn{
    self = [super init];
    if(self != nil){
        _index = userColumn.index;
        _name = userColumn.name;
        _max = userColumn.max;
        _notNull = userColumn.notNull;
        _defaultValue = userColumn.defaultValue;
        _primaryKey = userColumn.primaryKey;
        _type = userColumn.type;
        _dataType = userColumn.dataType;
    }
    return self;
}

+(NSString *) nameOfDataType: (enum GPKGDataType) dataType forColumn: (NSString *) name{
    [self validateDataType:dataType forColumn:name];
    return [GPKGDataTypes name:dataType];
}

/**
 * Validate the data type
 *
 * @param name
 *            column name
 *
 * @param dataType
 *            data type
 */
+(void) validateDataType: (enum GPKGDataType) dataType forColumn: (NSString *) name{
    if((int)dataType < 0){
        [NSException raise:@"Data Type Required" format:@"Data Type is required to create column: %@", name];
    }
}

-(BOOL) hasIndex{
    return self.index > NO_INDEX;
}

-(void) setIndex: (int) index{
    if ([self hasIndex]) {
        if (index != _index) {
            [NSException raise:@"Modified Index" format:@"User Column with a valid index may not be changed. Column Name: %@, Index: %d, Attempted Index: %d", _name, _index, index];
        }
    } else {
        _index = index;
    }
}

-(void) resetIndex{
    _index = NO_INDEX;
}

-(BOOL) isNamed: (NSString *) name{
    return [self.name isEqualToString:name];
}

-(BOOL) hasMax{
    return self.max != nil;
}

-(BOOL) hasDefaultValue{
    return self.defaultValue != nil;
}

-(BOOL) hasConstraints{
    return self.constraints != nil && self.constraints.count > 0;
}

-(NSArray<GPKGConstraint *> *) clearConstraints{
    NSArray<GPKGConstraint *> *constraintsCopy = [NSArray arrayWithArray:self.constraints];
    [self.constraints removeAllObjects];
    return constraintsCopy;
}

-(void) addDefaultConstraints{
    if ([self notNull]) {
        [self addNotNullConstraint];
    }
    if ([self hasDefaultValue]) {
        [self addDefaultValueConstraint:self.defaultValue];
    }
    if ([self primaryKey]) {
        [self addPrimaryKeyConstraint];
    }
}

-(void) addConstraint: (GPKGConstraint *) constraint{
    [self.constraints addObject:constraint];
}

-(void) addConstraintSql: (NSString *) constraint{
    [self.constraints addObject:[[GPKGRawConstraint alloc] initWithSql:constraint]];
}

-(void) addConstraints: (NSArray<GPKGConstraint *> *) constraints{
    for (GPKGConstraint *constraint in constraints) {
        [self addConstraint:constraint];
    }
}

-(void) addColumnConstraints: (GPKGColumnConstraints *) constraints{
    [self addConstraints:constraints.constraints];
}

-(void) addNotNullConstraint{
    [self setNotNull:YES];
    [self addConstraintSql:@"NOT NULL"];
}

-(void) addDefaultValueConstraint: (NSObject *) defaultValue{
    [self setDefaultValue:defaultValue];
    [self addConstraintSql:[NSString stringWithFormat:@"DEFAULT %@", [GPKGSqlUtils columnDefaultValue:self]]];
}

-(void) addPrimaryKeyConstraint{
    [self setPrimaryKey:YES];
    [self addConstraintSql:@"PRIMARY KEY AUTOINCREMENT"];
}

-(void) addUniqueConstraint{
    [self addConstraintSql:@"UNIQUE"];
}

-(void) validateMax{
    
    if(self.max != nil){
        if((int)self.dataType < 0){
            [NSException raise:@"Illegal State" format:@"Column max is only supported for data typed columns. column: %@, max: %@", self.name, self.max];
        }else if(self.dataType != GPKG_DT_TEXT && self.dataType != GPKG_DT_BLOB){
            [NSException raise:@"Illegal State" format:@"Column max is only supported for TEXT and BLOB columns. column: %@, max: %@, type: %@", self.name, self.max, [GPKGDataTypes name:self.dataType]];
        }
    }
    
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserColumn *userColumn = [[[self class] allocWithZone:zone] initWithUserColumn:self];
    return userColumn;
}

@end
