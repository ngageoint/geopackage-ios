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
    self = [super initWithTableName:geometryColumns.tableName];
    if(self != nil){
        self.geometryColumns = geometryColumns;
    }
    return self;
}

-(GPKGFeatureTable *) readFeatureTableWithConnection: (GPKGConnection *) db{
    return (GPKGFeatureTable *)[self readTableWithConnection:db];
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    return [[GPKGFeatureTable alloc] initWithTable:tableName andColumns:columns];
}

-(GPKGUserColumn *) createColumnWithResults: (GPKGResultSet *) results
                                   andIndex: (int) index
                                    andName: (NSString *) name
                                    andType: (NSString *) type
                                     andMax: (NSNumber *) max
                                 andNotNull: (BOOL) notNull
                       andDefaultValueIndex: (int) defaultValueIndex
                              andPrimaryKey: (BOOL) primaryKey{
    
    BOOL geometry = [name isEqualToString:self.geometryColumns.columnName];
    
    enum WKBGeometryType geometryType = WKB_NONE;
    enum GPKGDataType dataType = GPKG_DT_GEOMETRY;
    if(geometry){
        geometryType = [WKBGeometryTypes fromName:type];
    }else{
        dataType = [GPKGDataTypes fromName:type];
    }
    
    NSObject * defaultValue = [results getValueWithIndex:defaultValueIndex];
    
    GPKGFeatureColumn * column = [[GPKGFeatureColumn alloc] initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey andGeometryType:geometryType];
    
    return column;
}

@end
