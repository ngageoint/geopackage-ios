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

+(NSArray<GPKGUserCustomColumn *> *) createAdditionalUserColumnsAtIndex: (int) startingIndex{
    return [self createAdditionalUserColumnsAtIndex:startingIndex andNotNil:NO];
}

+(NSArray<GPKGUserCustomColumn *> *) createAdditionalUserColumnsAtIndex: (int) startingIndex andNotNil: (BOOL) notNull{
    
    NSMutableArray * columns = [[NSMutableArray alloc] init];
    
    int columnIndex = startingIndex;
    
    // Add Dublin Core Metadata term columns
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:[GPKGDublinCoreTypes name:GPKG_DCM_DATE] andDataType:GPKG_DT_DATETIME andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:[GPKGDublinCoreTypes name:GPKG_DCM_DESCRIPTION] andDataType:GPKG_DT_TEXT andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:[GPKGDublinCoreTypes name:GPKG_DCM_SOURCE] andDataType:GPKG_DT_TEXT andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:[GPKGDublinCoreTypes name:GPKG_DCM_TITLE] andDataType:GPKG_DT_TEXT andNotNull:notNull andDefaultValue:nil] toArray:columns];
    
    // Add test columns for common data types, some with limits
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_text" andDataType:GPKG_DT_TEXT andNotNull:notNull andDefaultValue:@""] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_real" andDataType:GPKG_DT_REAL andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_boolean" andDataType:GPKG_DT_BOOLEAN andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_blob" andDataType:GPKG_DT_BLOB andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_integer" andDataType:GPKG_DT_INTEGER andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_text_limited" andDataType:GPKG_DT_TEXT andMax: [NSNumber numberWithInt:5] andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_blob_limited" andDataType:GPKG_DT_BLOB andMax: [NSNumber numberWithInt:7] andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_date" andDataType:GPKG_DT_DATE andNotNull:notNull andDefaultValue:nil] toArray:columns];
    [GPKGUtils addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:@"test_datetime" andDataType:GPKG_DT_DATETIME andNotNull:notNull andDefaultValue:nil] toArray:columns];
    
    return columns;
}

+(NSArray<GPKGUserCustomColumn *> *) createSimpleUserColumnsAtIndex: (int) startingIndex{
    return [self createSimpleUserColumnsAtIndex:startingIndex andNotNil:YES];
}

+(NSArray<GPKGUserCustomColumn *> *) createSimpleUserColumnsAtIndex: (int) startingIndex andNotNil: (BOOL) notNull{
    
    NSMutableArray<GPKGUserCustomColumn *> *simpleUserColumns = [[NSMutableArray alloc] init];
    int columnIndex = startingIndex;
    
    NSArray<GPKGUserCustomColumn *> *allAdditionalColumns = [self createAdditionalUserColumnsAtIndex:startingIndex andNotNil:notNull];
    
    for(GPKGUserCustomColumn *column in allAdditionalColumns){
        if([GPKGSimpleAttributesTable isSimpleColumn:column]){
            [simpleUserColumns addObject:[GPKGUserCustomColumn createColumnWithIndex:columnIndex++ andName:column.name andDataType:column.dataType andMax:column.max andNotNull:column.notNull andDefaultValue:column.defaultValue]];
        }
    }

    return simpleUserColumns;
}

+(void) populateUserRowWithTable: (GPKGUserCustomTable *) userTable andRow: (GPKGUserCustomRow *) userRow andSkipColumns: (NSArray<NSString *> *) skipColumns{
    
    NSSet<NSString *> *skipColumnsSet = [[NSSet alloc] initWithArray:skipColumns];
    
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
                    value = [GPKGTestUtils roundDouble:[GPKGTestUtils randomDoubleLessThan:5000.0]];
                    break;
                case GPKG_DT_BOOLEAN:
                    value = [NSNumber numberWithBool:([GPKGTestUtils randomDouble] < .5 ? false : true)];
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
        GPKGUserCustomColumn *column = [[userRow table].columns objectAtIndex:i];
        enum GPKGDataType dataType = column.dataType;
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:column.index];
        [GPKGTestUtils assertEqualWithValue:[columns objectAtIndex:i] andValue2:[userRow getColumnNameWithIndex:i]];
        [GPKGTestUtils assertEqualIntWithValue:i andValue2:[userRow getColumnIndexWithColumnName:[columns objectAtIndex:i]]];
        int rowType = [userRow getRowColumnTypeWithIndex:i];
        NSObject *value = [userRow getValueWithIndex:i];
        
        switch (rowType) {
                
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
                
            case SQLITE_NULL:
                [GPKGTestUtils assertNil:value];
                break;
                
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
    
    GPKGUserCustomTable *customTable = [userRow table];
    
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
