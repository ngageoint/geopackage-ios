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

-(void) dropTable;

-(GPKGResultSet *) queryForId: (NSObject *) idValue;

-(NSObject *) queryForIdObject: (NSObject *) idValue;

-(GPKGResultSet *) queryForMultiId: (NSArray *) idValues;

-(NSObject *) queryForMultiIdObject: (NSArray *) idValues;

-(GPKGResultSet *) queryForAll;

-(NSObject *) getObject: (GPKGResultSet *) results;

-(NSObject *) getFirstObject: (GPKGResultSet *)results;

-(GPKGResultSet *) rawQuery: (NSString *) query;

-(NSArray *) singleColumnResults: (GPKGResultSet *) results;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field
                              andValue: (NSObject *) value
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

-(GPKGResultSet *) queryForFieldValues: (NSDictionary *) fieldValues;

-(GPKGResultSet *) queryForColumnValueFieldValues: (NSDictionary *) fieldValues;

-(GPKGResultSet *) queryWhere: (NSString *) where;

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy;

-(GPKGResultSet *) queryWhere: (NSString *) where
                              andGroupBy: (NSString *) groupBy
                              andHaving: (NSString *) having
                              andOrderBy: (NSString *) orderBy
                              andLimit: (NSString *) limit;

-(NSObject *) queryForSameId: (NSObject *) object;

-(int) update: (NSObject *) object;

-(int) delete: (NSObject *) object;

-(int) deleteById: (NSObject *) idValue;

-(int) deleteByMultiId: (NSArray *) idValues;

-(int) deleteWhere: (NSString *) where;

-(long long) create: (NSObject *) object;

-(long long) insert: (NSObject *) object;

-(long long) createIfNotExists: (NSObject *) object;

-(NSArray *) getIdValues: (NSObject *) object;

-(NSString *) buildPkWhereWithValue: (NSObject *) idValue;

-(NSString *) buildPkWhereWithValues: (NSArray *) idValues;

-(NSString *) buildWhereWithFields: (NSDictionary *) fields;

-(NSString *) buildWhereWithColumnValueFields: (NSDictionary *) fields;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation;

-(NSString *) buildWhereWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

-(int) count;

-(int) countWhere: (NSString *) where;

@end
