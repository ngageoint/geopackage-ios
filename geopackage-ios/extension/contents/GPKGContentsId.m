//
//  GPKGContentsId.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/8/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGContentsId.h"

NSString * const GPKG_CI_TABLE_NAME = @"nga_contents_id";
NSString * const GPKG_CI_COLUMN_PK = @"id";
NSString * const GPKG_CI_COLUMN_ID = @"id";
NSString * const GPKG_CI_COLUMN_TABLE_NAME = @"table_name";

@implementation GPKGContentsId

-(instancetype) init{
    self = [super init];
    return self;
}

-(void) setContents:(GPKGContents *)contents{
    _contents = contents;
    if(contents != nil){
        _tableName = contents.tableName;
    }else{
        _tableName = nil;
    }
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGContentsId *contentsId = [[GPKGContentsId alloc] init];
    contentsId.id = _id;
    contentsId.contents = _contents;
    contentsId.tableName = _tableName;
    return contentsId;
}

@end
