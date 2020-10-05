//
//  GPKGMultipleFeatureIndexResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/25/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGMultipleFeatureIndexResults.h"

@interface GPKGMultipleFeatureIndexResults ()

@property (nonatomic, strong) NSMutableArray<GPKGFeatureIndexResults *> *results;
@property (nonatomic) int count;
@property (nonatomic) int index;
@property (nonatomic, strong) GPKGFeatureIndexResults * currentResults;

@end

@implementation GPKGMultipleFeatureIndexResults

-(instancetype) initWithFeatureIndexResults: (GPKGFeatureIndexResults *) results{
    return [self initWithFeatureIndexResultsArray:[[NSArray alloc] initWithObjects:results, nil]];
}

-(instancetype) initWithFeatureIndexResults1: (GPKGFeatureIndexResults *) results1 andFeatureIndexResults2: (GPKGFeatureIndexResults *) results2{
    return [self initWithFeatureIndexResultsArray:[[NSArray alloc] initWithObjects:results1, results2, nil]];
}

-(instancetype) initWithFeatureIndexResultsArray: (NSArray<GPKGFeatureIndexResults *> *) resultsArray{
    self = [super init];
    if(self != nil){
        self.results = [[NSMutableArray alloc] init];
        [self.results addObjectsFromArray:resultsArray];
        int totalCount = 0;
        for(GPKGFeatureIndexResults *results in resultsArray){
            totalCount += [results count];
        }
        self.count = totalCount;
        self.index = -1;
    }
    return self;
}

-(int) count{
    return _count;
}

-(BOOL) moveToNext{
    BOOL hasNext = NO;
    
    if(self.currentResults != nil){
        hasNext = [self.currentResults moveToNext];
    }
    
    if(!hasNext){
        
        while(!hasNext && ++self.index < self.results.count){
            
            // Get the next feature index results
            self.currentResults = [self.results objectAtIndex:self.index];
            hasNext = [self.currentResults moveToNext];
            
        }
    }
    
    return hasNext;
}

-(GPKGFeatureRow *) featureRow{
    GPKGFeatureRow *row = nil;
    if(self.currentResults != nil){
        row = [self.currentResults featureRow];
    }
    return row;
}

-(NSNumber *) featureId{
    NSNumber *id = nil;
    if(self.currentResults != nil){
        id = [self.currentResults featureId];
    }
    return id;
}

-(void) close{
    for(GPKGFeatureIndexResults *result in self.results){
        [result close];
    }
}

@end
