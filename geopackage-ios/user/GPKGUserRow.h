//
//  GPKGUserRow.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserTable.h"

@interface GPKGUserRow : NSObject

@property (nonatomic, strong) GPKGUserTable *table;
@property (nonatomic, strong) NSArray *columnTypes;
@property (nonatomic, strong) NSArray *values;

-(instancetype) initWithTable: (GPKGUserTable *) table andColumnTypes: (NSArray *) columnTypes andValues: (NSArray *) values;

-(instancetype) initWithTable: (GPKGUserTable *) table;

-(int) columnCount;

-(NSArray *) getColumnNames;

-(NSString *) getColumnNameWithIndex: (int) index;

-(int) getColumnIndexWithColumnName: (NSString *) columnName;

-(NSObject *) getValueWithIndex: (int) index;

-(NSObject *) getValueWithColumnName: (NSString *) columnName;

-(int) getRowColumnTypeWithIndex: (int) index;

-(int) getRowColumnTypeWithColumnName: (NSString *) columnName;

-(GPKGUserColumn *) getColumnWithIndex: (int) index;

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName;

-(NSNumber *) getId;

-(int) getPkColumnIndex;

-(GPKGUserColumn *) getPkColumn;

-(void) setValueWithIndex: (int) index andValue: (NSObject *) value;

-(void) setValueWithColumnName: (NSString *) columnName andValue: (NSObject *) value;

-(void) setId: (NSNumber *) id;

-(void) resetId;

-(void) validateValueWithColumn: (GPKGUserColumn *) column andValue: (NSObject *) value andValueTypes: (NSArray *) valueTypes;

@end
