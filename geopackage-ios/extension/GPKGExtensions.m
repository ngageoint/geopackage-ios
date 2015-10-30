//
//  GPKGExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGExtensions.h"
#import "GPKGUtils.h"

NSString * const GPKG_EX_EXTENSION_NAME_DIVIDER = @"_";
NSString * const GPKG_EX_TABLE_NAME = @"gpkg_extensions";
NSString * const GPKG_EX_COLUMN_TABLE_NAME = @"table_name";
NSString * const GPKG_EX_COLUMN_COLUMN_NAME = @"column_name";
NSString * const GPKG_EX_COLUMN_EXTENSION_NAME = @"extension_name";
NSString * const GPKG_EX_COLUMN_DEFINITION = @"definition";
NSString * const GPKG_EX_COLUMN_SCOPE = @"scope";

NSString * const GPKG_EST_READ_WRITE_NAME = @"read-write";
NSString * const GPKG_EST_WRITE_ONLY_NAME = @"write-only";

@implementation GPKGExtensions

-(enum GPKGExtensionScopeType) getExtensionScopeType{
    enum GPKGExtensionScopeType value = -1;
    
    if(self.scope != nil){
        NSDictionary *scopeTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:GPKG_EST_READ_WRITE], GPKG_EST_READ_WRITE_NAME,
                                    [NSNumber numberWithInteger:GPKG_EST_WRITE_ONLY], GPKG_EST_WRITE_ONLY_NAME,
                                    nil
                                    ];
        NSNumber *enumValue = [GPKGUtils objectForKey:self.scope inDictionary:scopeTypes];
        value = (enum GPKGExtensionScopeType)[enumValue intValue];
    }
    
    return value;
}

-(void) setExtensionScopeType: (enum GPKGExtensionScopeType) extensionScopeType{
    
    switch(extensionScopeType){
        case GPKG_EST_READ_WRITE:
            self.scope = GPKG_EST_READ_WRITE_NAME;
            break;
        case GPKG_EST_WRITE_ONLY:
            self.scope = GPKG_EST_WRITE_ONLY_NAME;
            break;
    }
    
}

-(void) setTableName:(NSString *)tableName{
    _tableName = tableName;
    if(tableName == nil){
        _columnName = nil;
    }
}

-(void) setExtensionNameWithAuthor: (NSString *) author andExtensionName: (NSString *) extensionName{
    [self setExtensionName:[GPKGExtensions buildExtensionNameWithAuthor:author andExtensionName:extensionName]];
}

-(NSString *) getAuthor{
    return [GPKGExtensions getAuthorWithExtensionName:self.extensionName];
}

-(NSString *) getExtensionNameNoAuthor{
    return [GPKGExtensions getExtensionNameNoAuthorWithExtensionName:self.extensionName];
}

+(NSString *) buildExtensionNameWithAuthor: (NSString *) author andExtensionName: (NSString *) extensionName{
    return [NSString stringWithFormat:@"%@%@%@", author, GPKG_EX_EXTENSION_NAME_DIVIDER, extensionName];
}

+(NSString *) getAuthorWithExtensionName: (NSString *) extensionName{
    NSString * author = nil;
    if(extensionName != nil){
        author = [GPKGUtils objectAtIndex:0 inArray:[extensionName componentsSeparatedByString:GPKG_EX_EXTENSION_NAME_DIVIDER]];
    }
    return author;
}

+(NSString *) getExtensionNameNoAuthorWithExtensionName: (NSString *) extensionName{
    NSString * value = nil;
    if(extensionName != nil){
        NSRange range = [extensionName rangeOfString:GPKG_EX_EXTENSION_NAME_DIVIDER];
        value = [extensionName substringFromIndex:NSMaxRange(range)];
    }
    return value;
}

@end
