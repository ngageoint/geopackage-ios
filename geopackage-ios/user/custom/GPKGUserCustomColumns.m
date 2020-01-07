//
//  GPKGUserCustomColumns.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/6/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserCustomColumns.h"
#import "GPKGUserCustomColumn.h"

@implementation GPKGUserCustomColumns

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns{
    return [self initWithTable:tableName andColumns:columns andRequiredColumns:nil];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns{
    return [self initWithTable:tableName andColumns:columns andRequiredColumns:requiredColumns andCustom:NO];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andCustom: (BOOL) custom{
    return [self initWithTable:tableName andColumns:columns andRequiredColumns:nil andCustom:custom];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns andCustom: (BOOL) custom{
    self = [super initWithTable:tableName andColumns:columns andCustom:custom];
    if(self != nil){
        _requiredColumns = requiredColumns;
        [self updateColumns];
    }
    return self;
}

-(instancetype) initWithUserCustomColumns: (GPKGUserCustomColumns *) userCustomColumns{
    self = [super initWithUserColumns:userCustomColumns];
    if(self != nil){
        if(userCustomColumns.requiredColumns != nil){
            _requiredColumns = [NSMutableArray arrayWithArray:userCustomColumns.requiredColumns];
        }
    }
    return self;
}

-(void) updateColumns{
    [super updateColumns];
    
    if (!self.custom && self.requiredColumns != nil && self.requiredColumns.count > 0) {
        
        NSSet<NSString *> *search = [[NSSet alloc] initWithArray:self.requiredColumns];
        NSMutableDictionary<NSString *, NSNumber *> *found = [[NSMutableDictionary alloc] init];
        
        // Find the required columns
        for (GPKGUserCustomColumn *column in [self columns]) {
            
            NSString *columnName = column.name;
            int columnIndex = column.index;
            
            if([search containsObject:columnName]){
                NSNumber *previousIndex = [found objectForKey:columnName];
                [self duplicateCheckWithIndex:columnIndex andPreviousIndex:previousIndex andColumn:columnName];
                [found setObject:[NSNumber numberWithInt:columnIndex] forKey:columnName];
            }
        }
        
        // Verify the required columns were found
        for (NSString *requiredColumn in search) {
            [self missingCheckWithIndex:[found objectForKey:requiredColumn] andColumn:requiredColumn];
        }
    }
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserCustomColumns *userCustomColumns = [super mutableCopyWithZone:zone];
    return userCustomColumns;
}

@end
