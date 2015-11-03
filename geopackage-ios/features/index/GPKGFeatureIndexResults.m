//
//  GPKGFeatureIndexResults.m
//  geopackage-ios
//
//  Created by Brian Osborn on 10/15/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#import "GPKGFeatureIndexResults.h"
#import "GPKGFeatureRow.h"

@interface GPKGFeatureIndexResults ()

@property (nonatomic, strong) GPKGResultSet *results;

/**
 *  Used to keep the current feature row reference to preven loss of pointers within the unsafe unreatined feature row
 */
@property (nonatomic, strong) GPKGFeatureRow *featureRow;

@end

@implementation GPKGFeatureIndexResults

-(instancetype) initWithResults: (GPKGResultSet *) results{
    self = [super init];
    if(self != nil){
        self.results = results;
    }
    return self;
}

-(GPKGResultSet *) getResults{
    return self.results;
}

-(int) count{
    return self.results.count;
}

-(void) close{
    [self.results close];
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id __unsafe_unretained *)stackbuf count:(NSUInteger)len {

    // First call
    if(state->state == 0)
    {
        state->mutationsPtr = &state->extra[0];
        state->state = 1;
    }
    
    // Verify there are more results to return
    if(![self.results moveToNext]){
        return 0;
    }
    
    // Get and set the feature row
    self.featureRow = [self getFeatureRow];
    __unsafe_unretained GPKGFeatureRow * tempFeatureRow = self.featureRow;
    state->itemsPtr = &tempFeatureRow;
    
    return 1;
}

-(GPKGFeatureRow *) getFeatureRow{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
