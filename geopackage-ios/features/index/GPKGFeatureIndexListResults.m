//
//  GPKGFeatureIndexListResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGFeatureIndexListResults.h"

@interface GPKGFeatureIndexListResults ()

@property (nonatomic, strong) NSMutableArray *rows;
@property (nonatomic) int rowIndex;

@end

@implementation GPKGFeatureIndexListResults

-(instancetype) init{
    self = [super init];
    if(self != nil){
        self.rows = [NSMutableArray array];
        self.rowIndex = -1;
    }
    return self;
}

-(instancetype) initWithFeatureRow: (GPKGFeatureRow *) row{
    self = [self init];
    if(self != nil){
        [self addRow:row];
    }
    return self;
}

-(instancetype) initWithFeatureRows: (NSArray<GPKGFeatureRow *> *) rows{
    self = [self init];
    if(self != nil){
        [self addRows:rows];
    }
    return self;
}

-(void) addRow: (GPKGFeatureRow *) row{
    [self.rows addObject:row];
}

-(void) addRows: (NSArray<GPKGFeatureRow *> *) rows{
    [self.rows addObjectsFromArray:rows];
}

-(int) count{
    return (int) self.rows.count;
}

-(BOOL) moveToNext{
    self.rowIndex++;
    return self.rowIndex < self.rows.count;
}

-(GPKGFeatureRow *) featureRow{
    return [self.rows objectAtIndex:self.rowIndex];
}

-(NSNumber *) featureId{
    return [[self featureRow] id];
}

@end
