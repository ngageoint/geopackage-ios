//
//  GPKGExtensions.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGExtensions.h"

NSString * const EX_EXTENSION_NAME_DIVIDER = @"_";
NSString * const EX_TABLE_NAME = @"gpkg_extensions";
NSString * const EX_COLUMN_TABLE_NAME = @"table_name";
NSString * const EX_COLUMN_COLUMN_NAME = @"column_name";
NSString * const EX_COLUMN_EXTENSION_NAME = @"extension_name";
NSString * const EX_COLUMN_DEFINITION = @"definition";
NSString * const EX_COLUMN_SCOPE = @"scope";

NSString * const EST_READ_WRITE = @"read-write";
NSString * const EST_WRITE_ONLY = @"write-only";

@implementation GPKGExtensions

-(enum GPKGExtensionScopeType) getExtensionScopeType{
    enum GPKGExtensionScopeType value = -1;
    
    if(self.scope != nil){
        NSDictionary *scopeTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:READ_WRITE], EST_READ_WRITE,
                                    [NSNumber numberWithInteger:WRITE_ONLY], EST_WRITE_ONLY,
                                    nil
                                    ];
        NSNumber *enumValue = [scopeTypes objectForKey:self.scope];
        value = (enum GPKGExtensionScopeType)[enumValue intValue];
    }
    
    return value;
}

-(void) setExtensionScopeType: (enum GPKGExtensionScopeType) extensionScopeType{
    
    switch(extensionScopeType){
        case READ_WRITE:
            self.scope = EST_READ_WRITE;
            break;
        case WRITE_ONLY:
            self.scope = EST_WRITE_ONLY;
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
    [self setExtensionName:[NSString stringWithFormat:@"%@%@%@", author, EX_EXTENSION_NAME_DIVIDER, extensionName]];
}

-(NSString *) getAuthor{
    NSString * author = nil;
    if(self.extensionName != nil){
        author = [[self.extensionName componentsSeparatedByString:EX_EXTENSION_NAME_DIVIDER] objectAtIndex:0];
    }
    return author;
}

-(NSString *) getExtensionNameNoAuthor{
    NSString * value = nil;
    if(self.extensionName != nil){
        value = [[self.extensionName componentsSeparatedByString:EX_EXTENSION_NAME_DIVIDER] objectAtIndex:1];
    }
    return value;
}

@end
