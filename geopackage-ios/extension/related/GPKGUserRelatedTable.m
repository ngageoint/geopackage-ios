//
//  GPKGUserRelatedTable.m
//  geopackage-ios
//
//  Created by Brian Osborn on 6/14/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGUserRelatedTable.h"

@interface GPKGUserRelatedTable ()

@property (nonatomic, strong) NSString *relationName;
@property (nonatomic, strong) NSString *dataType;

@end

@implementation GPKGUserRelatedTable

-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andDataType: (NSString *) dataType andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [self initWithTable:tableName andRelation:relationName andDataType:dataType andColumns:columns andRequiredColumns:nil];
}

-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andDataType: (NSString *) dataType andColumns: (NSArray<GPKGUserCustomColumn *> *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns{
    self = [super initWithTable:tableName andColumns:columns andRequiredColumns:requiredColumns];
    if(self != nil){
        self.relationName = relationName;
        self.dataType = dataType;
    }
    return self;
}

-(instancetype) initWithRelation: (NSString *) relationName andDataType: (NSString *) dataType andCustomTable: (GPKGUserCustomTable *) userCustomTable{
    self = [super initWithCustomTable:userCustomTable];
    if(self != nil){
        self.relationName = relationName;
        self.dataType = dataType;
    }
    return self;
}

-(NSString *) relationName{
    return _relationName;
}

-(NSString *) dataType{
    return _dataType;
}

-(void) validateContents: (GPKGContents *) contents{
    // Verify the Contents have a relation name data type
    NSString *contentsDataType = contents.dataType;
    if (contentsDataType == nil || ![contentsDataType isEqualToString:self.dataType]) {
        [NSException raise:@"Relation Data Type" format:@"The Contents of a User Related Table must have a data type of %@", self.dataType];
    }
}

-(id) mutableCopyWithZone: (NSZone *) zone{
    GPKGUserRelatedTable *userRelatedTable = [super mutableCopyWithZone:zone];
    userRelatedTable.relationName = _relationName;
    userRelatedTable.dataType = _dataType;
    return userRelatedTable;
}

@end
