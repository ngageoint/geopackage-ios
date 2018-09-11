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

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) validateObject: (NSObject*) object{
    
}

-(void) setValueInObject: (NSObject*) object withColumnName: (NSString *) column withValue: (NSObject *) value{
    int columnIndex = ((NSNumber*) [self.columnIndex valueForKey:column]).intValue;
    [self setValueInObject:object withColumnIndex:columnIndex withValue:value];
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnName: (NSString *) column{
    int columnIndex = ((NSNumber*) [self.columnIndex valueForKey:column]).intValue;
    return [self getValueFromObject:object withColumnIndex:columnIndex];
}

-(void) initializeColumnIndex{
    self.columnIndex = [[NSMutableDictionary alloc] init];
    NSInteger count = [self.columns count];
    for(int i = 0; i < count; i++){
        [GPKGUtils setObject:[NSNumber numberWithInt:i] forKey:[GPKGUtils objectAtIndex:i inArray:self.columns] inDictionary:self.columnIndex];
    }
}

-(BOOL) tableExists{
    return [self.database tableExists:self.tableName];
}

-(SFPProjection *) getProjection: (NSObject *) object{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(void) dropTable{
    [self.database dropTable:self.tableName];
}

-(GPKGResultSet *) queryForId: (NSObject *) idValue{
    
    NSString * whereString = [self buildPkWhereWithValue:idValue];
    NSArray * whereArgs = [self buildPkWhereArgsWithValue:idValue];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs: whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(NSObject *) queryForIdObject: (NSObject *) idValue{
    
    GPKGResultSet *results = [self queryForId:idValue];
    NSObject * objectResult = [self getFirstObject:results];
    return objectResult;
}

-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues{
    
    NSString * whereString = [self buildPkWhereWithValues:idValues];
    NSArray * whereArgs = [self buildPkWhereArgsWithValues:idValues];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs: whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(NSObject *) queryForMultiIdObject: (NSArray *) idValues{
    
    GPKGResultSet *results = [self queryForMultiId:idValues];
    NSObject * objectResult = [self getFirstObject:results];
    return objectResult;
}

-(GPKGResultSet *) queryForAll{
    return [self.database queryWithTable:self.tableName andColumns:nil andWhere:nil andWhereArgs:nil andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(NSObject *) getObject: (GPKGResultSet *) results{
    
    NSArray *result = [results getRow];
    
    NSObject *objectResult = [self createObject];
    
    NSInteger count = [results.columns count];
    for(int i = 0; i < count; i++){
        [self setValueInObject:objectResult withColumnName:[GPKGUtils objectAtIndex:i inArray:results.columns] withValue:[GPKGUtils objectAtIndex:i inArray:result]];
    }
    
    return objectResult;
}

-(NSObject *) getFirstObject: (GPKGResultSet *)results{
    NSObject *objectResult = nil;
    @try{
        if([results moveToNext]){
            objectResult = [self getObject: results];
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
        NSArray *result = [results getRow];
        [GPKGUtils addObject:[GPKGUtils objectAtIndex:0 inArray:result] toArray:singleColumnResults];
    }
    return singleColumnResults;
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value{
    return [self queryForEqWithField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field
                            andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                            andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereWithField:field andValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs: whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
    return results;
}

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereWithField:field andColumnValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryForLikeWithField: (NSString *) field andValue: (NSObject *) value{
    return [self queryForLikeWithField:field andValue:value andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryForLikeWithField: (NSString *) field
                              andValue: (NSObject *) value
                            andGroupBy: (NSString *) groupBy
                             andHaving: (NSString *) having
                            andOrderBy: (NSString *) orderBy{
    NSString *whereString = [self buildWhereLikeWithField:field andValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs: whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
    return results;
}

-(GPKGResultSet *) queryForLikeWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value{
    NSString *whereString = [self buildWhereLikeWithField:field andColumnValue:value];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValue:value];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs:whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryForFieldValues:(GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithValues:fieldValues];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs: whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryForColumnValueFieldValues:(GPKGColumnValues *) fieldValues{
    NSString *whereString = [self buildWhereWithColumnValueFields:fieldValues];
    NSArray *whereArgs = [self buildWhereArgsWithColumnValues:fieldValues];
    GPKGResultSet *results = [self.database queryWithTable:self.tableName andColumns:nil andWhere:whereString andWhereArgs: whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
    return results;
}

-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    return [self.database queryWithTable:self.tableName andColumns:nil andWhere:where andWhereArgs: whereArgs andGroupBy:nil andHaving:nil andOrderBy:nil];
}

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy{
    return [self.database queryWithTable:self.tableName andColumns:nil andWhere:where andWhereArgs: whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit{
    return [self.database queryWithTable:self.tableName andColumns:nil andWhere:where andWhereArgs: whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
}

-(GPKGResultSet *) queryForChunkWithLimit: (int) limit andOffset: (int) offset{
    return [self queryForChunkWithOrderBy:[GPKGUtils objectAtIndex:0 inArray:self.idColumns] andLimit:limit andOffset:offset];
}

-(GPKGResultSet *) queryForChunkWithOrderBy: (NSString *) orderBy andLimit: (int) limit andOffset: (int) offset{
    return [self queryWhere:nil andWhereArgs:nil andGroupBy:nil andHaving:nil andOrderBy:orderBy andLimit:[self buildLimitWithLimit:limit andOffset:offset]];
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
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs: whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy];
}

-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy
                    andLimit: (NSString *) limit{
    return [self.database queryWithTable:self.tableName andColumns:columns andWhere:where andWhereArgs: whereArgs andGroupBy:groupBy andHaving:having andOrderBy:orderBy andLimit:limit];
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
        NSArray * idValues = [self getMultiId:object];
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

-(int) update: (NSObject *) object{
    [self validateObject:object];
    
    GPKGContentValues *values = [[GPKGContentValues alloc] init];
    for(NSString * column in self.columns){
        if(![self.idColumns containsObject:column]){
            NSObject * value = [self getValueFromObject:object withColumnName:column];
            [values putKey:column withValue:value];
        }
    }
    NSArray* multiId = [self getMultiId:object];
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
        numDeleted = [self deleteByMultiId:[self getMultiId:object]];
    }else{
        GPKGColumnValues *values = [self values: object];
        numDeleted = [self deleteWhere:[self buildWhereWithFields:values] andWhereArgs:[self buildWhereArgsWithValues:values]];
    }
    return numDeleted;
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
    for(NSString * column in self.columns){
        if(!self.autoIncrementId || ![self.idColumns containsObject:column]){
            NSObject * value = [self getValueFromObject:object withColumnName:column];
            if(value != nil){
                [values putKey:column withValue:value];
            }
        }
    }
    if([values size] == 0){
        for(NSString * column in self.columns){
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

-(NSObject *) getId: (NSObject *) object{
    return [self getValueFromObject:object withColumnName:[GPKGUtils objectAtIndex:0 inArray:self.idColumns]];
}

-(NSArray *) getMultiId: (NSObject *) object{
    NSMutableArray *idValues = [[NSMutableArray alloc] init];
    for(NSString *idColumn in self.idColumns){
        NSObject* idValue = [self getValueFromObject:object withColumnName:idColumn];
        [GPKGUtils addObject:idValue toArray:idValues];
    }
    return idValues;
}

-(void) setId: (NSObject *) object withIdValue: (NSObject *) id{
    [self setValueInObject:object withColumnName:[GPKGUtils objectAtIndex:0 inArray:self.idColumns] withValue:id];
}

-(void) setMultiId: (NSObject *) object withIdValues: (NSArray *) idValues{
    for(int i = 0; i < [idValues count]; i++){
        [self setValueInObject:object withColumnName:[GPKGUtils objectAtIndex:i inArray:self.idColumns] withValue:[GPKGUtils objectAtIndex:i inArray:idValues]];
    }
}

-(GPKGColumnValues *) values: (NSObject *) object{
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    for(NSString * column in self.columns){
        NSObject * value = [self getValueFromObject:object withColumnName:column];
        [values addColumn:column withValue:value];
    }
    return values;
}

-(NSString *) buildPkWhereWithValue: (NSObject *) idValue{
    return [self buildWhereWithField:[GPKGUtils objectAtIndex:0 inArray:self.idColumns] andValue:idValue];
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
    for(NSObject * value in idValues){
        [values addObjectsFromArray:[self buildWhereArgsWithValue:value]];
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
        [whereString appendString:[self buildWhereWithField:column andValue:[fields getValue:column]]];
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
        [whereString appendString:[self buildWhereWithField:column andColumnValue:(GPKGColumnValue *)[fields getValue:column]]];
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
        NSObject * value = [values getValue:column];
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
        GPKGColumnValue * value = (GPKGColumnValue *)[values getValue:column];
        if(value != nil && value.value != nil){
            if(value.tolerance != nil){
                [args addObjectsFromArray:[self getValueToleranceRange:value]];
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
            args = [self getValueToleranceRange:value];
        }else{
            args = [self buildWhereArgsWithValue:value.value];
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

-(NSArray *) getValueToleranceRange: (GPKGColumnValue *) value{
    double doubleValue = [(NSNumber *)value.value doubleValue];
    double tolerance = [value.tolerance doubleValue];
    return [NSArray arrayWithObjects:[[NSDecimalNumber alloc]initWithDouble:doubleValue - tolerance], [[NSDecimalNumber alloc]initWithDouble:doubleValue + tolerance], nil];
}

@end
