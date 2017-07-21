//
//  GPKGProjectionFactoryTestCase.m
//  geopackage-ios
//
//  Created by Brian Osborn on 7/21/17.
//  Copyright © 2017 NGA. All rights reserved.
//

#import "GPKGProjectionFactoryTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGProjectionConstants.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProjectionRetriever.h"

@implementation GPKGProjectionFactoryTestCase

static NSString *authority = @"Test";
static int code = 100001;

- (void)setUp {
    [super setUp];
    [GPKGProjectionFactory clear];
    [GPKGProjectionRetriever clear];
}

- (void)tearDown {
    [super tearDown];
}

-(void) testCustomProjection{
 
    NSNumber *authorityCode = [NSNumber numberWithInt:code];
    
    GPKGProjection *projection = [GPKGProjectionFactory projectionWithAuthority:authority
                                                                        andNumberCode:authorityCode
                                                                      andParams:@"+proj=tmerc +lat_0=0 +lon_0=121 +k=1 +x_0=500000 +y_0=0 +ellps=krass +units=m +no_defs"];
    authorityCode = [NSNumber numberWithInt:[authorityCode intValue] + 1];
    [GPKGTestUtils assertNotNil:projection];
    
    @try{
        [GPKGProjectionFactory projectionWithAuthority:authority
                            andNumberCode:authorityCode
                            andParams:@"+proj=tmerc +lat_0=0 +lon_0=121 +k=1 +x_0=500000 +y_0=0 +ellps=krass +units=m +no_defs +invalid"];
        [GPKGTestUtils fail:@"Invalid projection did not fail"];
    } @catch (NSException *exception) {
        // pass
    }
    authorityCode = [NSNumber numberWithInt:[authorityCode intValue] + 1];
    
    @try {
        [GPKGProjectionFactory projectionWithEpsg:authorityCode];
        [GPKGTestUtils fail:@"Invalid projection did not fail"];
    } @catch (NSException *exception) {
        // pass
    }
}

-(void) testAddingProjectionToAuthority{
    
    NSNumber *authorityCode = [NSNumber numberWithInt:code];
    
    @try {
        [GPKGProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_NONE andNumberCode:authorityCode];
        [GPKGTestUtils fail:@"Missing projection did not fail"];
    } @catch (NSException *exception) {
        // pass
    }
    
    [GPKGProjectionRetriever setProjection:@"+proj=tmerc +lat_0=0 +lon_0=121 +k=1 +x_0=500000 +y_0=0 +ellps=krass +units=m +no_defs"
                              forAuthority:PROJ_AUTHORITY_NONE andNumberCode:authorityCode];
    
    GPKGProjection *projection = [GPKGProjectionFactory projectionWithAuthority:PROJ_AUTHORITY_NONE andNumberCode:authorityCode];
    [GPKGTestUtils assertNotNil:projection];
    
}

-(void) testAddingAuthorityProjections{
    
    // Make sure 4 projections do not exist
    for (int i = code; i < code + 4; i++) {
        @try {
            [GPKGProjectionFactory projectionWithAuthority:authority andNumberCode:[NSNumber numberWithInt:i]];
            [GPKGTestUtils fail:@"Missing projection did not fail"];
        } @catch (NSException *exception) {
            // pass
        }
    }
    
    // Add 3 custom projections to the new authority
    NSMutableDictionary *properties = [[NSMutableDictionary alloc] init];
    [properties setObject:@"+proj=tmerc +lat_0=0 +lon_0=121 +k=1 +x_0=500000 +y_0=0 +ellps=krass +units=m +no_defs"
                   forKey:[[NSNumber numberWithInt:code] stringValue]];
    [properties setObject:@"+proj=longlat +datum=WGS84 +no_defs"
                   forKey:[[NSNumber numberWithInt:code + 1] stringValue]];
    [properties setObject:@"+proj=merc +a=6378137 +b=6378137 +lat_ts=0.0 +lon_0=0.0 +x_0=0.0 +y_0=0 +k=1.0 +units=m +nadgrids=@null +wktext  +no_defs"
                   forKey:[[NSNumber numberWithInt:code + 2] stringValue]];
    [GPKGProjectionRetriever setProjections:properties forAuthority:authority];
    
    // Verify first 3 projections exist, last still does not
    for (int i = code; i < code + 4; i++) {
        
        if (i < code + 3) {
            GPKGProjection *projection = [GPKGProjectionFactory projectionWithAuthority:authority andNumberCode:[NSNumber numberWithInt:i]];
            [GPKGTestUtils assertNotNil:projection];
        } else {
            @try {
                [GPKGProjectionFactory projectionWithAuthority:authority andNumberCode:[NSNumber numberWithInt:i]];
                [GPKGTestUtils fail:@"Missing projection did not fail"];
            } @catch (NSException *exception) {
                // pass
            }
        }
    }
    
    // Clear authority code from retriever but not from factory cache
    [GPKGProjectionRetriever clearAuthority:authority andNumberCode:[NSNumber numberWithInt:code]];
    GPKGProjection *projection = [GPKGProjectionFactory projectionWithAuthority:authority andNumberCode:[NSNumber numberWithInt:code]];
    [GPKGTestUtils assertNotNil:projection];
    
    // Clear authority code from factory cache and verify no longer exists
    [GPKGProjectionFactory clearAuthority:authority andNumberCode:[NSNumber numberWithInt:code]];
    @try {
        [GPKGProjectionFactory projectionWithAuthority:authority andNumberCode:[NSNumber numberWithInt:code]];
        [GPKGTestUtils fail:@"Missing projection did not fail"];
    } @catch (NSException *exception) {
        // pass
    }
    
    // Set projection back into the retriever and verify factory creates it
    [GPKGProjectionRetriever setProjection:@"+proj=longlat +datum=WGS84 +no_defs"
                              forAuthority:authority andNumberCode:[NSNumber numberWithInt:code]];
    projection = [GPKGProjectionFactory projectionWithAuthority:authority andNumberCode:[NSNumber numberWithInt:code]];
    [GPKGTestUtils assertNotNil:projection];
}

@end
