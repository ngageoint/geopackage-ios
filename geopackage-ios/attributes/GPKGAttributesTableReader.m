//
//  GPKGAttributesTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/17/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesTableReader.h"
#import "GPKGAttributesColumn.h"

@implementation GPKGAttributesTableReader

-(instancetype) initWithTableName: (NSString *) tableName{
    self = [super initWithTableName:tableName];
    return self;
}

-(GPKGAttributesTable *) readAttributesTableWithConnection: (GPKGConnection *) db{
    return (GPKGAttributesTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGAttributesTable alloc] initWithTable:tableName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithResults: (GPKGResultSet *) results
                                   andIndex: (int) index
                                    andName: (NSString *) name
                                    andType: (NSString *) type
                                     andMax: (NSNumber *) max
                                 andNotNull: (BOOL) notNull
                       andDefaultValueIndex: (int) defaultValueIndex
                              andPrimaryKey: (BOOL) primaryKey{
    
    enum GPKGDataType dataType = [GPKGDataTypes fromName:type];
    
    NSObject * defaultValue = [results getValueWithIndex:defaultValueIndex];
    
    GPKGAttributesColumn * column = [[GPKGAttributesColumn alloc] initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    
    return column;
}

@end
