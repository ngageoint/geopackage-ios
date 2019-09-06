//
//  GPKGTableInfo.m
//  geopackage-ios
//
//  Created by Brian Osborn on 8/23/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGTableInfo.h"
#import "SFGeometryTypes.h"
#import "GPKGSqlUtils.h"

NSString * const GPKG_TI_CID = @"cid";
int const GPKG_TI_CID_INDEX = 0;
NSString * const GPKG_TI_NAME = @"name";
int const GPKG_TI_NAME_INDEX = 1;
NSString * const GPKG_TI_TYPE = @"type";
int const GPKG_TI_TYPE_INDEX = 2;
NSString * const GPKG_TI_NOT_NULL = @"notnull";
int const GPKG_TI_NOT_NULL_INDEX = 3;
NSString * const GPKG_TI_DFLT_VALUE = @"dflt_value";
int const GPKG_TI_DFLT_VALUE_INDEX = 4;
NSString * const GPKG_TI_PK = @"pk";
int const GPKG_TI_PK_INDEX = 5;
NSString * const GPKG_TI_DEFAULT_NULL = @"NULL";

@interface GPKGTableInfo()

/**
 * Table name
 */
@property (nonatomic, strong) NSString *tableName;

/**
 * Table columns
 */
@property (nonatomic, strong) NSMutableArray<GPKGTableColumn *> *columns;

/**
 * Column name to column mapping
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, GPKGTableColumn *> *namesToColumns;

/**
 * Primary key column names
 */
@property (nonatomic, strong) NSMutableArray<GPKGTableColumn *> *primaryKeys;

@end

@implementation GPKGTableInfo

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param columns
 *            table columns
 */
-(instancetype) initWithTable: (NSString *) tableName andColumns: (NSArray<GPKGTableColumn *> *) columns{
    self = [super self];
    if(self != nil){
        self.tableName = tableName;
        self.columns = [NSMutableArray arrayWithArray:columns];
        self.namesToColumns = [[NSMutableDictionary alloc] init];
        self.primaryKeys = [[NSMutableArray alloc] init];
        for(GPKGTableColumn *column in columns){
            [self.namesToColumns setObject:column forKey:[column name]];
            if([column primaryKey]){
                [_primaryKeys addObject:column];
            }
        }
    }
    return self;
}

-(NSString *) tableName{
    return _tableName;
}

-(int) numColumns{
    return (int) self.columns.count;
}

-(NSArray<GPKGTableColumn *> *) columns{
    return _columns;
}

-(GPKGTableColumn *) columnAtIndex: (int) index{
    if (index < 0 || index >= self.columns.count) {
        [NSException raise:@"Index Out Of Bounds" format:@"Column index: %d, not within range 0 to %d", index, [self numColumns] - 1];
    }
    return [self.columns objectAtIndex:index];
}

-(BOOL) hasColumn: (NSString *) name{
    return [self column:name] != nil;
}

-(GPKGTableColumn *) column: (NSString *) name{
    return [self.namesToColumns objectForKey:name];
}

-(BOOL) hasPrimaryKey{
    return self.primaryKeys.count > 0;
}

-(NSArray<GPKGTableColumn *> *) primaryKeys{
    return _primaryKeys;
}

-(GPKGTableColumn *) primaryKey{
    GPKGTableColumn *pk = nil;
    if ([self hasPrimaryKey]) {
        pk = [self.primaryKeys objectAtIndex:0];
    }
    return pk;
}

