//
//  GPKGUserCustomColumn.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserCustomColumn.h"

@implementation GPKGUserCustomColumn

+(GPKGUserCustomColumn *) createPrimaryKeyColumnWithName: (NSString *) name{
    return [self createPrimaryKeyColumnWithIndex:NO_INDEX andName:name];
}

+(GPKGUserCustomColumn *) createPrimaryKeyColumnWithIndex: (int) index
                                                  andName: (NSString *) name{
    return [[GPKGUserCustomColumn alloc] initWithIndex:index andName:name andDataType:GPKG_DT_INTEGER andMax:nil andNotNull:true andDefaultValue:nil andPrimaryKey:true];
}

+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                   andDataType: (enum GPKGDataType) type{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type];
}

+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type{
    return [self createColumnWithIndex:index andName:name andDataType:type andNotNull:NO andDefaultValue:nil];
}

+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                   andDataType: (enum GPKGDataType) type
                                    andNotNull: (BOOL) notNull{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andNotNull:notNull];
}

+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull{
    return [self createColumnWithIndex:index andName:name andDataType:type andNotNull:notNull andDefaultValue:nil];
}

+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                   andDataType: (enum GPKGDataType) type
                                    andNotNull: (BOOL) notNull
                               andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:nil andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                   andDataType: (enum GPKGDataType) type
                                        andMax: (NSNumber *) max{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andMax:max];
}

+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max{
    return [self createColumnWithIndex:index andName:name andDataType:type andMax:max andNotNull:NO andDefaultValue:nil];
}

+(GPKGUserCustomColumn *) createColumnWithName: (NSString *) name
                                   andDataType: (enum GPKGDataType) type
                                        andMax: (NSNumber *) max
                                    andNotNull: (BOOL) notNull
                               andDefaultValue: (NSObject *) defaultValue{
    return [self createColumnWithIndex:NO_INDEX andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue];
}

+(GPKGUserCustomColumn *) createColumnWithIndex: (int) index
                                        andName: (NSString *) name
                                    andDataType: (enum GPKGDataType) type
                                         andMax: (NSNumber *) max
                                     andNotNull: (BOOL) notNull
                                andDefaultValue: (NSObject *) defaultValue{
    return [[GPKGUserCustomColumn alloc] initWithIndex:index andName:name andDataType:type andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:false];
}

+(GPKGUserCustomColumn *) createColumnWithTableColumn: (GPKGTableColumn *) tableColumn{
    return [[GPKGUserCustomColumn alloc] initWithTableColumn:tableColumn];
}

/**
 *  Initialize
 *
 *  @param index        index
 *  @param name         column name
 *  @param dataType     data type
 *  @param max          max value
 *  @param notNull      not null flag
 *  @param defaultValue default value
 *  @param primaryKey   primary key flag
 *
 *  @return new user column
 */
-(instancetype) initWithIndex: (int) index
                      andName: (NSString *) name
                  andDataType: (enum GPKGDataType) dataType
                       andMax: (NSNumber *) max
                   andNotNull: (BOOL) notNull
              andDefaultValue: (NSObject *) defaultValue
                andPrimaryKey: (BOOL) primaryKey{
    self = [super initWithIndex:index andName:name andDataType:dataType andMax:max andNotNull:notNull andDefaultValue:defaultValue andPrimaryKey:primaryKey];
    return self;
}

/**
 * Initialize
 *
 * @param tableColumn
 *            table column
 */
-(instancetype) initWithTableColumn: (GPKGTableColumn *) tableColumn{
    self = [super initWithTableColumn:tableColumn];
    return self;
}

@end
