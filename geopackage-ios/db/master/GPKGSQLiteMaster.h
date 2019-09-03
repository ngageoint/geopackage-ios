//
//  GPKGSQLiteMaster.h
//  geopackage-ios
//
//  Created by Brian Osborn on 8/26/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGSQLiteMasterTypes.h"
#import "GPKGSQLiteMasterColumns.h"
#import "GPKGTableConstraints.h"
#import "GPKGConnection.h"

/**
 * SQLite Master table queries (sqlite_master)
 */
@interface GPKGSQLiteMaster : NSObject

/**
 * Table Name
 */
extern NSString * const GPKG_SM_TABLE_NAME;

/**
 * Result count
 *
 * @return count
 */
-(int) count;

/**
 * Get the columns in the result
 *
 * @return columns
 */
-(NSArray<NSNumber *> *) columns;

/**
 * Get the type
 *
 * @param row
 *            row index
 * @return type
 */
-(enum GPKGSQLiteMasterType) typeAtRow: (int) row;

/**
 * Get the type string
 *
 * @param row
 *            row index
 * @return type string
 */
-(NSString *) typeStringAtRow: (int) row;

/**
 * Get the name
 *
 * @param row
 *            row index
 * @return name
 */
-(NSString *) nameAtRow: (int) row;

/**
 * Get the table name
 *
 * @param row
 *            row index
 * @return name
 */
-(NSString *) tableNameAtRow: (int) row;

/**
 * Get the rootpage
 *
 * @param row
 *            row index
 * @return name
 */
-(NSNumber *) rootpageAtRow: (int) row;

/**
 * Get the sql
 *
 * @param row
 *            row index
 * @return name
 */
-(NSString *) sqlAtRow: (int) row;

/**
 * Get the value of the column at the row index
 *
 * @param row
 *            row index
 * @param column
 *            column type
 * @return value
 */
-(NSObject *) valueAtRow: (int) row forColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Get the row at the row index
 *
 * @param row
 *            row index
 * @return row column values
 */
-(NSArray<NSObject *> *) row: (int) row;

/**
 * Get the value in the row at the column index
 *
 * @param row
 *            row
 * @param column
 *            column type
 * @return value
 */
-(NSObject *) valueInRow: (NSArray<NSObject *> *) row forColumn: (enum GPKGSQLiteMasterColumn) column;

/**
 * Get the column index of the column type
 *
 * @param column
 *            column type
 * @return column index
 */
-(int) columnIndex: (enum GPKGSQLiteMasterColumn) column;

/**
 * Get the constraints from table SQL
 *
 * @param row
 *            row index
 * @return constraints
 */
-(GPKGTableConstraints *) constraintsAtRow: (int) row;

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @return count
 */
