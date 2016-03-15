//
//  GPKGFeatureTableData.h
//  geopackage-ios
//
//  Created by Brian Osborn on 3/15/16.
//  Copyright © 2016 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGFeatureRowData.h"

@interface GPKGFeatureTableData : NSObject

-(instancetype) initWithName: (NSString *) name andCount: (int) count;

-(instancetype) initWithName: (NSString *) name andCount: (int) count andRows: (NSArray<GPKGFeatureRowData *> *) rows;

-(NSString *) getName;

-(int) getCount;

-(NSArray<GPKGFeatureRowData *> *) getRows;

-(NSObject *) jsonCompatible;

@end
