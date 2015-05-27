//
//  GPKGResultSet.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/11/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface GPKGResultSet : NSObject

@property (nonatomic) sqlite3_stmt *statement;
@property (nonatomic) int count;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSDictionary * columnIndex;

-(instancetype) initWithStatement:(sqlite3_stmt *) statement andCount: (int) count;

-(BOOL) moveToNext;

-(BOOL) moveToFirst;

-(BOOL) moveToPosition: (int) position;

-(void) close;

-(NSArray *) getRow;

-(void) getRowPopulateValues: (NSMutableArray *) values andColumnTypes: (NSMutableArray *) types;

-(NSObject *) getValueWithIndex: (int) index;

-(int) getColumnIndexWithName: (NSString *) columnName;

-(int) getType: (int) columnIndex;

-(NSString *) getString: (int) columnIndex;

-(NSNumber *) getInt: (int) columnIndex;

-(NSData *) getBlob: (int) columnIndex;

-(NSNumber *) getLong: (int) columnIndex;

-(NSNumber *) getDouble: (int) columnIndex;

@end