+(int) countWithConnection: (GPKGConnection *) db;

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db) {
    return query(db, SQLiteMasterQuery.create());
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return count
 */
public static int count(GeoPackageCoreConnection db, String tableName) {
    return count(db, types(), tableName);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 String tableName) {
    return query(db, SQLiteMasterColumn.values(), types(), tableName);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryForColumns(GeoPackageCoreConnection db,
                                           Collection<SQLiteMasterColumn> columns) {
    return queryForColumns(db, columns, null);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryForColumns(GeoPackageCoreConnection db,
                                           Collection<SQLiteMasterColumn> columns, String tableName) {
    return query(db, columns.toArray(new SQLiteMasterColumn[0]), types(),
                 tableName);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @return count
 */
public static int countByType(GeoPackageCoreConnection db,
                              SQLiteMasterType type) {
    return countByType(db, type, null);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryByType(GeoPackageCoreConnection db,
                                       SQLiteMasterType type) {
    return queryByType(db, type, null);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @return count
 */
public static int countByType(GeoPackageCoreConnection db,
                              Collection<SQLiteMasterType> types) {
    return countByType(db, types, null);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryByType(GeoPackageCoreConnection db,
                                       Collection<SQLiteMasterType> types) {
    return queryByType(db, types, null);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return count
 */
public static int countByType(GeoPackageCoreConnection db,
                              SQLiteMasterType type, String tableName) {
    return count(db, type, tableName);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryByType(GeoPackageCoreConnection db,
                                       SQLiteMasterType type, String tableName) {
    return query(db, SQLiteMasterColumn.values(), type, tableName);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return count
 */
public static int countByType(GeoPackageCoreConnection db,
                              Collection<SQLiteMasterType> types, String tableName) {
    return count(db, types.toArray(new SQLiteMasterType[0]), tableName);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryByType(GeoPackageCoreConnection db,
                                       Collection<SQLiteMasterType> types, String tableName) {
    return query(db, SQLiteMasterColumn.values(),
                 types.toArray(new SQLiteMasterType[0]), tableName);
}

/**
 *
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        Collection<SQLiteMasterType> types) {
    return count(db, types, null);
}

/**
 *
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 Collection<SQLiteMasterColumn> columns, SQLiteMasterType type) {
    return query(db, columns, type, null);
}

/**
 *
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 Collection<SQLiteMasterColumn> columns,
                                 Collection<SQLiteMasterType> types) {
    return query(db, columns, types, null);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 Collection<SQLiteMasterColumn> columns, SQLiteMasterType type,
                                 String tableName) {
    return query(db, columns.toArray(new SQLiteMasterColumn[0]), type,
                 tableName);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        Collection<SQLiteMasterType> types, String tableName) {
    return count(db, types.toArray(new SQLiteMasterType[0]), tableName);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 Collection<SQLiteMasterColumn> columns,
                                 Collection<SQLiteMasterType> types, String tableName) {
    return query(db, columns.toArray(new SQLiteMasterColumn[0]),
                 types.toArray(new SQLiteMasterType[0]), tableName);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        SQLiteMasterType type) {
    return count(db, types(type));
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterType type) {
    return query(db, columns, types(type));
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return count
 */
public static int count(GeoPackageCoreConnection db, SQLiteMasterType type,
                        String tableName) {
    return count(db, types(type), tableName);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterType type,
                                 String tableName) {
    return query(db, columns, types(type), tableName);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        SQLiteMasterType[] types) {
    return count(db, types, SQLiteMasterQuery.create());
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterType[] types) {
    return query(db, columns, types, SQLiteMasterQuery.create());
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        SQLiteMasterType[] types, String tableName) {
    return count(db, types, SQLiteMasterQuery
                 .create(SQLiteMasterColumn.TBL_NAME, tableName));
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterType[] types,
                                 String tableName) {
    return query(db, columns, types, SQLiteMasterQuery
                 .create(SQLiteMasterColumn.TBL_NAME, tableName));
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param query
 *            query
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterQuery query) {
    return query(db, SQLiteMasterColumn.values(), query);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param query
 *            query
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        SQLiteMasterQuery query) {
    return count(db, types(), query);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param query
 *            query
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterQuery query) {
    return query(db, columns, types(), query);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param query
 *            query
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterType type, SQLiteMasterQuery query) {
    return query(db, SQLiteMasterColumn.values(), type, query);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param type
 *            result type
 * @param query
 *            query
 * @return count
 */
public static int count(GeoPackageCoreConnection db, SQLiteMasterType type,
                        SQLiteMasterQuery query) {
    return count(db, types(type), query);
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param type
 *            result type
 * @param query
 *            query
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterType type,
                                 SQLiteMasterQuery query) {
    return query(db, columns, types(type), query);
}

/**
 * Count the sqlite_master table
 *
 * @param db
 *            connection
 * @param types
 *            result types
 * @param query
 *            query
 * @return count
 */
public static int count(GeoPackageCoreConnection db,
                        SQLiteMasterType[] types, SQLiteMasterQuery query) {
    return query(db, null, types, query).count();
}

/**
 * Query the sqlite_master table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param types
 *            result types
 * @param query
 *            query
 * @return SQLiteMaster result
 */
public static SQLiteMaster query(GeoPackageCoreConnection db,
                                 SQLiteMasterColumn[] columns, SQLiteMasterType[] types,
                                 SQLiteMasterQuery query) {
    
    StringBuilder sql = new StringBuilder("SELECT ");
    List<String> args = new ArrayList<>();
    
    if (columns != null && columns.length > 0) {
        
        for (int i = 0; i < columns.length; i++) {
            if (i > 0) {
                sql.append(", ");
            }
            sql.append(columns[i].name().toLowerCase());
        }
        
    } else {
        sql.append("count(*)");
    }
    
    sql.append(" FROM ");
    sql.append(TABLE_NAME);
    
    boolean hasQuery = query != null && query.has();
    boolean hasTypes = types != null && types.length > 0;
    
    if (hasQuery || hasTypes) {
        
        sql.append(" WHERE ");
        
        if (hasQuery) {
            sql.append(query.buildSQL());
            args.addAll(query.getArguments());
        }
        
        if (hasTypes) {
            
            if (hasQuery) {
                sql.append(" AND");
            }
            
            sql.append(" type IN (");
            for (int i = 0; i < types.length; i++) {
                if (i > 0) {
                    sql.append(", ");
                }
                sql.append("?");
                args.add(types[i].name().toLowerCase());
            }
            sql.append(")");
        }
    }
    
    List<List<Object>> results = db.queryResults(sql.toString(),
                                                 args.toArray(new String[0]));
    
    SQLiteMaster sqliteMaster = new SQLiteMaster(results, columns);
    
    return sqliteMaster;
}

/**
 * Query the sqlite_master views on the table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryViewsOnTable(GeoPackageCoreConnection db,
                                             String tableName) {
    return queryViewsOnTable(db, SQLiteMasterColumn.values(), tableName);
}

/**
 * Query the sqlite_master views on the table
 *
 * @param db
 *            connection
 * @param columns
 *            result columns
 * @param tableName
 *            table name
 * @return SQLiteMaster result
 */
public static SQLiteMaster queryViewsOnTable(GeoPackageCoreConnection db,
                                             SQLiteMasterColumn[] columns, String tableName) {
    return query(db, columns, SQLiteMasterType.VIEW,
                 SQLiteMasterQuery.createTableViewQuery(tableName));
}

/**
 * Count the sqlite_master views on the table
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return count
 */
public static int countViewsOnTable(GeoPackageCoreConnection db,
                                    String tableName) {
    return count(db, SQLiteMasterType.VIEW,
                 SQLiteMasterQuery.createTableViewQuery(tableName));
}

/**
 * Query for the table constraints
 *
 * @param db
 *            connection
 * @param tableName
 *            table name
 * @return SQL constraints
 */
public static TableConstraints queryForConstraints(
                                                   GeoPackageCoreConnection db, String tableName) {
    TableConstraints constraints = new TableConstraints();
    SQLiteMaster tableMaster = SQLiteMaster.queryByType(db,
                                                        SQLiteMasterType.TABLE, tableName);
    for (int i = 0; i < tableMaster.count(); i++) {
        constraints.addConstraints(tableMaster.getConstraints(i));
    }
    return constraints;
}

@end
