//
//  GPKGManualFeatureQueryResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/11/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGManualFeatureQueryResults.h"

@interface GPKGManualFeatureQueryResults ()

@property (nonatomic, strong) GPKGFeatureDao *featureDao;
@property (nonatomic, strong) NSArray<NSString *> *columns;
@property (nonatomic, strong) NSArray<NSNumber *> *featureIds;
@property (nonatomic) int index;

@end

@implementation GPKGManualFeatureQueryResults

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao andIds: (NSArray<NSNumber *> *) featureIds{
    return [self initWithFeatureDao:featureDao andColumns:[featureDao columnNames] andIds:featureIds];
}

-(instancetype) initWithFeatureDao: (GPKGFeatureDao *) featureDao andColumns: (NSArray<NSString *> *) columns andIds: (NSArray<NSNumber *> *) featureIds{
    self = [super init];
    if(self != nil){
        self.featureDao = featureDao;
        self.columns = columns;
        self.featureIds = featureIds;
        self.index = -1;
    }
    return self;
}

-(GPKGFeatureDao *) featureDao{
    return _featureDao;
}

-(NSArray<NSString *> *) columns{
    return _columns;
}

-(NSArray<NSNumber *> *) featureIds{
    return _featureIds;
}

-(int) count{
    return (int) self.featureIds.count;
}

-(BOOL) moveToNext{
    self.index++;
    return self.index < self.featureIds.count;
}

-(GPKGFeatureRow *) featureRow{
    return (GPKGFeatureRow *)[self.featureDao queryWithColumns:self.columns forIdObject:[self featureId]];
}

-(NSNumber *) featureId{
    return [self.featureIds objectAtIndex:self.index];
}

-(void) close{

}

@end
