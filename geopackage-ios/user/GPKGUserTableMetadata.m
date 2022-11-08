//
//  GPKGUserTableMetadata.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserTableMetadata.h"
#import "GPKGUserTable.h"

NSString * const GPKG_UTM_DEFAULT_ID_COLUMN_NAME = @"id";

@implementation GPKGUserTableMetadata

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.autoincrement = DEFAULT_AUTOINCREMENT;
    }
    return self;
}

-(NSString *) defaultDataType{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSArray<GPKGUserColumn *> *) buildColumns{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(NSString *) dataType{
    return _dataType != nil ? _dataType : [self defaultDataType];
}

-(NSString *) identifier{
    return _identifier != nil ? _identifier : [self tableName];
}

-(NSString *) idColumnName{
    return _idColumnName != nil ? _idColumnName : GPKG_UTM_DEFAULT_ID_COLUMN_NAME;
}

@end
