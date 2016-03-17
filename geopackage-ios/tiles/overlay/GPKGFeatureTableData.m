//
//  GPKGFeatureTableData.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import "GPKGFeatureTableData.h"

@interface GPKGFeatureTableData ()

@property (nonatomic, strong) NSString *name;
@property (nonatomic) int count;
@property (nonatomic, strong) NSArray<GPKGFeatureRowData *> *rows;

@end

@implementation GPKGFeatureTableData

-(instancetype) initWithName: (NSString *) name andCount: (int) count{
    return [self initWithName:name andCount:count andRows:nil];
}

-(instancetype) initWithName: (NSString *) name andCount: (int) count andRows: (NSArray<GPKGFeatureRowData *> *) rows{
    self = [super init];
    if(self){
        self.name = name;
        self.count = count;
        self.rows = rows;
    }
    return self;
}

-(NSString *) getName{
    return self.name;
}

-(int) getCount{
    return self.count;
}

-(NSArray<GPKGFeatureRowData *> *) getRows{
    return self.rows;
}

-(NSObject *) jsonCompatible{
    return [self jsonCompatibleWithPoints:YES andGeometries:YES];
}

-(NSObject *) jsonCompatibleWithPoints: (BOOL) includePoints{
    return [self jsonCompatibleWithPoints:includePoints andGeometries:NO];
}

-(NSObject *) jsonCompatibleWithGeometries: (BOOL) includeGeometries{
    return [self jsonCompatibleWithPoints:includeGeometries andGeometries:includeGeometries];
}

-(NSObject *) jsonCompatibleWithPoints: (BOOL) includePoints andGeometries: (BOOL) includeGeometries{
    NSObject *jsonObject = nil;
    if(self.rows == nil || self.rows.count == 0){
        jsonObject = [NSNumber numberWithInt:self.count];
    }else{
        NSMutableArray * jsonRows = [[NSMutableArray alloc] init];
        for(GPKGFeatureRowData * row in self.rows){
            [jsonRows addObject:[row jsonCompatibleWithPoints:includePoints andGeometries:includeGeometries]];
        }
        jsonObject = jsonRows;
    }
    
    return jsonObject;
}

@end