+(GPKGTableInfo *) infoWithConnection: (GPKGConnection *) db andTable: (NSString *) tableName{
    
    NSString *sql = [NSString stringWithFormat:@"PRAGMA table_info(%@)", [GPKGSqlUtils quoteWrapName:tableName]];
    
    NSArray<NSArray<NSObject *> *> *results = [db queryResultsWithSql:sql andArgs:nil];
    
    NSMutableArray<GPKGTableColumn *> *tableColumns = [[NSMutableArray alloc] init];
    
    for (NSArray<NSObject *> *column : results) {
        
        int index = [((NSNumber *)[column objectAtIndex:GPKG_TI_CID_INDEX]) intValue];
        NSString *name = (NSString *)[column objectAtIndex:GPKG_TI_NAME_INDEX];
        NSString *type = (NSString *)[column objectAtIndex:GPKG_TI_TYPE_INDEX];
        BOOL notNull = [((NSNumber *)[column objectAtIndex:GPKG_TI_NOT_NULL_INDEX]) intValue] == 1;
        NSString *defaultValueString = (NSString *)[column objectAtIndex:GPKG_TI_DFLT_VALUE_INDEX];
        BOOL primaryKey = [((NSNumber *)[column objectAtIndex:GPKG_TI_PK_INDEX]) intValue] == 1;

        // If the type has a max limit on it, pull it off
        NSNumber *max = nil;
        if (type != nil && [type hasSuffix:@")"]){
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
        
        enum GPKGDataType dataType = [self dataType:type];
        NSObject *defaultValue = [self defaultValue:defaultValueString withDataType:dataType];
        
        GPKGTableColumn *tableColumn = [[GPKGTableColumn alloc] initWithIndex:index andName:name andType:type andDataType:dataType andMax:max andNotNull:notNull andDefaultValueString:defaultValueString andDefaultValue:defaultValue andPrimaryKey:primaryKey];
        [tableColumns addObject:tableColumn];
    }
    
    GPKGTableInfo *tableInfo = nil;
    if(tableColumns.count > 0){
        tableInfo = [[GPKGTableInfo alloc] initWithTable:tableName andColumns:tableColumns];
    }
    
    return tableInfo;
}

+(enum GPKGDataType) dataType: (NSString *) type{
    
    enum GPKGDataType dataType = [GPKGDataTypes fromName:type];
    
    if ((int)dataType < 0) {
        
        // Check if a geometry and set as a blob
        if([SFGeometryTypes fromName:type] != SF_NONE){
            dataType = GPKG_DT_BLOB;
        }
        
    }
    return dataType;
}

+(NSObject *) defaultValue: (NSString *) defaultValue withType: (NSString *) type{
    return [self defaultValue:defaultValue withDataType:[self dataType:type]];
}

+(NSObject *) defaultValue: (NSString *) defaultValue withDataType: (enum GPKGDataType) type{
    return nil; // TODO
    /*
    Object value = defaultValue;
    
    if (defaultValue != null && type != null
        && !defaultValue.equalsIgnoreCase(DEFAULT_NULL)) {
        
        switch (type) {
            case TEXT:
                break;
            case DATE:
            case DATETIME:
                if (!DateConverter.isFunction(defaultValue)) {
                    DateConverter converter = DateConverter.converter(type);
                    try {
                        value = converter.dateValue(defaultValue);
                    } catch (Exception e) {
                        logger.log(
                                   Level.WARNING, "Invalid " + type + " format: "
                                   + defaultValue + ", String value used",
                                   e);
                    }
                }
                break;
            case BOOLEAN:
                value = Integer.parseInt(defaultValue) == 0 ? Boolean.FALSE
                : Boolean.TRUE;
                break;
            case TINYINT:
                value = Byte.parseByte(defaultValue);
                break;
            case SMALLINT:
                value = Short.parseShort(defaultValue);
                break;
            case MEDIUMINT:
                value = Integer.parseInt(defaultValue);
                break;
            case INT:
            case INTEGER:
                value = Long.parseLong(defaultValue);
                break;
            case FLOAT:
                value = Float.parseFloat(defaultValue);
                break;
            case DOUBLE:
            case REAL:
                value = Double.parseDouble(defaultValue);
                break;
            case BLOB:
                value = defaultValue.getBytes();
                break;
            default:
                throw new GeoPackageException("Unsupported Data Type " + type);
        }
        
    }
    
    return value;
     */
}

@end
