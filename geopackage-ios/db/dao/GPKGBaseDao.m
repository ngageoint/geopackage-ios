//
//  GPKGBaseDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGBaseDao.h"
#import "GPKGSqlUtils.h"
#import "GPKGUtils.h"
#import "GPKGAlterTable.h"

@implementation GPKGBaseDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super init];
    if(self != nil){
        self.database = database;
        self.databaseName = database.name;
        self.idColumns = [[NSArray alloc] init];
        self.autoIncrementId = NO;
    }
    return self;
}

-(NSObject *) createObject{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    [self doesNotRecognizeSelector:_cmd];
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) validateObject: (NSObject*) object{
    
}

-(void) setValueInObject: (NSObject*) object withColumnName: (NSString *) column withValue: (NSObject *) value{
    NSNumber *columnIndex = [self.columnIndex valueForKey:column];
    if(columnIndex != nil){
        [self setValueInObject:object withColumnIndex:((NSNumber *)columnIndex).intValue withValue:value];
    }
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnName: (NSString *) column{
    NSObject *value = nil;
    NSNumber *columnIndex = [self.columnIndex valueForKey:column];
    if(columnIndex != nil){
        value = [self valueFromObject:object withColumnIndex:((NSNumber *)columnIndex).intValue];
    }
    return value;
}

-(void) initializeColumnIndex{
    self.columnIndex = [[NSMutableDictionary alloc] init];
    int count = [self columnCount];
    for(int i = 0; i < count; i++){
        [GPKGUtils setObject:[NSNumber numberWithInt:i] forKey:[GPKGUtils objectAtIndex:i inArray:self.columnNames] inDictionary:self.columnIndex];
    }
}

-(int) columnCount{
    return (int)[_columnNames count];
}

-(NSString *) columnNameWithIndex: (int) index{
    return [self.columnNames objectAtIndex:index];
}

-(BOOL) tableExists{
    return [self.database tableExists:self.tableName];
}

-(NSString *) idColumn{
    return [GPKGUtils objectAtIndex:0 inArray:self.idColumns];
}

-(SFPProjection *) projection: (NSObject *) object{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) dropTable{
    [self.database dropTable:self.tableName];
}

-(GPKGResultSet *) queryForId: (NSObject *) idValue{
    return [self queryWithColumns:self.columnNames forId:idValue];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forId: (NSObject *) idValue{
    NSString * whereString = [self buildPkWhereWithValue:idValue];
    NSArray * whereArgs = [self buildPkWhereArgsWithValue:idValue];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(NSObject *) queryForIdObject: (NSObject *) idValue{
    GPKGResultSet *results = [self queryForId:idValue];
    NSObject * objectResult = [self firstObject:results];
    return objectResult;
}

-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues{
    return [self queryWithColumns:self.columnNames forMultiId:idValues];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forMultiId: (NSArray *) idValues{
    NSString * whereString = [self buildPkWhereWithValues:idValues];
    NSArray * whereArgs = [self buildPkWhereArgsWithValues:idValues];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(NSObject *) queryForMultiIdObject: (NSArray *) idValues{
    
    GPKGResultSet *results = [self queryForMultiId:idValues];
    NSObject * objectResult = [self firstObject:results];
    return objectResult;
}

-(GPKGResultSet *) queryForIdInt: (int) id{
    return [self queryWithColumns:self.columnNames forIdInt:id];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forIdInt: (int) id{
    return [self queryWithColumns:columns forId:[NSNumber numberWithInt:id]];
}

-(GPKGResultSet *) queryForAll{
    return [self query];
}

-(GPKGResultSet *) query{
    return [self queryWithColumns:self.columnNames];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns{
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:nil andWhereArgs:nil andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(NSString *) querySQL{
    return [self querySQLWithColumns:self.columnNames];
}

-(NSString *) queryIdsSQL{
    return [self querySQLWithColumns:self.idColumns];
}

-(NSString *) querySQLWithColumns: (NSArray<NSString *> *) columns{
    return [self.database querySQLWithTable:self.tableName andColumns:columns andWhere:nil andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(NSObject *) object: (GPKGResultSet *) results{
    
    NSArray *result = [results row];
    
    NSObject *objectResult = [self createObject];
    
    NSInteger count = [results.columnNames count];
    for(int i = 0; i < count; i++){
        [self setValueInObject:objectResult withColumnName:[GPKGUtils objectAtIndex:i inArray:results.columnNames] withValue:[GPKGUtils objectAtIndex:i inArray:result]];
    }
    
    return objectResult;
}

-(NSObject *) firstObject: (GPKGResultSet *)results{
    NSObject *objectResult = nil;
    @try{
        if([results moveToNext]){
            objectResult = [self object: results];
        }
    }@finally{
        [results close];
    }
    
    return objectResult;
}

-(GPKGResultSet *) rawQuery: (NSString *) query{
    return [self rawQuery:query andArgs:nil];
}

-(GPKGResultSet *) rawQuery: (NSString *) query andArgs: (NSArray *) args{
    GPKGResultSet *results = [self.database rawQuery:query andArgs:args];
    return results;
}

-(NSArray *) singleColumnResults: (GPKGResultSet *) results{
    NSMutableArray *singleColumnResults = [[NSMutableArray alloc] init];
    while([results moveToNext]){
        NSArray *result = [results row];
        [GPKGUtils addObject:[GPKGUtils objectAtIndex:0 inArray:result] toArray:singleColumnResults];
    }
    return singleColumnResults;
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value{
    return [self queryForEqWithColumns:self.columnNames andField:field andValue:value];
}

-(GPKGResultSet *) queryForEqWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andValue: (NSObject *) value{
    return [self queryForEqWithColumns:columns andField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(int) countForEqWithField: (NSString *) field andValue: (NSObject *) value{
    return [self countForEqWithField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    return [self queryForEqWithColumns:self.columnNames andField:field andValue:value andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryForEqWithColumns: (NSArray<NSString *> *) columns
                            andField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereWithField:field andValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
    return results;
}

-(int) countForEqWithField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereWithField:field andValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithValue:value];
    return [self countWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    return [self queryForEqWithColumns:self.columnNames andField:field andColumnValue:value];
}

-(GPKGResultSet *) queryForEqWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereWithField:field andColumnValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(int) countForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereWithField:field andColumnValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValue:value];
    return [self countWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryForLikeWithField: (NSString *) field andValue: (NSObject *) value{
    return [self queryForLikeWithColumns:self.columnNames andField:field andValue:value];
}

-(GPKGResultSet *) queryForLikeWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andValue: (NSObject *) value{
    return [self queryForLikeWithColumns:columns andField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(int) countForLikeWithField: (NSString *) field andValue: (NSObject *) value{
    return [self countForLikeWithField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryForLikeWithField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    return [self queryForLikeWithColumns:self.columnNames andField:field andValue:value andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryForLikeWithColumns: (NSArray<NSString *> *) columns
                            andField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereLikeWithField:field andValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
    return results;
}

-(int) countForLikeWithField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereLikeWithField:field andValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithValue:value];
    return [self countWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryForLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    return [self queryForLikeWithColumns:self.columnNames andField:field andColumnValue:value];
}

-(GPKGResultSet *) queryForLikeWithColumns: (NSArray<NSString *> *) columns andField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereLikeWithField:field andColumnValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(int) countForLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereLikeWithField:field andColumnValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValue:value];
    return [self countWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryForFieldValues:(GPKGColumnValues *) fieldValues{
    return [self queryWithColumns:self.columnNames forFieldValues:fieldValues];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithValues:fieldValues];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(int) countForFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithValues:fieldValues];
    return [self countWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryForColumnValueFieldValues:(GPKGColumnValues *) fieldValues{
    return [self queryWithColumns:self.columnNames forColumnValueFieldValues:fieldValues];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns forColumnValueFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithColumnValueFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValues:fieldValues];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:columns andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(int) countForColumnValueFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithColumnValueFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValues:fieldValues];
    return [self countWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL{
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nil andWhere:nil andWhereArgs:nil];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL{
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nil andWhere:nil andWhereArgs:nil];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andNestedArgs:nestedArgs];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs{
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:nil andWhereArgs:nil];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs{
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:nil andWhereArgs:nil];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nil andFieldValues:fieldValues];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nil andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andNestedArgs:nestedArgs andFieldValues:fieldValues];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithValues:fieldValues];
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:whereString andWhereArgs:whereArgs];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithValues:fieldValues];
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:whereString andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:where];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where{
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:where andWhereArgs:nil];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where{
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andWhere:where];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where{
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nil andWhere:where andWhereArgs:nil];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where{
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nil andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryInWithColumns:columns andNestedSQL:nestedSQL andNestedArgs:nil andWhere:where andWhereArgs:whereArgs];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self countInWithNestedSQL:nestedSQL andNestedArgs:nil andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryInWithColumns:self.columnNames andNestedSQL:nestedSQL andNestedArgs:nestedArgs andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryInWithColumns: (NSArray<NSString *> *) columns andNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    NSString *whereString = [self buildWhereInWithNestedSQL:nestedSQL andWhere:where];
    NSArray *args = [self buildWhereInArgsWithNestedArgs:nestedArgs andWhereArgs:whereArgs];
    return [self queryWithColumns:columns andWhere:whereString andWhereArgs:args];
}

-(int) countInWithNestedSQL: (NSString *) nestedSQL andNestedArgs: (NSArray<NSString *> *) nestedArgs andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    NSString *whereString = [self buildWhereInWithNestedSQL:nestedSQL andWhere:where];
    NSArray *args = [self buildWhereInArgsWithNestedArgs:nestedArgs andWhereArgs:whereArgs];
    return [self countWhere:whereString andWhereArgs:args];
}

-(GPKGResultSet *) queryWhere: (NSString *) where{
    return [self queryWithColumns:self.columnNames andWhere:where];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self queryWithColumns:columns andWhere:where andWhereArgs:nil];
}

-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self queryWithColumns:self.columnNames andWhere:where andWhereArgs:whereArgs];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
        return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(NSString *) querySQLWhere: (NSString *) where{
    return [self querySQLWithColumns:self.columnNames andWhere:where];
}

-(NSString *) queryIdsSQLWhere: (NSString *) where{
    return [self querySQLWithColumns:[NSArray arrayWithObject:[self idColumn]] andWhere:where];
}

-(NSString *) queryMultiIdsSQLWhere: (NSString *) where{
    return [self querySQLWithColumns:self.idColumns andWhere:where];
}

-(NSString *) querySQLWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where{
    return [self.database querySQLWithTable:self.tableName andColumns:columns andWhere:where andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy{
    return [self queryWithColumns:self.columnNames andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit{
    return [self queryWithColumns:self.columnNames andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryWithColumns: (NSArray<NSString *> *) columns
                            andWhere: (NSString *) where
                            andWhereArgs: (NSArray *) whereArgs
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy
                            andLimit: (NSString *) limit{
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:self.columnNames andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andWhere:nil andWhereArgs:nil andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:self.columnNames andWhere:where andWhereArgs:whereArgs andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andWhere:where andWhereArgs:whereArgs andOrderBy:[self idColumn] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:self.columnNames andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andWhere:nil andWhereArgs:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:self.columnNames andWhere:where andWhereArgs:whereArgs andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithColumns:self.columnNames andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithColumns: (NSArray<NSString *> *) columns andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs andGroupBy: (NSString *) groupBy andHaving: (NSString *) having andOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryWithColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:[self buildLimitWithLimit:limit andOffset:offset]];
}

-(NSString *) buildLimitWithLimit: (int) limit andOffset: (int) offset{
    return [NSString stringWithFormat:@"%d,%d", offset, limit];
}

-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy{
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy
                    andLimit: (NSString *) limit{
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs:whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(BOOL) idExists: (NSObject *) id{
    return [self queryForIdObject:id] != nil;
}

-(BOOL) multiIdExists: (NSArray *) idValues{
    return [self queryForMultiIdObject:idValues] != nil;
}

-(NSObject *) queryForSameId: (NSObject *) object{
    
    NSObject * sameIdObject = nil;
    if(object != nil){
        NSArray * idValues = [self multiId:object];
        sameIdObject = [self queryForMultiIdObject:idValues];
    }
    return sameIdObject;
}

-(void) beginTransaction{
    [self.database beginTransaction];
}

-(void) commitTransaction{
    [self.database commitTransaction];
}

-(void) rollbackTransaction{
    [self.database rollbackTransaction];
}

-(BOOL) inTransaction{
    return [self.database inTransaction];
}

-(int) update: (NSObject *) object{
    [self validateObject:object];
    
    GPKGContentValues *values = [[GPKGContentValues alloc] init];
    for(NSString * column in self.columnNames){
        if(![self.idColumns containsObject:column]){
            NSObject * value = [self valueFromObject:object withColumnName:column];
            [values putKey:column withValue:value];
        }
    }
    NSArray* multiId = [self multiId:object];
    NSString *where = [self buildPkWhereWithValues:multiId];
    NSArray *whereArgs = [self buildPkWhereArgsWithValues:multiId];
    int count = [self updateWithValues:values andWhere:where andWhereArgs:whereArgs];
    return count;
}

-(int) updateWithValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = [self.database updateWithTable:self.tableName andValues:values andWhere:where andWhereArgs:whereArgs];
    return count;
}

-(int) delete: (NSObject *) object{
    int numDeleted;
    if([self hasId]){
        numDeleted = [self deleteByMultiId:[self multiId:object]];
    }else{
        GPKGColumnValues *values = [self values: object];
        numDeleted = [self deleteWhere:[self buildWhereWithFields:values] andWhereArgs:[self buildWhereArgsWithValues:values]];
    }
    return numDeleted;
}

-(int) deleteObjects: (NSArray *) objects{
    int count = 0;
    for(NSObject *object in objects){
        count += [self delete:object];
    }
    return count;
}

-(int) deleteById: (NSObject *) idValue{
    return [self.database deleteWithTable:self.tableName andWhere:[self buildPkWhereWithValue:idValue] andWhereArgs:[self buildPkWhereArgsWithValue:idValue]];
}

-(int) deleteByMultiId: (NSArray *) idValues{
    return [self.database deleteWithTable:self.tableName andWhere:[self buildPkWhereWithValues:idValues] andWhereArgs:[self buildPkWhereArgsWithValues:idValues]];
}

-(int) deleteWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.database deleteWithTable:self.tableName andWhere:where andWhereArgs:whereArgs];
}

-(int) deleteByFieldValues: (GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithValues:fieldValues];
    return [self deleteWhere:whereString andWhereArgs:whereArgs];
}

-(int) deleteAll{
    return[self.database deleteWithTable:self.tableName andWhere:nil];
}

-(long long) create: (NSObject *) object{
    return [self insert:object];
}

-(long long) insert: (NSObject *) object{
    [self validateObject:object];
    
    GPKGContentValues *values = [[GPKGContentValues alloc]init];
    for(NSString * column in self.columnNames){
        if(!self.autoIncrementId || ![self.idColumns containsObject:column]){
            NSObject * value = [self valueFromObject:object withColumnName:column];
            if(value != nil){
                [values putKey:column withValue:value];
            }
        }
    }
    if([values size] == 0){
        for(NSString * column in self.columnNames){
            [values putKey:column withValue:[NSNull null]];
        }
    }
    long long id = [self.database insertWithTable:self.tableName andValues:values];
    return id;
}

-(long long) createIfNotExists: (NSObject *) object{
    
    NSObject * existingObject = [self queryForSameId:object];
    
    long long id = -1;
    
    if(existingObject == nil){
        id = [self create:object];
    }
    
    return id;
}

-(long long) createOrUpdate: (NSObject *) object{
    
     NSObject * existingObject = [self queryForSameId:object];
    
    long long id = -1;
    
    if(existingObject == nil){
        id = [self create:object];
    } else{
        [self update:object];
    }
    
    return id;
}

-(BOOL) hasId{
    return self.idColumns.count > 0;
}

-(NSObject *) id: (NSObject *) object{
    return [self valueFromObject:object withColumnName:[self idColumn]];
}

-(NSArray *) multiId: (NSObject *) object{
    NSMutableArray *idValues = [[NSMutableArray alloc] init];
    for(NSString *idColumn in self.idColumns){
        NSObject* idValue = [self valueFromObject:object withColumnName:idColumn];
        [GPKGUtils addObject:idValue toArray:idValues];
    }
    return idValues;
}

-(void) setId: (NSObject *) object withIdValue: (NSObject *) id{
    [self setValueInObject:object withColumnName:[self idColumn] withValue:id];
}

-(void) setMultiId: (NSObject *) object withIdValues: (NSArray *) idValues{
    for(int i = 0; i < [idValues count]; i++){
        [self setValueInObject:object withColumnName:[GPKGUtils objectAtIndex:i inArray:self.idColumns] withValue:[GPKGUtils objectAtIndex:i inArray:idValues]];
    }
}

-(GPKGColumnValues *) values: (NSObject *) object{
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    for(NSString * column in self.columnNames){
        NSObject * value = [self valueFromObject:object withColumnName:column];
        [values addColumn:column withValue:value];
    }
    return values;
}

-(NSString *) buildPkWhereWithValue: (NSObject *) idValue{
    return [self buildWhereWithField:[self idColumn] andValue:idValue];
}

-(NSArray *) buildPkWhereArgsWithValue: (NSObject *) idValue{
    return [self buildWhereArgsWithValue:idValue];
}

-(NSString *) buildPkWhereWithValues: (NSArray *) idValues{
    GPKGColumnValues *idColumnValues = [[GPKGColumnValues alloc] init];
    for(int i = 0; i < [idValues count]; i++){
        [idColumnValues addColumn:[GPKGUtils objectAtIndex:i inArray:self.idColumns] withValue:[GPKGUtils objectAtIndex:i inArray:idValues]];
    }
    NSString * whereString = [self buildWhereWithFields:idColumnValues];
    return whereString;
}

-(NSArray *) buildPkWhereArgsWithValues: (NSArray *) idValues{
    NSMutableArray * values = [[NSMutableArray alloc] init];
    for(int i = 0; i < [idValues count]; i++){
        NSObject *value = [GPKGUtils objectAtIndex:i inArray:idValues];
        if(value != nil){
            [values addObjectsFromArray:[self buildWhereArgsWithValue:value]];
        }
    }
    return values;
}

-(NSString *) buildWhereWithFields: (GPKGColumnValues *) fields{
    return [self buildWhereWithFields:fields andOperation:@"and"];
}

-(NSString *) buildWhereWithFields: (GPKGColumnValues *) fields andOperation: (NSString *) operation{
    NSMutableString *whereString = [NSMutableString string];
    for(NSString * column in fields.columns){
        if([whereString length] > 0){
            [whereString appendFormat:@" %@ ", operation];
        }
        [whereString appendString:[self buildWhereWithField:column andValue:[fields value:column]]];
    }
    return whereString;
}

-(NSString *) buildWhereWithColumnValueFields: (GPKGColumnValues *) fields{
    return [self buildWhereWithColumnValueFields:fields andOperation:@"and"];
}

-(NSString *) buildWhereWithColumnValueFields: (GPKGColumnValues *) fields andOperation: (NSString *) operation{
    NSMutableString *whereString = [NSMutableString string];
    for(NSString * column in fields.columns){
        if([whereString length] > 0){
            [whereString appendFormat:@" %@ ", operation];
        }
        [whereString appendString:[self buildWhereWithField:column andColumnValue:(GPKGColumnValue *)[fields value:column]]];
    }
    return whereString;
}

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value{
    return [self buildWhereWithField:field andValue:value andOperation:@"="];
}

-(NSString *) buildWhereLikeWithField: (NSString *) field andValue: (NSObject *) value{
    return [self buildWhereWithField:field andValue:value andOperation:@"LIKE"];
}

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation{
    NSMutableString *whereString = [NSMutableString string];
    [whereString appendFormat:@"%@ ", [GPKGSqlUtils quoteWrapName:field]];
    if(value == nil){
        [whereString appendString:@"is null"];
    }else{
        [whereString appendFormat:@"%@ ?", operation];
    }
    return whereString;
}

-(NSString *) buildWhereWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    
    NSMutableString *whereString = [NSMutableString string];
    
    if(value != nil){
        if(value.value != nil && value.tolerance != nil){
            [whereString appendFormat:@"%@ >= ? and %@ <= ?", [GPKGSqlUtils quoteWrapName:field], [GPKGSqlUtils quoteWrapName:field]];
        }else{
            [whereString appendString:[self buildWhereWithField:field andValue:value.value]];
        }
    }else{
        [whereString appendString:[self buildWhereWithField:field andValue:nil andOperation:nil]];
    }
    
    return whereString;
}

-(NSString *) buildWhereLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    
    NSMutableString *whereString = [NSMutableString string];
    
    if(value != nil){
        if(value.tolerance != nil){
            [NSException raise:@"LIKE Tolerance" format:@"Field value tolerance not supported for LIKE query, Field: %@, Value: %@", field, value.tolerance];
        }
        [whereString appendString:[self buildWhereLikeWithField:field andValue:value.value]];
    }else{
        [whereString appendString:[self buildWhereWithField:field andValue:nil andOperation:nil]];
    }
    
    return whereString;
}

-(NSArray *) buildWhereArgsWithValues: (GPKGColumnValues *) values{
    NSMutableArray * args = [[NSMutableArray alloc] init];
    for(NSString * column in values.columns){
        NSObject * value = [values value:column];
        if(value != nil){
            [GPKGUtils addObject:value toArray:args];
        }
    }
    return [args count] == 0 ? nil : args;
}

-(NSArray *) buildWhereArgsWithValueArray: (NSArray *) values{
    NSMutableArray * args = [[NSMutableArray alloc] init];
    for(NSObject * value in values){
        if(value != nil){
            [GPKGUtils addObject:value toArray:args];
        }
    }
    return [args count] == 0 ? nil : args;
}

-(NSArray *) buildWhereArgsWithColumnValues: (GPKGColumnValues *) values{
    NSMutableArray * args = [[NSMutableArray alloc] init];
    for(NSString * column in values.columns){
        GPKGColumnValue * value = (GPKGColumnValue *)[values value:column];
        if(value != nil && value.value != nil){
            if(value.tolerance != nil){
                [args addObjectsFromArray:[self valueToleranceRange:value]];
            }else{
                [GPKGUtils addObject:value.value toArray:args];
            }
        }
    }
    return [args count] == 0 ? nil : args;
}

-(NSArray *) buildWhereArgsWithValue: (NSObject *) value{
    NSMutableArray * args = nil;
    if(value != nil){
        args = [[NSMutableArray alloc] init];
        [GPKGUtils addObject:value toArray:args];
    }
    return args;
}

-(NSArray *) buildWhereArgsWithColumnValue: (GPKGColumnValue *) value{
    NSArray * args = nil;
    if(value != nil){
        if(value.value != nil && value.tolerance != nil){
            args = [self valueToleranceRange:value];
        }else{
            args = [self buildWhereArgsWithValue:value.value];
        }
    }
    return args;
}

-(NSString *) buildWhereInWithNestedSQL: (NSString *) nestedSQL andWhere: (NSString *) where{
    
    NSString *nestedWhere = [NSString stringWithFormat:@"%@ IN (%@)", [GPKGSqlUtils quoteWrapName:[self idColumn]], nestedSQL];
    
    NSString *whereClause = nil;
    if(where == nil){
        whereClause = nestedWhere;
    }else{
        whereClause = [NSString stringWithFormat:@"(%@) AND (%@)", where, nestedWhere];
    }

    return whereClause;
}

-(NSArray<NSString *> *) buildWhereInArgsWithNestedArgs: (NSArray<NSString *> *) nestedArgs andWhereArgs: (NSArray<NSString *> *) whereArgs{
    
    NSArray *args = nil;

    if(whereArgs != nil || nestedArgs != nil){
        if(whereArgs == nil){
            args = [NSArray arrayWithArray:nestedArgs];
        }else if(nestedArgs == nil){
            args = [NSArray arrayWithArray:whereArgs];
        }else{
            args = [whereArgs arrayByAddingObjectsFromArray:nestedArgs];
        }
    }

    return args;
}

-(int) count{
    return [self countWhere:nil andWhereArgs:nil];
}

-(int) countWhere: (NSString *) where{
    return [self countWhere:where andWhereArgs:nil];
}

-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) args{
    return [self.database countWithTable:self.tableName andWhere:where andWhereArgs:args];
}

-(NSNumber *) minOfColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) args{
    return [self.database minWithTable:self.tableName andColumn:column andWhere:where andWhereArgs:args];
}

-(NSNumber *) maxOfColumn: (NSString *) column andWhere: (NSString *) where andWhereArgs: (NSArray *) args{
    return [self.database maxWithTable:self.tableName andColumn:column andWhere:where andWhereArgs:args];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self.database querySingleResultWithSql:sql andArgs:args];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andDataType: (enum GPKGDataType) dataType{
    return [self.database querySingleResultWithSql:sql andArgs:args andDataType:dataType];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column{
    return [self.database querySingleResultWithSql:sql andArgs:args andColumn:column];
}

-(NSObject *) querySingleResultWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType{
    return [self.database querySingleResultWithSql:sql andArgs:args andColumn:column andDataType:dataType];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self.database querySingleColumnResultsWithSql:sql andArgs:args];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataType: (enum GPKGDataType) dataType{
    return [self.database querySingleColumnResultsWithSql:sql andArgs:args andDataType:dataType];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column{
    return [self.database querySingleColumnResultsWithSql:sql andArgs:args andColumn:column];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType{
    return [self.database querySingleColumnResultsWithSql:sql andArgs:args andColumn:column andDataType:dataType];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andLimit: (NSNumber *) limit{
    return [self.database querySingleColumnResultsWithSql:sql andArgs:args andColumn:column andLimit:limit];
}

-(NSArray<NSObject *> *) querySingleColumnResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andColumn: (int) column andDataType: (enum GPKGDataType) dataType andLimit: (NSNumber *) limit{
    return [self.database querySingleColumnResultsWithSql:sql andArgs:args andColumn:column andDataType:dataType andLimit:limit];
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self.database queryResultsWithSql:sql andArgs:args];
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes{
    return [self.database queryResultsWithSql:sql andArgs:args andDataTypes:dataTypes];
}

-(NSArray<NSObject *> *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args{
    return [self.database querySingleRowResultsWithSql:sql andArgs:args];
}

-(NSArray<NSObject *> *) querySingleRowResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes{
    return [self.database querySingleRowResultsWithSql:sql andArgs:args andDataTypes:dataTypes];
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andLimit: (NSNumber *) limit{
    return [self.database queryResultsWithSql:sql andArgs:args andLimit:limit];
}

-(NSArray<NSArray<NSObject *> *> *) queryResultsWithSql: (NSString *) sql andArgs: (NSArray *) args andDataTypes: (NSArray *) dataTypes andLimit: (NSNumber *) limit{
    return [self.database queryResultsWithSql:sql andArgs:args andDataTypes:dataTypes andLimit:limit];
}

-(NSArray *) valueToleranceRange: (GPKGColumnValue *) value{
    double doubleValue = [(NSNumber *)value.value doubleValue];
    double tolerance = [value.tolerance doubleValue];
    return [NSArray arrayWithObjects:[[NSDecimalNumber alloc]initWithDouble:doubleValue - tolerance], [[NSDecimalNumber alloc]initWithDouble:doubleValue + tolerance], nil];
}

-(void) renameColumnWithName: (NSString *) columnName toColumn: (NSString *) newColumnName{
    [GPKGAlterTable renameColumn:columnName inTable:self.tableName toColumn:newColumnName withConnection:self.database];
}

-(void) renameColumnWithIndex: (int) index toColumn: (NSString *) newColumnName{
    [self renameColumnWithName:[self columnNameWithIndex:index] toColumn:newColumnName];
}

-(void) dropColumnWithIndex: (int) index{
    [self dropColumnWithName:[self columnNameWithIndex:index]];
}

-(void) dropColumnWithName: (NSString *) columnName{
    [GPKGAlterTable dropColumn:columnName fromTableName:self.tableName withConnection:self.database];
}

-(void) dropColumnIndexes: (NSArray<NSNumber *> *) indexes{
    NSMutableArray<NSString *> *columnNames = [[NSMutableArray alloc] init];
    for(NSNumber *index in indexes){
        [columnNames addObject:[self columnNameWithIndex:[index intValue]]];
    }
    [self dropColumnNames:columnNames];
}

-(void) dropColumnNames: (NSArray<NSString *> *) columnNames{
    [GPKGAlterTable dropColumns:columnNames fromTableName:self.tableName withConnection:self.database];
}

@end
