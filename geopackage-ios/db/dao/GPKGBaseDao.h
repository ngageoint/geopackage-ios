//
//  GPKGBaseDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"
#import "GPKGColumnValue.h"
#import "GPKGColumnValues.h"
#import "GPKGProjection.h"

@interface GPKGBaseDao : NSObject

@property (nonatomic, strong) NSString *databaseName;
@property (nonatomic) GPKGConnection *database;
@property (nonatomic, strong) NSArray *idColumns;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSMutableDictionary *columnIndex;

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(void) initializeColumnIndex;

-(BOOL) tableExists;

-(GPKGProjection *) getProjection: (NSObject *) object;

-(void) dropTable;

-(GPKGResultSet *) queryForId: (NSObject *) idValue;

-(NSObject *) queryForIdObject: (NSObject *) idValue;

-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues;

-(NSObject *) queryForMultiIdObject: (NSArray *) idValues;

-(GPKGResultSet *) queryForAll;

-(NSObject *) getObject: (GPKGResultSet *) results;

-(NSObject *) getFirstObject: (GPKGResultSet *)results;

-(GPKGResultSet *) rawQuery: (NSString *) query;

-(GPKGResultSet *) rawQuery: (NSString *) query andArgs: (NSArray *) args;

-(NSArray *) singleColumnResults: (GPKGResultSet *) results;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field
                              andValue: (NSObject *) value
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

-(GPKGResultSet *) queryForFieldValues: (GPKGColumnValues *) fieldValues;

-(GPKGResultSet *) queryForColumnValueFieldValues: (GPKGColumnValues *) fieldValues;

-(GPKGResultSet *) queryWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andWhereArgs: (NSArray *) whereArgs
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit;

-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy;

-(GPKGResultSet *) queryColumns: (NSArray *) columns
                       andWhere: (NSString *) where
                   andWhereArgs: (NSArray *) whereArgs
                     andGroupBy: (NSString *) groupBy
                      andHaving: (NSString *) having
                     andOrderBy: (NSString *) orderBy
                       andLimit: (NSString *) limit;

-(BOOL) idExists: (NSObject *) id;

-(BOOL) multiIdExists: (NSArray *) idValues;

-(NSObject *) queryForSameId: (NSObject *) object;

-(int) update: (NSObject *) object;

-(int) updateWithValues: (GPKGContentValues *) values andWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

-(int) delete: (NSObject *) object;

-(int) deleteById: (NSObject *) idValue;

-(int) deleteByMultiId: (NSArray *) idValues;

-(int) deleteWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs;

-(long long) create: (NSObject *) object;

-(long long) insert: (NSObject *) object;

-(long long) createIfNotExists: (NSObject *) object;

-(NSObject *) getId: (NSObject *) object;

-(NSArray *) getMultiId: (NSObject *) object;

-(void) setId: (NSObject *) object withIdValue: (NSObject *) id;

-(void) setMultiId: (NSObject *) object withIdValues: (NSArray *) idValues;

-(NSString *) buildPkWhereWithValue: (NSObject *) idValue;

-(NSArray *) buildPkWhereArgsWithValue: (NSObject *) idValue;

-(NSString *) buildPkWhereWithValues: (NSArray *) idValues;

-(NSString *) buildWhereWithFields: (GPKGColumnValues *) fields;

-(NSString *) buildWhereWithColumnValueFields: (GPKGColumnValues *) fields;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation;

-(NSString *) buildWhereWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

-(NSArray *) buildWhereArgsWithValues: (GPKGColumnValues *) fields;

-(NSArray *) buildWhereArgsWithValueArray: (NSArray *) values;

-(NSArray *) buildWhereArgsWithColumnValues: (GPKGColumnValues *) fields;

-(NSArray *) buildWhereArgsWithValue: (NSObject *) value;

-(NSArray *) buildWhereArgsWithColumnValue: (GPKGColumnValue *) value;

-(int) count;

-(int) countWhere: (NSString *) where;

-(int) countWhere: (NSString *) where andWhereArgs: (NSArray *) args;

@end
