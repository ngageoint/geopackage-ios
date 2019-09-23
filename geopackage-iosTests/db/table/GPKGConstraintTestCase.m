//
//  GPKGConstraintTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 9/19/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraintTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGUtils.h"
#import "GPKGGeoPackageTableCreator.h"
#import "GPKGConstraintTestResult.h"
#import "GPKGConstraintParser.h"

@implementation GPKGConstraintTestCase

/**
 * Test parsing constraints in the GeoPackage database tables
 */
-(void) testTables{
    
    [self testSQLTable:GPKG_SRS_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQLTable:GPKG_CON_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:1 andNames:[NSArray arrayWithObject:@"fk_gc_r_srs_id"]];
    [self testSQLTable:GPKG_GC_TABLE_NAME withPrimaryKey:1 andUnique:1 andCheck:0 andForeignKey:2 andNames:[NSArray arrayWithObjects:@"pk_geom_cols", @"uk_gc_table_name", @"fk_gc_tn", @"fk_gc_srs", nil]];
    [self testSQLTable:GPKG_TMS_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:2 andNames:[NSArray arrayWithObjects:@"fk_gtms_table_name", @"fk_gtms_srs", nil]];
    [self testSQLTable:GPKG_TM_TABLE_NAME withPrimaryKey:1 andUnique:0 andCheck:0 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"pk_ttm", @"fk_tmm_table_name", nil]];
    [self testSQLTable:GPKG_DC_TABLE_NAME withPrimaryKey:1 andUnique:1 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObjects:@"pk_gdc", @"gdc_tn", nil]];
    [self testSQLTable:GPKG_DCC_TABLE_NAME withPrimaryKey:0 andUnique:1 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"gdcc_ntv"]];
    [self testSQLTable:GPKG_M_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"m_pk"]];
    [self testSQLTable:GPKG_MR_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:2 andNames:[NSArray arrayWithObjects:@"crmr_mfi_fk", @"crmr_mpi_fk", nil]];
    [self testSQLTable:GPKG_EX_TABLE_NAME withPrimaryKey:0 andUnique:1 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"ge_tce"]];
    [self testSQLTable:GPKG_CDGC_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:1 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"fk_g2dgtct_name", [NSNull null], nil]];
    [self testSQLTable:GPKG_CDGT_TABLE_NAME withPrimaryKey:0 andUnique:1 andCheck:0 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"fk_g2dgtat_name", [NSNull null], nil]];
    [self testSQLTable:GPKG_ER_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQLTable:GPKG_TI_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQLTable:GPKG_GI_TABLE_NAME withPrimaryKey:1 andUnique:0 andCheck:0 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"pk_ngi", @"fk_ngi_nti_tn", nil]];
    [self testSQLTable:GPKG_FTL_TABLE_NAME withPrimaryKey:1 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"pk_nftl"]];
    [self testSQLTable:GPKG_TS_TABLE_NAME withPrimaryKey:0 andUnique:0 andCheck:1 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"fk_nts_gtms_tn", [NSNull null], nil]];
    [self testSQLTable:GPKG_CI_TABLE_NAME withPrimaryKey:0 andUnique:1 andCheck:0 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"uk_nci_table_name", @"fk_nci_gc_tn", nil]];
    
}

/**
 * Test parsing constraints in the table SQL
 */
