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

@end

@implementation GPKGUserRelatedTable

-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns{
    return [self initWithTable:tableName andRelation:relationName andColumns:columns andRequiredColumns:nil];
}

-(instancetype) initWithTable: (NSString *) tableName andRelation: (NSString *) relationName andColumns: (NSArray<GPKGUserCustomColumn *> *) columns andRequiredColumns: (NSArray<NSString *> *) requiredColumns{
    self = [super initWithTable:tableName andColumns:columns andRequiredColumns:requiredColumns];
    if(self != nil){
        self.relationName = relationName;
    }
    return self;
}

-(instancetype) initWithRelation: (NSString *) relationName andCustomTable: (GPKGUserCustomTable *) userCustomTable{
    self = [super initWithCustomTable:userCustomTable];
    if(self != nil){
        self.relationName = relationName;
    }
    return self;
}

-(NSString *) relationName{
    return _relationName;
}

-(void) setContents:(GPKGContents *)contents{
    _contents = contents;
    if(contents != nil){
        // Verify the Contents have a relation name data type
        NSString *dataType = contents.dataType;
        if (dataType == nil || ![dataType isEqualToString:self.relationName]) {
            [NSException raise:@"Relation Data Type" format:@"The Contents of a User Related Table must have a data type of %@", self.relationName];
        }
    }
}

@end
