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

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(NSString *) getTableName;

-(BOOL) isTableExists;

-(NSObject *) queryForId: (NSObject *) idValue;

-(NSObject *) queryForMultiId: (NSArray *) idValues;

-(GPKGResultSet *) queryForAll;

-(NSObject *) getObject: (GPKGResultSet *) results;

-(NSObject *) getFirstObject: (GPKGResultSet *)results;

-(GPKGResultSet *) query: (NSString *) query;

-(NSArray *) singleColumnResults: (GPKGResultSet *) results;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value;

-(NSString *) buildSelectAll;

-(NSString *) buildSelectAllWithWhere: (NSString *) where;

-(NSString *) buildWhereWithFields: (NSDictionary *) fields;

-(NSString *) buildWhereWithColumnValueFields: (NSDictionary *) fields;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation;

-(NSString *) buildWhereWithField: (NSString *) field andColumnValue: (GPKGColumnValue *) value;

-(int) count;

-(int) countWhere: (NSString *) where;

@end