-(void) testSql{
    
    [self testSQL:nil withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQL:@"" withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@",
                   @"CREATE TABLE table_name (\n"
                   , @" id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\n"
                   , @" column_name INTEGER NOT NULL UNIQUE\n"
                   , @");"]
        withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                   , @" column_name INTEGER NOT NULL UNIQUE"
                   , @");"]
        withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray array]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@",
                   @"CREATE TABLE table_name (\n"
                   , @" id INTEGER CONSTRAINT my_pk PRIMARY KEY AUTOINCREMENT CONSTRAINT my_not_null NOT NULL,\n"
                   , @" column_name INTEGER NOT NULL CONSTRAINT my_unique UNIQUE\n"
                   , @");"]
        withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObjects:@"my_pk", @"my_not_null", @"my_unique", nil]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" id INTEGER constraint \"my pk\" PRIMARY \nKEY    AUTOINCREMENT \tCONSTRAINT\n\n my_not_null\n NOT\t NULL,"
                   , @"\ncolumn_name\nINTEGER\nNOT\nNULL\nCONSTRAINT\n\"my unique\"\nUNIQUE"
                   , @");"]
        withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObjects:@"my pk", @"my_not_null", @"my_unique", nil]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name (\n"
                   , @" column1 TEXT NOT NULL,\n"
                   , @" column2 INTEGER NOT NULL UNIQUE,\n"
                   , @" CONSTRAINT pk_name PRIMARY KEY (column1, column2)\n"
                   , @");"]
        withPrimaryKey:1 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"pk_name"]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT NOT NULL,"
                   , @" column2 INTEGER NOT NULL UNIQUE,"
                   , @" CONSTRAINT    pk_name   PRIMARY KEY (column1, column2)"
                   , @");"]
        withPrimaryKey:1 andUnique:0 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"pk_name"]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name (\n"
                   , @" column1 TEXT NOT NULL,\n"
                   , @" column2 INTEGER NOT NULL,\n"
                   , @" CONSTRAINT uk_name UNIQUE (column1, column2)\n"
                   , @");"]
        withPrimaryKey:0 andUnique:1 andCheck:0 andForeignKey:0 andNames:[NSArray arrayWithObject:@"uk_name"]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT NOT NULL,"
                   , @" column2 INTEGER NOT NULL,"
                   , @" UNIQUE (column1, column2)"
                   , @");"]
        withPrimaryKey:0 andUnique:1 andCheck:0 andForeignKey:0 andNames:[self createNames:1]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT NOT NULL,"
                   , @" column2 INTEGER NOT NULL,"
                   , @" CONSTRAINT c_name CHECK (column1 in ('value1','value2'))"
                   , @");"]
        withPrimaryKey:0 andUnique:0 andCheck:1 andForeignKey:0 andNames:[NSArray arrayWithObject:@"c_name"]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE   TABLE    table_name    ("
                   , @"   column1 TEXT NOT NULL , "
                   , @" column2 INTEGER NOT NULL ,"
                   , @"\tCHECK ( column1 in ( 'value1' , 'value2'  )   )  "
                   , @")"]
        withPrimaryKey:0 andUnique:0 andCheck:1 andForeignKey:0 andNames:[self createNames:1]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT NOT NULL,"
                   , @" column2 INTEGER NOT NULL,"
                   , @" CONSTRAINT fk_name FOREIGN KEY (column2) REFERENCES table_name2(column3)"
                   , @")"]
        withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:1 andNames:[NSArray arrayWithObject:@"fk_name"]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT NOT NULL,"
                   , @" column2 INTEGER NOT NULL,"
                   , @" FOREIGN       KEY (column2) REFERENCES table_name2(column3)"
                   , @")"]
        withPrimaryKey:0 andUnique:0 andCheck:0 andForeignKey:1 andNames:[self createNames:1]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT,"
                   , @" column2 INTEGER,"
                   , @" CONSTRAINT pk_name PRIMARY KEY (column1, column2),"
                   , @" CONSTRAINT uk_name UNIQUE (column1, column2),"
                   , @" CONSTRAINT c_name CHECK (column1 in ('value1','value2')),"
                   , @" CONSTRAINT fk_name FOREIGN KEY (column2) REFERENCES table_name2(column3)"
                   , @")"]
        withPrimaryKey:1 andUnique:1 andCheck:1 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"pk_name", @"uk_name", @"c_name", @"fk_name", nil]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT,"
                   , @" column2 INTEGER,"
                   , @" CONSTRAINT \"pk name\" PRIMARY KEY (column1, column2),"
                   , @" UNIQUE (column1, column2),"
                   , @" CONSTRAINT \"c_name\" CHECK (column1 in ('value1','value2')),"
                   , @" CONSTRAINT fk_name FOREIGN KEY (column2) REFERENCES table_name2(column3)"
                   , @")"]
        withPrimaryKey:1 andUnique:1 andCheck:1 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"pk name", [NSNull null], @"c_name", @"fk_name", nil]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                   @"CREATE TABLE table_name ("
                   , @" column1 TEXT,"
                   , @" column2 INTEGER,"
                   , @" PRIMARY KEY (column1, column2),"
                   , @" UNIQUE (column1, column2),"
                   , @" CHECK (column1 in ('value1','value2')),"
                   , @" FOREIGN KEY (column2) REFERENCES table_name2(column3)"
                   , @")"]
        withPrimaryKey:1 andUnique:1 andCheck:1 andForeignKey:1 andNames:[self createNames:4]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                   @"create table table_name ("
                   , @" column1 TEXT,"
                   , @" column2 INTEGER,"
                   , @" constraint pk_name primary key (column1, column2),"
                   , @" constraint uk_name unique (column1, column2),"
                   , @" constraint c_name check (column1 in ('value1','value2')),"
                   , @" constraint fk_name foreign key (column2) references table_name2(column3)"
                   , @")"]
        withPrimaryKey:1 andUnique:1 andCheck:1 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"pk_name", @"uk_name", @"c_name", @"fk_name", nil]];
    [self testSQL:[NSString stringWithFormat:@"%@%@%@%@%@%@%@%@",
                   @"create table table_name ("
                   , @" column1 TEXT CONSTRAINT col1_not_null NOT NULL CONSTRAINT col1_unique UNIQUE,"
                   , @" column2 INTEGER CONSTRAINT col2_check CHECK(column2 > 0),"
                   , @" constraint pk_name primary key (column1, column2),"
                   , @" constraint uk_name unique (column1, column2),"
                   , @" constraint c_name check (column1 in ('value1','value2')),"
                   , @" constraint fk_name foreign key (column2) references table_name2(column3)"
                   , @")"]
        withPrimaryKey:1 andUnique:1 andCheck:1 andForeignKey:1 andNames:[NSArray arrayWithObjects:@"pk_name", @"uk_name", @"c_name", @"fk_name", @"col1_not_null", @"col1_unique", @"col2_check", nil]];

}

