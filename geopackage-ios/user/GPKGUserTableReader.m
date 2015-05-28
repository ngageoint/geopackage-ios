//
//  GPKGUserTableReader.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/27/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserTableReader.h"
#import "GPKGUtils.h"

NSString * const GPKG_UTR_CID = @"cid";
NSString * const GPKG_UTR_NAME = @"name";
NSString * const GPKG_UTR_TYPE = @"type";
NSString * const GPKG_UTR_NOT_NULL = @"notnull";
NSString * const GPKG_UTR_PK = @"pk";
NSString * const GPKG_UTR_DFLT_VALUE = @"dflt_value";

@implementation GPKGUserTableReader

-(instancetype) initWithTableName: (NSString *) tableName{
    self = [super init];
    if(self != nil){
        self.tableName = tableName;
    }
    return self;
}

-(GPKGUserTable *) createTableWithName: (NSString *) tableName andColumns: (NSArray *) columns{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGUserColumn *) createColumnWithResults: (GPKGResultSet *) results
                                   andIndex: (int) index
                                   andName: (NSString *) name
                                   andType: (NSString *) type
                                   andMax: (NSNumber *) max
                                   andNotNull: (BOOL) notNull
                                   andDefaultValueIndex: (int) defaultValueIndex
                                   andPrimaryKey: (BOOL) primaryKey{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(GPKGUserTable *) readTableWithConnection: (GPKGConnection *) db{
    
    NSMutableArray * columnList = [[NSMutableArray alloc] init];
    
    GPKGResultSet * result = [db rawQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", self.tableName]];
    @try{
        while ([result moveToNext]){
            int index = [[result getInt:[result getColumnIndexWithName:GPKG_UTR_CID]] intValue];
            NSString * name = [result getString:[result getColumnIndexWithName:GPKG_UTR_NAME]];
            NSString * type = [result getString:[result getColumnIndexWithName:GPKG_UTR_TYPE]];
            BOOL notNull = [[result getInt:[result getColumnIndexWithName:GPKG_UTR_NOT_NULL]] intValue] == 1;
            BOOL primarykey = [[result getInt:[result getColumnIndexWithName:GPKG_UTR_PK]] intValue] == 1;
            
            NSNumber * max = nil;
            if(type != nil&& [type hasSuffix:@")"]){
                NSRange maxStartRange = [type rangeOfString:@"("];
                if(maxStartRange.length != 0){
                    NSInteger maxStart = maxStartRange.location + 1;
                    NSRange maxRange = NSMakeRange(maxStart, [type length] - maxStart);
                    NSString * maxString = [type substringWithRange:maxRange];
                    if([maxString length] > 0){
                        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                        formatter.numberStyle = NSNumberFormatterDecimalStyle;
                        max = [formatter numberFromString:maxString];
                    }
                    type = [type substringToIndex:maxStartRange.location];
                }
                
            }
            
            int defaultValueIndex = [result getColumnIndexWithName:GPKG_UTR_DFLT_VALUE];
            
            GPKGUserColumn * column = [self createColumnWithResults:result andIndex:index andName:name andType:type andMax:max andNotNull:notNull andDefaultValueIndex:defaultValueIndex andPrimaryKey:primarykey];
            [GPKGUtils addObject:column toArray:columnList];
        }
    }@finally{
        [result close];
    }
    
    if([columnList count] == 0){
        [NSException raise:@"No Table" format:@"Table does not exist: %@", self.tableName];
    }
    
    return [self createTableWithName:self.tableName andColumns:columnList];
}

@end
