//
//  GPKGDataColumnConstraintsDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGDataColumnConstraintsDao.h"
#import "GPKGDataColumnsDao.h"

@implementation GPKGDataColumnConstraintsDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = DCC_TABLE_NAME;
        self.idColumns = @[DCC_COLUMN_CONSTRAINT_NAME, DCC_COLUMN_CONSTRAINT_TYPE, DCC_COLUMN_VALUE];
        self.columns = @[DCC_COLUMN_CONSTRAINT_NAME, DCC_COLUMN_CONSTRAINT_TYPE, DCC_COLUMN_VALUE, DCC_COLUMN_MIN, DCC_COLUMN_MIN_IS_INCLUSIVE, DCC_COLUMN_MAX, DCC_COLUMN_MAX_IS_INCLUSIVE, DCC_COLUMN_DESCRIPTION];
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
            setObject.min = (NSDecimalNumber *) value;
            break;
        case 4:
            setObject.minIsInclusive = (NSNumber *) value;
            break;
        case 5:
            setObject.max = (NSDecimalNumber *) value;
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

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGDataColumnConstraints *getObject = (GPKGDataColumnConstraints*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.constraintName;
            break;
        case 1:
            value = getObject.constraintType;
            break;
        case 2:
            value = getObject.value;
            break;
        case 3:
            value = getObject.min;
            break;
        case 4:
            value = getObject.minIsInclusive;
            break;
        case 5:
            value = getObject.max;
            break;
        case 6:
            value = getObject.maxIsInclusive;
            break;
        case 7:
            value = getObject.theDescription;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    //TODO
    return nil;
}

-(int) deleteCascade: (GPKGDataColumnConstraints *) constraints{
    int count = 0;
    
    if(constraints != nil){
        
        // Check if the last remaining contraint with the constraint name is being deleted
        GPKGResultSet * remainingConstraints = [self queryByConstraintName:constraints.constraintName];
        if(remainingConstraints.count == 1){
            
            if([remainingConstraints moveToNext]){
                GPKGDataColumnConstraints * remainingConstraint = (GPKGDataColumnConstraints *) [self getObject:remainingConstraints];
                
                // Compare the name, type, and value
                if([remainingConstraint.constraintName isEqualToString: constraints.constraintName]
                   && [remainingConstraint.constraintType isEqualToString: constraints.constraintType]
                   && (remainingConstraint.value == nil ?
                       constraints.value == nil : [remainingConstraint.value isEqualToString:constraints.value])){
                    
                       // Delete Date Columns
                       GPKGDataColumnsDao * dao = [self getDataColumnsDao];
                       GPKGResultSet * dataColumnResults = [dao queryByConstraintName:constraints.constraintName];
                       while([dataColumnResults moveToNext]){
                           GPKGDataColumns * dataColumns = (GPKGDataColumns *) [dao getObject:dataColumnResults];
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

-(int) deleteCascadeWhere: (NSString *) where{
    int count = 0;
    if(where != nil){
        GPKGResultSet *results = [self queryWhere:where];
        while([results moveToNext]){
            GPKGDataColumnConstraints *dataColumnConstraints = (GPKGDataColumnConstraints *)[self getObject:results];
            count += [self deleteCascade:dataColumnConstraints];
        }
        [results close];
    }
    return count;
}

-(int) deleteByIdCascade: (NSNumber *) id{
    int count = 0;
    if(id != nil){
        GPKGDataColumnConstraints *dataColumnConstraints = (GPKGDataColumnConstraints *) [self queryForIdObject:id];
        if(dataColumnConstraints != nil){
            count = [self deleteCascade:dataColumnConstraints];
        }
    }
    return count;
}

-(int) deleteIdsCascade: (NSArray *) idCollection{
    int count = 0;
    if(idCollection != nil){
        for(NSNumber * id in idCollection){
            count += [self deleteByIdCascade:id];
        }
    }
    return count;
}

-(GPKGResultSet *) queryByConstraintName: (NSString *) constraintName{
    return [self queryForEqWithField:DCC_COLUMN_CONSTRAINT_NAME andValue:constraintName];
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

-(GPKGDataColumnsDao *) getDataColumnsDao{
    return [[GPKGDataColumnsDao alloc] initWithDatabase:self.database];
}

@end
