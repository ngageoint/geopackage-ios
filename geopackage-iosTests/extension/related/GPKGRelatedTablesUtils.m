//
//  GPKGRelatedTablesUtils.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 6/29/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGRelatedTablesUtils.h"
#import "GPKGUtils.h"
#import "GPKGDublinCoreTypes.h"
#import "GPKGSimpleAttributesTable.h"
#import "GPKGTestUtils.h"
#import "GPKGDateTimeUtils.h"
#import "GPKGDublinCoreMetadata.h"

@implementation GPKGRelatedTablesUtils

+(NSArray<GPKGUserCustomColumn *> *) createAdditionalUserColumns{
    return [self createAdditionalUserColumnsWithNotNil:NO];
}

+(NSArray<GPKGUserCustomColumn *> *) createAdditionalUserColumnsWithNotNil: (BOOL) notNull{
    
    NSMutableArray * columns = [NSMutableArray array];
    
    // Add Dublin Core Metadata term columns
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_DATE] andDataType:GPKG_DT_DATETIME andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_DESCRIPTION] andDataType:GPKG_DT_TEXT andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_SOURCE] andDataType:GPKG_DT_TEXT andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:[GPKGDublinCoreTypes name:GPKG_DCM_TITLE] andDataType:GPKG_DT_TEXT andNotNull:notNull] toArray:columns];
    
    // Add test columns for common data types, some with limits
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_text" andDataType:GPKG_DT_TEXT andNotNull:notNull andDefaultValue:@""] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_real" andDataType:GPKG_DT_REAL andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_boolean" andDataType:GPKG_DT_BOOLEAN andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_blob" andDataType:GPKG_DT_BLOB andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_integer" andDataType:GPKG_DT_INTEGER andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_text_limited" andDataType:GPKG_DT_TEXT andMax: [NSNumber numberWithInt:5] andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_blob_limited" andDataType:GPKG_DT_BLOB andMax: [NSNumber numberWithInt:7] andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_date" andDataType:GPKG_DT_DATE andNotNull:notNull] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithName:@"test_datetime" andDataType:GPKG_DT_DATETIME andNotNull:notNull] toArray:columns];
    
    return columns;
}

+(NSArray<GPKGUserCustomColumn *> *) createSimpleUserColumns{
    return [self createSimpleUserColumnsWithNotNil:YES];
}

+(NSArray<GPKGUserCustomColumn *> *) createSimpleUserColumnsWithNotNil: (BOOL) notNull{
    
    NSMutableArray<GPKGUserCustomColumn *> *simpleUserColumns = [NSMutableArray array];
    
    NSArray<GPKGUserCustomColumn *> *allAdditionalColumns = [self createAdditionalUserColumnsWithNotNil:notNull];
    
    for(GPKGUserCustomColumn *column in allAdditionalColumns){
        if([GPKGSimpleAttributesTable isSimpleColumn:column]){
            [simpleUserColumns addObject:[GPKGUserCustomColumn createColumnWithName:column.name andDataType:column.dataType andMax:column.max andNotNull:column.notNull andDefaultValue:column.defaultValue]];
        }
    }

    return simpleUserColumns;
}

+(void) populateUserRowWithTable: (GPKGUserCustomTable *) userTable andRow: (GPKGUserCustomRow *) userRow andSkipColumns: (NSArray<NSString *> *) skipColumns{
    
    NSSet<NSString *> *skipColumnsSet = [NSSet setWithArray:skipColumns];
    
    for(GPKGUserCustomColumn *column in userTable.columns){
        if(![skipColumnsSet containsObject:column.name]){
            
            // Leave nullable columns null 20% of the time
            if(!column.notNull && (int)[GPKGDublinCoreTypes fromName:column.name] < 0){
                if ([GPKGTestUtils randomDouble] < 0.2) {
                    continue;
                }
            }
            
            NSObject * value = nil;
            
            switch (column.dataType) {
                    
                case GPKG_DT_TEXT:
                {
                    NSString * text = [[NSProcessInfo processInfo] globallyUniqueString];
                    if(column.max != nil && [text length] > [column.max intValue]){
                        text = [text substringToIndex:[column.max intValue]];
                    }
                    value = text;
                }
                    break;
                case GPKG_DT_REAL:
                case GPKG_DT_DOUBLE:
                    value = [[NSDecimalNumber alloc] initWithDouble:[GPKGTestUtils randomDoubleLessThan:5000.0]];
                    break;
                case GPKG_DT_BOOLEAN:
                    value = [NSNumber numberWithBool:([GPKGTestUtils randomDouble] < .5 ? NO : YES)];
                    break;
                case GPKG_DT_INTEGER:
                case GPKG_DT_INT:
                    value = [NSNumber numberWithInt:[GPKGTestUtils randomIntLessThan:500]];
                    break;
                case GPKG_DT_BLOB:
                {
                    NSData * blob = [[[NSProcessInfo processInfo] globallyUniqueString] dataUsingEncoding:NSUTF8StringEncoding];
                    if(column.max != nil && [blob length] > [column.max intValue]){
                        blob = [blob subdataWithRange:NSMakeRange(0, [column.max intValue])];
                    }
                    value = blob;
                }
                    break;
                case GPKG_DT_DATE:
                case GPKG_DT_DATETIME:
                {
                    NSDate *date = [NSDate date];
                    if([GPKGTestUtils randomDouble] < .5){
                        if(column.dataType == GPKG_DT_DATE){
                            value = [GPKGDateTimeUtils convertToDateWithString:[GPKGDateTimeUtils convertToStringWithDate:date andType:column.dataType]];
                        }else{
                            value = date;
                        }
                    }else{
                        value = [GPKGDateTimeUtils convertToStringWithDate:date andType:column.dataType];
                    }
                }
                    break;
                default:
                    [NSException raise:@"Not implemented" format:@"Not implemented for data type: %u", column.dataType];
            }
            
            [userRow setValueWithColumnName:column.name andValue:value];
            
        }
    }
    
}

