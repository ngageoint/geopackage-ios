//
//  GPKGSpatialReferenceSystem.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const SRS_TABLE_NAME;
extern NSString * const SRS_COLUMN_PK;
extern NSString * const SRS_COLUMN_SRS_NAME;
extern NSString * const SRS_COLUMN_SRS_ID;
extern NSString * const SRS_COLUMN_ORGANIZATION;
extern NSString * const SRS_COLUMN_ORGANIZATION_COORDSYS_ID;
extern NSString * const SRS_COLUMN_DEFINITION;
extern NSString * const SRS_COLUMN_DESCRIPTION;

@interface GPKGSpatialReferenceSystem : NSObject

@property (nonatomic, strong) NSString *srsName;
@property (nonatomic, strong) NSNumber *srsId;
@property (nonatomic, strong) NSString *organization;
@property (nonatomic, strong) NSNumber *organizationCoordsysId;
@property (nonatomic, strong) NSString *definition;
@property (nonatomic, strong) NSString *theDescription;

@end