/**
 * Create a list of null names
 *
 * @param count
 *            number of names
 * @return names
 */
-(NSMutableArray<NSString *> *) createNames: (int) count{
    NSMutableArray<NSString *> *names = [[NSMutableArray alloc] init];
    for(int i = 0; i < count; i++){
        [GPKGUtils addObject:nil toArray:names];
    }
    return names;
}

/**
 * Test the database script for constraint parsing
 *
 * @param tableName
 *            database table name
 * @param primaryKey
 *            expected primary key count
 * @param unique
 *            expected unique count
 * @param check
 *            expected check count
 * @param foreignKey
 *            expected foreign key count
 * @param names
 *            expected constraint names
 */
-(void) testSQLTable: (NSString *) tableName withPrimaryKey: (int) primaryKey andUnique: (int) unique andCheck: (int) check andForeignKey: (int) foreignKey andNames: (NSArray<NSString *> *) names{
    
    int count = 0;
    int primaryKeyCount = 0;
    int uniqueCount = 0;
    int checkCount = 0;
    int foreignKeyCount = 0;
    
    NSArray<NSString *> *statements = [GPKGGeoPackageTableCreator readSQLScript:tableName];
    for (NSString *sql in statements) {
        
        GPKGConstraintTestResult *constraintResult = [self testConstraintWithSql:sql andNames:names];
        
        count += [constraintResult count];
        primaryKeyCount += constraintResult.primaryKeyCount;
        uniqueCount += constraintResult.uniqueCount;
        checkCount += constraintResult.checkCount;
        foreignKeyCount += constraintResult.foreignKeyCount;
    }
    
    [GPKGTestUtils assertEqualIntWithValue:primaryKey + unique + check + foreignKey andValue2:count];
    [GPKGTestUtils assertEqualIntWithValue:primaryKey andValue2:primaryKeyCount];
    [GPKGTestUtils assertEqualIntWithValue:unique andValue2:uniqueCount];
    [GPKGTestUtils assertEqualIntWithValue:check andValue2:checkCount];
    [GPKGTestUtils assertEqualIntWithValue:foreignKey andValue2:foreignKeyCount];
    
}

/**
 * Test the database script for constraint parsing
 *
 * @param sql
 *            table sql
 * @param primaryKey
 *            expected primary key count
 * @param unique
 *            expected unique count
 * @param check
 *            expected check count
 * @param foreignKey
 *            expected foreign key count
 * @param names
 *            expected constraint names, table names (null or not) followed
 *            by columns (non null)
 */
