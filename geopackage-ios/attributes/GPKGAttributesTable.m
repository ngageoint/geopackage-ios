//
//  GPKGAttributesTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 11/1/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGAttributesTable.h"
#import "GPKGContentsDataTypes.h"

@implementation GPKGAttributesTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    self = [super initWithTable:tableName andColumns:columns];
    return self;
}

-(void) setContents:(GPKGContents *)contents{
    _contents = contents;
    if(contents != nil){
        // Verify the Contents have an attributes data type
        enum GPKGContentsDataType dataType = [contents getContentsDataType];
        if(dataType != GPKG_CDT_ATTRIBUTES){
            [NSException raise:@"Invalid Contents Data Type" format:@"The Contents of an Attributes Table must have a data type of attributes"];
        }
    }
}

@end
