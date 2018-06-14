//
//  GPKGUserCustomTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomTable.h"

@implementation GPKGUserCustomTable

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [self initWithTable:tableName andColumns:columns andRequiredColumns:nil];
}

-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns{
    self = [super initWithTable:tableName andColumns:columns];
    if(self != nil){

        if (requiredColumns != nil && requiredColumns.count > 0) {
            
            NSSet<NSString *> *search = [[NSSet alloc] initWithArray:requiredColumns];
            NSMutableDictionary<NSString *, NSNumber *> *found = [[NSMutableDictionary alloc] init];
            
            // Find the required columns
            for (GPKGUserCustomColumn *column in columns) {
                
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
    return self;
}

-(instancetype) initWithCustomTable: (GPKGUserCustomTable *) userCustomTable{
    self = [super initWithUserTable:userCustomTable];
    return self;
}

@end