+(void) validateUserRow: (GPKGUserCustomRow *) userRow withColumns: (NSArray<NSString *> *) columns{
    
    [GPKGTestUtils assertEqualIntWithValue:(int)columns.count andValue2:userRow.columnCount];
    
    for(int i = 0; i < userRow.columnCount; i++){
        GPKGUserColumn *column = [[[userRow userCustomTable] userCustomColumns] columnWithIndex:i];
        enum GPKGDataType dataType = column.dataType;
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:column.index];
        [GPKGTestUtils assertEqualWithValue:[columns objectAtIndex:i] andValue2:[userRow columnNameWithIndex:i]];
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:[userRow columnIndexWithColumnName:[columns objectAtIndex:i]]];
        int sqliteType = [userRow sqliteTypeWithIndex:i];
        NSObject *value = [userRow valueWithIndex:i];
        
        if(value != nil){
            switch (sqliteType) {
                    
                case SQLITE_INTEGER:
                    [GPKGTestUtils validateIntegerValue:value andDataType:column.dataType];
                    break;
                    
                case SQLITE_FLOAT:
                    [GPKGTestUtils validateFloatValue:value andDataType:column.dataType];
                    break;
                    
                case SQLITE_TEXT:
                {
                    if(dataType == GPKG_DT_DATE || dataType == GPKG_DT_DATETIME){
                        [GPKGTestUtils assertTrue:[value isKindOfClass:[NSDate class]]];
                        NSDate *date = (NSDate *) value;
                        NSString *dateString = [GPKGDateTimeUtils convertToStringWithDate:date andType:dataType];
                        [GPKGTestUtils assertTrue:[date compare:[GPKGDateTimeUtils convertToDateWithString:dateString]] == NSOrderedSame];
                    }else{
                        [GPKGTestUtils assertTrue:[value isKindOfClass:[NSString class]]];
                    }
                }
                    break;
                    
                case SQLITE_BLOB:
                    [GPKGTestUtils assertTrue:[value isKindOfClass:[NSData class]]];
                    break;
                    
            }
        }
        
    }
    
}

+(void) validateDublinCoreColumnsWithRow: (GPKGUserCustomRow *) userRow{
    
    [self validateDublinCoreColumnsWithRow:userRow andType:GPKG_DCM_DATE];
    [self validateSimpleDublinCoreColumnsWithRow:userRow];
    
}

+(void) validateSimpleDublinCoreColumnsWithRow: (GPKGUserCustomRow *) userRow{
    
    [self validateDublinCoreColumnsWithRow:userRow andType:GPKG_DCM_DESCRIPTION];
    [self validateDublinCoreColumnsWithRow:userRow andType:GPKG_DCM_SOURCE];
    [self validateDublinCoreColumnsWithRow:userRow andType:GPKG_DCM_TITLE];
    
}

+(void) validateDublinCoreColumnsWithRow: (GPKGUserCustomRow *) userRow andType: (enum GPKGDublinCoreType) type{
    
    GPKGUserCustomTable *customTable = [userRow userCustomTable];
    
    [GPKGTestUtils assertTrue:[GPKGDublinCoreMetadata hasColumn:type inTable:[userRow table]]];
    [GPKGTestUtils assertTrue:[GPKGDublinCoreMetadata hasColumn:type inRow:userRow]];
    GPKGUserCustomColumn *column1 = (GPKGUserCustomColumn *)[GPKGDublinCoreMetadata column:type fromTable:customTable];
    GPKGUserCustomColumn *column2 = (GPKGUserCustomColumn *)[GPKGDublinCoreMetadata column:type fromRow:userRow];
    [GPKGTestUtils assertNotNil:column1];
    [GPKGTestUtils assertNotNil:column2];
    [GPKGTestUtils assertEqualWithValue:column1 andValue2:column2];
    NSObject *value = [GPKGDublinCoreMetadata value:type fromRow:userRow];
    [GPKGTestUtils assertNotNil:value];
    
}

@end
