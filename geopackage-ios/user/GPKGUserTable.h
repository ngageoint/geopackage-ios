//
//  GPKGUserTable.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGUserColumn.h"
#import "GPKGUserUniqueConstraint.h"

@interface GPKGUserTable : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSArray *columnNames;
@property (nonatomic, strong) NSArray *columns;
@property (nonatomic, strong) NSMutableDictionary *nameToIndex;
@property (nonatomic) int pkIndex;
@property (nonatomic, strong) NSArray *uniqueConstraints;

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

-(int) getColumnIndexWithColumnName: (NSString *) columnName;

-(NSArray *) getColumnNames;

-(NSString *) getColumnNameWithIndex: (int) index;

-(NSArray *) getColumns;

-(GPKGUserColumn *) getColumnWithIndex: (int) index;

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName;

-(int) columnCount;

-(GPKGUserColumn *) getPkColumn;

-(void) addUniqueConstraint: (GPKGUserUniqueConstraint *) uniqueConstraint;

@end
