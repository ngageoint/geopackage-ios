//
//  GPKGAlterTableCreateTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGAlterTableCreateTestCase.h"
#import "GPKGAlterTableUtils.h"
#import "GPKGTestUtils.h"
#import "GPKGAlterTable.h"

@implementation GPKGAlterTableCreateTestCase

/**
 * Test column alters
 */
-(void) testColumns{
    [GPKGAlterTableUtils testColumns:self.geoPackage];
}

/**
 * Test copy feature table
 */
-(void) testCopyFeatureTable{
    [GPKGAlterTableUtils testCopyFeatureTable:self.geoPackage];
}

/**
 * Test copy tile table
 */
-(void) testCopyTileTable{
    [GPKGAlterTableUtils testCopyTileTable:self.geoPackage];
}

/**
 * Test copy attributes table
 */
-(void) testCopyAttributesTable{
    [GPKGAlterTableUtils testCopyAttributesTable:self.geoPackage];
}

/**
 * Test copy user table
 */
-(void) testCopyUserTable{
    [GPKGAlterTableUtils testCopyUserTable:self.geoPackage];
}

/**
 * Test alter column
 */
-(void) testAlterColumn{

    NSString *tableName = @"user_test_table";
    NSString *columnName = @"column";
    int countCount = 0;

    NSMutableArray<GPKGUserCustomColumn *> *columns = [NSMutableArray array];
    [columns addObject:[GPKGUserCustomColumn createPrimaryKeyColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount]]];
    GPKGUserCustomColumn *column2 = [GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount] andDataType:GPKG_DT_TEXT andNotNull:YES];
    [column2 addUniqueConstraint];
    [columns addObject:column2];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount] andDataType:GPKG_DT_TEXT andNotNull:YES andDefaultValue:@"default_value"]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount] andDataType:GPKG_DT_BOOLEAN]];
    [columns addObject:[GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount] andDataType:GPKG_DT_DOUBLE]];
    GPKGUserCustomColumn *column6 = [GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount] andDataType:GPKG_DT_INTEGER andNotNull:YES];
    [column6 addConstraintSql:[NSString stringWithFormat:@"CONSTRAINT check_constraint CHECK (%@%d >= 0)", columnName, countCount]];
    [columns addObject:column6];
    GPKGUserCustomColumn *column7 = [GPKGUserCustomColumn createColumnWithName:[NSString stringWithFormat:@"%@%d", columnName, ++countCount] andDataType:GPKG_DT_INTEGER];
    [column7 addConstraintSql:[NSString stringWithFormat:@"CONSTRAINT another_check_constraint_13 CHECK (%@%d >= 0)", columnName, countCount]];
    [columns addObject:column7];

    GPKGUserCustomTable *table = [[GPKGUserCustomTable alloc] initWithTable:tableName andColumns:columns];

    [self.geoPackage createUserTable:table];

    // Double column not null constraint
    GPKGUserCustomColumn *doubleColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:4];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_DOUBLE andValue2:doubleColumn.dataType];
    [GPKGTestUtils assertFalse:doubleColumn.notNull];

    // Double not null
    [doubleColumn addNotNullConstraint];
    [GPKGAlterTable alterColumn:doubleColumn inTableName:tableName withConnection:self.geoPackage.database];
    doubleColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:4];
    [GPKGTestUtils assertTrue:doubleColumn.notNull];

    // Double not null removed
    [doubleColumn setNotNull:NO];
    [GPKGAlterTable alterColumn:doubleColumn inTableName:tableName withConnection:self.geoPackage.database];
    doubleColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:4];
    [GPKGTestUtils assertFalse:doubleColumn.notNull];

    // Boolean default value constraint
    GPKGUserCustomColumn *booleanColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:3];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_BOOLEAN andValue2:booleanColumn.dataType];
    [GPKGTestUtils assertFalse:[booleanColumn hasDefaultValue]];

    // Default boolean value of true
    [booleanColumn setDefaultValue:[NSNumber numberWithBool:YES]];
    [GPKGAlterTable alterColumn:booleanColumn inTableName:tableName withConnection:self.geoPackage.database];
    booleanColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:3];
    [GPKGTestUtils assertTrue:[booleanColumn hasDefaultValue]];
    [GPKGTestUtils assertTrue:[booleanColumn defaultValue]];

    // Default boolean value of false
    [booleanColumn setDefaultValue:[NSNumber numberWithBool:NO]];
    [GPKGAlterTable alterColumn:booleanColumn inTableName:tableName withConnection:self.geoPackage.database];
    booleanColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:3];
    [GPKGTestUtils assertTrue:[booleanColumn hasDefaultValue]];
    [GPKGTestUtils assertFalse:[((NSNumber *)[booleanColumn defaultValue]) boolValue]];

    // Default boolean value removed
    [booleanColumn setDefaultValue:nil];
    [GPKGAlterTable alterColumn:booleanColumn inTableName:tableName withConnection:self.geoPackage.database];
    booleanColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:3];
    [GPKGTestUtils assertFalse:[booleanColumn hasDefaultValue]];
    [GPKGTestUtils assertNil:[booleanColumn defaultValue]];

    // Primary key
    GPKGUserCustomColumn *pkColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:0];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_INTEGER andValue2:pkColumn.dataType];
    [GPKGTestUtils assertTrue:pkColumn.primaryKey];
    [GPKGTestUtils assertTrue:pkColumn.autoincrement];

    // Autoincrement false
    [pkColumn setAutoincrement:NO];
    [GPKGAlterTable alterColumn:pkColumn inTableName:tableName withConnection:self.geoPackage.database];
    pkColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:0];
    [GPKGTestUtils assertTrue:pkColumn.primaryKey];
    [GPKGTestUtils assertFalse:pkColumn.autoincrement];

    // Autoincrement true
    [pkColumn setAutoincrement:YES];
    [GPKGAlterTable alterColumn:pkColumn inTableName:tableName withConnection:self.geoPackage.database];
    pkColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:0];
    [GPKGTestUtils assertTrue:pkColumn.primaryKey];
    [GPKGTestUtils assertTrue:pkColumn.autoincrement];

    // Primary key false
    [pkColumn setPrimaryKey:NO];
    [GPKGAlterTable alterColumn:pkColumn inTableName:tableName withConnection:self.geoPackage.database];
    pkColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:0];
    [GPKGTestUtils assertFalse:pkColumn.primaryKey];
    [GPKGTestUtils assertFalse:pkColumn.autoincrement];

    // Text unique constraint
    GPKGUserCustomColumn *textColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:1];
    [GPKGTestUtils assertEqualIntWithValue:GPKG_DT_TEXT andValue2:textColumn.dataType];
    [GPKGTestUtils assertTrue:textColumn.unique];

    // Unique text removed
    [textColumn setUnique:NO];
    [GPKGAlterTable alterColumn:textColumn inTableName:tableName withConnection:self.geoPackage.database];
    textColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:1];
    [GPKGTestUtils assertFalse:textColumn.unique];

    // Unique text
    [textColumn setUnique:YES];
    [GPKGAlterTable alterColumn:textColumn inTableName:tableName withConnection:self.geoPackage.database];
    textColumn = (GPKGUserCustomColumn *)[[self.geoPackage userCustomDaoWithTableName:tableName].table columnWithIndex:1];
    [GPKGTestUtils assertTrue:textColumn.unique];
    
}

@end
