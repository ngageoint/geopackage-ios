//
//  GPKGFeatureTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/26/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureTable.h"
#import "GPKGContentsDataTypes.h"

@implementation GPKGFeatureTable

-(instancetype) initWithGeometryColumns: (GPKGGeometryColumns *) geometryColumns andColumns: (NSArray *) columns{
    self = [self initWithTable:geometryColumns.tableName andGeometryColumn:geometryColumns.columnName andColumns:columns];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [self initWithTable:tableName andGeometryColumn:nil andColumns:columns];
    return self;
}

-(instancetype) initWithTable: (NSString *) tableName andGeometryColumn: (NSString *) geometryColumn andColumns: (NSArray *) columns{
    self = [super initWithColumns:[[GPKGFeatureColumns alloc] initWithTable:tableName andGeometryColumn:geometryColumn andColumns:columns]];
    return self;
}

-(NSString *) dataType{
    return [self dataTypeWithDefault:GPKG_CDT_FEATURES_NAME];
}

-(void) validateContents:(GPKGContents *)contents{
    // Verify the Contents have a features data type
    if(![contents isFeaturesTypeOrUnknown]){
        [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of a Feature Table must have a data type of %@. actual type: %@", GPKG_CDT_FEATURES_NAME, contents.dataType];
    }
}

-(GPKGFeatureColumns *) featureColumns{
    return (GPKGFeatureColumns *) [super columns];
}

-(GPKGUserColumns *) createUserColumnsWithColumns: (NSArray<GPKGUserColumn *> *) columns{
    return [[GPKGFeatureColumns alloc] initWithTable:[self tableName] andGeometryColumn:[self geometryColumnName] andColumns:columns andCustom:YES];
}

-(int) geometryColumnIndex{
    return [self featureColumns].geometryIndex;
}

-(GPKGFeatureColumn *) geometryColumn{
    return [[self featureColumns] geometryColumn];
}

-(NSString *) geometryColumnName{
    return [self featureColumns].geometryColumnName;
    
}

-(NSArray<NSString *> *) idAndGeometryColumnNames{
    return [NSArray arrayWithObjects:[self pkColumnName], [self geometryColumnName], nil];
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGFeatureTable *featureTable = [super mutableCopyWithZone:zone];
    return featureTable;
}

@end
