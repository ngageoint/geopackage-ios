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

-(instancetype) initWithTable: (NSString *) tableName{
    self = [super initWithTable:tableName];
    return self;
}

-(GPKGTileTable *) readTileTableWithConnection: (GPKGConnection *) db{
        return (GPKGTileTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGTileTable alloc] initWithTable:tableName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [GPKGTileColumn createColumnWithTableColumn:tableColumn];
}

@end
