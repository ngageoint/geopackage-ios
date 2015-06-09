//
//  GPKGTileTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/5/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGTileTableReader.h"
#import "GPKGTileColumn.h"

@implementation GPKGTileTableReader

-(instancetype) initWithTileMatrixSet: (GPKGTileMatrixSet *) tileMatrixSet{
    self = [super initWithTableName:tileMatrixSet.tableName];
    if(self != nil){
        self.tileMatrixSet = tileMatrixSet;
    }
    return self;
}

-(GPKGTileTable *) readTileTableWithConnection: (GPKGConnection *) db{
        return (GPKGTileTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGTileTable alloc] initWithTable:tableName andColumns:columns];
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
    
    GPKGTileColumn * column = [[GPKGTileColumn alloc] initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    
    return column;
}

@end