-(void) testSQL: (NSString *) sql withPrimaryKey: (int) primaryKey andUnique: (int) unique andCheck: (int) check andForeignKey: (int) foreignKey andNames: (NSArray<NSString *> *) names{
    
    GPKGConstraintTestResult *constraintResult = [self testConstraintWithSql:sql andNames:names];
    
    [GPKGTestUtils assertEqualIntWithValue:primaryKey + unique + check + foreignKey andValue2:[constraintResult count]];
    [GPKGTestUtils assertEqualIntWithValue:primaryKey andValue2:constraintResult.primaryKeyCount];
    [GPKGTestUtils assertEqualIntWithValue:unique andValue2:constraintResult.uniqueCount];
    [GPKGTestUtils assertEqualIntWithValue:check andValue2:constraintResult.checkCount];
    [GPKGTestUtils assertEqualIntWithValue:foreignKey andValue2:constraintResult.foreignKeyCount];

}

/**
 * Test parsing the table SQL for constraints
 *
 * @param sql
 *            table SQL
 * @param names
 *            expected constraint names, table names (null or not) followed
 *            by columns (non null)
 * @return constraint test results
 */
-(GPKGConstraintTestResult *) testConstraintWithSql: (NSString *) sql andNames: (NSArray<NSString *> *) names{
    
    int primaryKeyCount = 0;
    int uniqueCount = 0;
    int checkCount = 0;
    int foreignKeyCount = 0;
    
    GPKGTableConstraints *constraints = [GPKGConstraintParser tableConstraintsForSQL:sql];
    for (int i = 0; i < [constraints numTableConstraints]; i++) {
        
        GPKGConstraint *constraint = [constraints tableConstraintAtIndex:i];
        NSString *name = [GPKGUtils objectAtIndex:i inArray:names];
        
        [self testConstraint:constraint withName:name andType:constraint.type];
        
        switch (constraint.type) {
            case GPKG_CT_PRIMARY_KEY:
                primaryKeyCount++;
                break;
            case GPKG_CT_UNIQUE:
                uniqueCount++;
                break;
            case GPKG_CT_CHECK:
                checkCount++;
                break;
            case GPKG_CT_FOREIGN_KEY:
                foreignKeyCount++;
                break;
            default:
                [GPKGTestUtils fail:[NSString stringWithFormat:@"Unexpected table constraint type: %@", [GPKGConstraintTypes name:constraint.type]]];
        }
    }
    
    int nameIndex = [constraints numTableConstraints];
    
    for (NSString *columnName in [constraints columnsWithConstraints]) {
        for (int i = 0; i < [constraints numConstraintsForColumn:columnName]; i++){
            
            GPKGConstraint *constraint = [constraints columnConstraintForColumn:columnName atIndex:i];
            
            NSString *name = nil;
            if(constraint.name != nil){
                name = [GPKGUtils objectAtIndex:nameIndex++ inArray:names];
            }
            
            [self testConstraint:constraint withName:name andType:constraint.type];
        }
    }
    
    return [[GPKGConstraintTestResult alloc] initWithTableConstraints:constraints andPrimaryKeyCount:primaryKeyCount andUniqueCount:uniqueCount andCheckCount:checkCount andForeignKeyCount:foreignKeyCount];
}

/**
 * Test the constraint
 *
 * @param constraint
 *            constraint
 * @param name
 *            expected name
 * @param type
 *            constraint type
 */
-(void) testConstraint: (GPKGConstraint *) constraint withName: (NSString *) name andType: (enum GPKGConstraintType) type{
    [self testConstraintHelper:constraint withName:name andType:type];
    NSString *constraintSql = [constraint buildSql];
    [self testConstraintHelper:[GPKGConstraintParser constraintForSQL:constraintSql] withName:name andType:type];
}

/**
 * Test the constraint
 *
 * @param constraint
 *            constraint
 * @param name
 *            expected name
 * @param type
 *            constraint type
 */
-(void) testConstraintHelper: (GPKGConstraint *) constraint withName: (NSString *) name andType: (enum GPKGConstraintType) type{
    [GPKGTestUtils assertNotNil:constraint];
    NSString *constraintSql = [constraint buildSql];
    [GPKGTestUtils assertEqualIntWithValue:type andValue2:constraint.type];
    [GPKGTestUtils assertTrue:[GPKGConstraintParser isSQL:constraintSql type:type]];
    [GPKGTestUtils assertEqualIntWithValue:type andValue2:[GPKGConstraintParser typeForSQL:constraintSql]];
    [GPKGTestUtils assertEqualWithValue:name andValue2:constraint.name];
    [GPKGTestUtils assertEqualWithValue:name andValue2:[GPKGConstraintParser nameForSQL:constraintSql]];
}

@end
