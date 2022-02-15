//
//  GPKGPaginationTestCase.m
//  geopackage-iosTests
//
//  Created by Brian Osborn on 2/15/22.
//  Copyright © 2022 NGA. All rights reserved.
//

#import "GPKGPaginationTestCase.h"
#import "GPKGTestUtils.h"
#import "GPKGPagination.h"

@implementation GPKGPaginationTestCase

/**
 * Test pagination find
 */
-(void) testFind{

    [self testFindWithSQL:@"SELECT... LIMIT 5" andLimit:5];
    [self testFindWithSQL:@"SELECT... LIMIT 10" andLimit:10];
    [self testFindWithSQL:@"SELECT... LIMIT     30" andLimit:30];
    [self testFindWithSQL:@"SELECT... LIMIT     40        " andLimit:40];
    [self testFindWithSQL:@"SELECT... LIMIT 15,10" andLimit:10 andOffsetInt:15];
    [self testFindWithSQL:@"SELECT... LIMIT 7 , 5 " andLimit:5 andOffsetInt:7];
    [self testFindWithSQL:@"SELECT... LIMIT   100    ,     50      " andLimit:50 andOffsetInt:100];
    [self testFindWithSQL:@"SELECT... LIMIT 10 OFFSET 15" andLimit:10 andOffsetInt:15];
    [self testFindWithSQL:@"SELECT... LIMIT 5 OFFSET 7 " andLimit:5 andOffsetInt:7];
    [self testFindWithSQL:@"SELECT... LIMIT   50    OFFSET     100      " andLimit:50 andOffsetInt:100];
    [self testFindWithSQL:@"SELECT... LIMIT -15" andLimit:-15];
    [self testFindWithSQL:@"SELECT... LIMIT -15,-10" andLimit:-10 andOffsetInt:0];
    [self testFindWithSQL:@"SELECT... LIMIT -15 , -10" andLimit:-10 andOffsetInt:0];
    [self testFindWithSQL:@"SELECT... LIMIT -10 OFFSET -15" andLimit:-10 andOffsetInt:0];

}

/**
 * Test pagination replace
 */
-(void) testReplace{

    [self testReplaceWithSQL:@"SELECT... LIMIT 5" andExpected:@"SELECT... LIMIT 5 OFFSET 5"];
    [self testReplaceWithSQL:@"SELECT... LIMIT 15,10" andExpected:@"SELECT... LIMIT 10 OFFSET 25"];
    [self testReplaceWithSQL:@"SELECT... LIMIT 5 OFFSET 7" andExpected:@"SELECT... LIMIT 5 OFFSET 12"];
    [self testReplaceWithSQL:@"SELECT... LIMIT -15" andExpected:@"SELECT... LIMIT -15"];
    [self testReplaceWithSQL:@"SELECT... LIMIT -15,-10" andExpected:@"SELECT... LIMIT -10 OFFSET 0"];
    [self testReplaceWithSQL:@"SELECT... LIMIT -15,10" andExpected:@"SELECT... LIMIT 10 OFFSET 10"];

}

/**
 * Test pagination find
 *
 * @param sql
 *            SQL statement
 * @param limit
 *            limit
 */
-(void) testFindWithSQL: (NSString *) sql andLimit: (int) limit{
    [self testFindWithSQL:sql andLimit:limit andOffset:nil];
}

/**
 * Test pagination find
 *
 * @param sql
 *            SQL statement
 * @param limit
 *            limit
 * @param offset
 *            offset
 */
-(void) testFindWithSQL: (NSString *) sql andLimit: (int) limit andOffsetInt: (int) offset{
    [self testFindWithSQL:sql andLimit:limit andOffset:[NSNumber numberWithInt:offset]];
}

/**
 * Test pagination find
 *
 * @param sql
 *            SQL statement
 * @param limit
 *            limit
 * @param offset
 *            offset
 */
-(void) testFindWithSQL: (NSString *) sql andLimit: (int) limit andOffset: (NSNumber *) offset{

    GPKGPagination *pagination = [GPKGPagination findInSQL:sql];
    [GPKGTestUtils assertEqualIntWithValue:limit andValue2:pagination.limit];
    BOOL hasOffset = offset != nil;
    [GPKGTestUtils assertEqualBoolWithValue:hasOffset andValue2:[pagination hasOffset]];
    if(hasOffset){
        [GPKGTestUtils assertEqualWithValue:offset andValue2:pagination.offset];
    }else{
        [GPKGTestUtils assertNil:pagination.offset];
    }
    
    pagination = [GPKGPagination findInSQL:[sql lowercaseString]];
    [GPKGTestUtils assertEqualIntWithValue:limit andValue2:pagination.limit];
    hasOffset = offset != nil;
    [GPKGTestUtils assertEqualBoolWithValue:hasOffset andValue2:[pagination hasOffset]];
    if(hasOffset){
        [GPKGTestUtils assertEqualWithValue:offset andValue2:pagination.offset];
    }else{
        [GPKGTestUtils assertNil:pagination.offset];
    }

}

/**
 * Test pagination replace
 *
 * @param sql
 *            SQL statement
 * @param expected
 *            expected SQL
 */
-(void) testReplaceWithSQL: (NSString *) sql andExpected: (NSString *) expected{

    GPKGPagination *pagination = [GPKGPagination findInSQL:sql];
    [pagination incrementOffset];
    [GPKGTestUtils assertEqualWithValue:expected andValue2:[pagination replaceSQL:sql]];

}

@end
