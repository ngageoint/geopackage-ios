//
//  GPKGDataColumnConstraintsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataColumnConstraintsDao.h"
#import "GPKGDataColumnsDao.h"
#import "GPKGUtils.h"

@implementation GPKGDataColumnConstraintsDao

+(GPKGDataColumnConstraintsDao *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [self createWithDatabase:geoPackage.database];
}

+(GPKGDataColumnConstraintsDao *) createWithDatabase: (GPKGConnection *) database{
    return [[GPKGDataColumnConstraintsDao alloc] initWithDatabase:database];
}

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_DCC_TABLE_NAME;
        self.idColumns = @[GPKG_DCC_COLUMN_CONSTRAINT_NAME, GPKG_DCC_COLUMN_CONSTRAINT_TYPE, GPKG_DCC_COLUMN_VALUE];
        self.columnNames = @[GPKG_DCC_COLUMN_CONSTRAINT_NAME, GPKG_DCC_COLUMN_CONSTRAINT_TYPE, GPKG_DCC_COLUMN_VALUE, GPKG_DCC_COLUMN_MIN, GPKG_DCC_COLUMN_MIN_IS_INCLUSIVE, GPKG_DCC_COLUMN_MAX, GPKG_DCC_COLUMN_MAX_IS_INCLUSIVE, GPKG_DCC_COLUMN_DESCRIPTION];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGDataColumnConstraints alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGDataColumnConstraints *setObject = (GPKGDataColumnConstraints*) object;
    
    switch(columnIndex){
        case 0:
            setObject.constraintName = (NSString *) value;
            break;
        case 1:
            setObject.constraintType = (NSString *) value;
            break;
        case 2:
            setObject.value = (NSString *) value;
            break;
        case 3:
            setObject.min = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 4:
            setObject.minIsInclusive = (NSNumber *) value;
            break;
        case 5:
            setObject.max = [GPKGUtils decimalNumberFromNumber:(NSNumber *) value];
            break;
        case 6:
            setObject.maxIsInclusive = (NSNumber *) value;
            break;
        case 7:
            setObject.theDescription = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGDataColumnConstraints *constraints = (GPKGDataColumnConstraints*) object;
    
    switch(columnIndex){
        case 0:
            value = constraints.constraintName;
            break;
        case 1:
            value = constraints.constraintType;
            break;
        case 2:
            value = constraints.value;
            break;
        case 3:
            value = constraints.min;
            break;
        case 4:
            value = constraints.minIsInclusive;
            break;
        case 5:
            value = constraints.max;
            break;
        case 6:
            value = constraints.maxIsInclusive;
            break;
        case 7:
            value = constraints.theDescription;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(SFPProjection *) projection: (NSObject *) object{
    GPKGDataColumnConstraints *projectionObject = (GPKGDataColumnConstraints*) object;
    GPKGResultSet *dataColumnResults = [self dataColumns:projectionObject];
    GPKGDataColumnsDao *dataColumnsDao = [self dataColumnsDao];
    SFPProjection * projection = nil;
    if([dataColumnResults moveToNext]){
        GPKGDataColumns *dataColumns = (GPKGDataColumns *)[dataColumnsDao object:dataColumnResults];
        projection = [dataColumnsDao projection:dataColumns];
    }
    [dataColumnResults close];
    return projection;
}

-(int) deleteCascade: (GPKGDataColumnConstraints *) constraints{
    int count = 0;
    
    if(constraints != nil){
        
        // Check if the last remaining contraint with the constraint name is being deleted
        GPKGResultSet *remainingConstraints = [self queryByConstraintName:constraints.constraintName];
        if(remainingConstraints.count == 1){
            
            if([remainingConstraints moveToNext]){
                GPKGDataColumnConstraints * remainingConstraint = (GPKGDataColumnConstraints *) [self object:remainingConstraints];
                
                // Compare the name, type, and value
                if([remainingConstraint.constraintName isEqualToString: constraints.constraintName]
                   && [remainingConstraint.constraintType isEqualToString: constraints.constraintType]
                   && (remainingConstraint.value == nil ?
                       constraints.value == nil : [remainingConstraint.value isEqualToString:constraints.value])){
                    
                       // Delete Date Columns
                       GPKGDataColumnsDao *dao = [self dataColumnsDao];
                       GPKGResultSet *dataColumnResults = [dao queryByConstraintName:constraints.constraintName];
                       while([dataColumnResults moveToNext]){
                           GPKGDataColumns *dataColumns = (GPKGDataColumns *) [dao object:dataColumnResults];
                           [dao delete: dataColumns];
                       }
                       [dataColumnResults close];
                }
            }
        }
        [remainingConstraints close];
        
        // Delete
        count = [self delete:constraints];
    }
    
    return count;
}

-(int) deleteCascadeWithCollection: (NSArray *) constraintsCollection{
    int count = 0;
    if(constraintsCollection != nil){
        for(GPKGDataColumnConstraints *dataColumnConstraints in constraintsCollection){
            count += [self deleteCascade:dataColumnConstraints];
        }
    }
    return count;
}

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    if(where != nil){
        NSMutableArray *dataColumnConstraintsArray = [[NSMutableArray alloc] init];
        GPKGResultSet *results = [self queryWhere:where andWhereArgs:whereArgs];
        while([results moveToNext]){
            GPKGDataColumnConstraints *dataColumnConstraints = (GPKGDataColumnConstraints *)[self object:results];
            [dataColumnConstraintsArray addObject:dataColumnConstraints];
        }
        [results close];
        for(GPKGDataColumnConstraints *dataColumnConstraints in dataColumnConstraintsArray){
            count += [self deleteCascade:dataColumnConstraints];
        }
    }
    return count;
}

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName{
    return [self queryForEqWithField:GPKG_DCC_COLUMN_CONSTRAINT_NAME andValue:constraintName];
}

-(GPKGDataColumnConstraints *) queryByUniqueConstraintName: (NSString *) constraintName
                                         andConstraintType: (enum GPKGDataColumnConstraintType) constraintType
                                                  andValue: (NSString *) value{
    
    GPKGDataColumnConstraints * dataColumnConstraints = [[GPKGDataColumnConstraints alloc] init];
    dataColumnConstraints.constraintName = constraintName;
    [dataColumnConstraints setDataColumnConstraintType:constraintType];
    dataColumnConstraints.value = value;
    
    NSObject * resultObject = [self queryForSameId:dataColumnConstraints];
    
    GPKGDataColumnConstraints * result = nil;
    if(resultObject != nil){
        result = (GPKGDataColumnConstraints *) resultObject;
    }
    
    return result;
    
}

-(GPKGResultSet *) dataColumns: (GPKGDataColumnConstraints *) dataColumnConstraints{
    GPKGDataColumnsDao * dao = [self dataColumnsDao];
    GPKGResultSet *results = [dao queryByConstraintName:dataColumnConstraints.constraintName];
    return results;
}

-(GPKGDataColumnsDao *) dataColumnsDao{
    return [GPKGDataColumnsDao createWithDatabase:self.database];
}

@end
