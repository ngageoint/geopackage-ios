//
//  GPKGUserCustomTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/19/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomTableReader.h"

@implementation GPKGUserCustomTableReader

-(instancetype) initWithTable: (NSString *) tableName{
    self = [super initWithTable:tableName];
    return self;
}

-(GPKGUserCustomTable *) readUserCustomTableWithConnection: (GPKGConnection *) db{
    return (GPKGUserCustomTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGUserCustomTable alloc] initWithTable:tableName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithResults: (GPKGResultSet *) results
                                   andIndex: (int) index
                                    andName: (NSString *) name
                                    andType: (NSString *) type
                                     andMax: (NSNumber *) max
                                 andNotNull: (BOOL) notNull
                       andDefaultValueIndex: (int) defaultValueIndex
                              andPrimaryKey: (BOOL) primaryKey{
    
    enum GPKGDataType dataType = [self dataType:type];
    
    NSObject * defaultValue = [results getValueWithIndex:defaultValueIndex];
    
    GPKGUserCustomColumn * column = [[GPKGUserCustomColumn alloc] initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    
    return column;
}

+(GPKGUserCustomTable *) readTableWithConnection: (GPKGConnection *) db andTableName: (NSString *) tableName{
    GPKGUserCustomTableReader *tableReader = [[GPKGUserCustomTableReader alloc] initWithTable:tableName];
    GPKGUserCustomTable *customTable = [tableReader readUserCustomTableWithConnection:db];
    return customTable;
}

@end
