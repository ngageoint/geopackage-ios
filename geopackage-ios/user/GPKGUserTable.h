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
@property (nonatomic, strong) NSDictionary *nameToIndex;
@property (nonatomic) int pkIndex;
@property (nonatomic, strong) NSMutableArray *uniqueConstraints;

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns;

-(void) duplicateCheckWithIndex: (int) index andPreviousIndex: (NSNumber *) previousIndex andColumn: (NSString *) column;

-(void) typeCheckWithExpected: (enum GPKGDataType) expected andColumn: (GPKGUserColumn *) column;

-(void) missingCheckWithIndex: (NSNumber *) index andColumn: (NSString *) column;

-(int) getColumnIndexWithColumnName: (NSString *) columnName;

-(NSString *) getColumnNameWithIndex: (int) index;

-(GPKGUserColumn *) getColumnWithIndex: (int) index;

-(GPKGUserColumn *) getColumnWithColumnName: (NSString *) columnName;

-(int) columnCount;

-(GPKGUserColumn *) getPkColumn;

-(void) addUniqueConstraint: (GPKGUserUniqueConstraint *) uniqueConstraint;

@end
