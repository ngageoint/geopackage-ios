//
//  GPKGBaseDao.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/8/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGConnection.h"

@interface GPKGBaseDao : NSObject

@property (nonatomic) GPKGConnection *database;

-(instancetype) initWithDatabase: (GPKGConnection *) database;

-(NSString *) getTableName;

-(BOOL) isTableExists;

-(NSObject *) queryForId: (NSObject *) idValue;

-(NSObject *) queryForMultiId: (NSArray *) idValues;

-(GPKGResultSet *) queryForAll;

-(NSObject *) getObject: (GPKGResultSet *) results;

-(GPKGResultSet *) query: (NSString *) query;

-(NSArray *) singleColumnResults: (GPKGResultSet *) results;

-(GPKGResultSet *) queryForEqWithField: (NSString *) field andValue: (NSObject *) value;

-(NSString *) buildSelectAll;

-(NSString *) buildSelectAllWithWhere: (NSString *) where;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value;

-(NSString *) buildWhereWithField: (NSString *) field andValue: (NSObject *) value andOperation: (NSString *) operation;

@end
