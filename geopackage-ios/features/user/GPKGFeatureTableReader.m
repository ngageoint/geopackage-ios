//
//  GPKGFeatureTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTableReader.h"

@implementation GPKGFeatureTableReader

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    self = [self initWithTable:geometryColumns.tableName andGeometryColumn:geometryColumns.columnName];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumnName{
    self = [super initWithTable:tableName];
    if(self != nil){
        self.columnName = geometryColumnName;
    }
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName{
    self = [self initWithTable:tableName andGeometryColumn:nil];
    return self;
}

-(GPKGFeatureTable *) readFeatureTableWithConnection: (GPKGConnection *) db{
    return (GPKGFeatureTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGFeatureTable alloc] initWithTable:tableName andGeometryColumn:self.columnName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [GPKGFeatureColumn createColumnWithTableColumn:tableColumn];
}

@end
