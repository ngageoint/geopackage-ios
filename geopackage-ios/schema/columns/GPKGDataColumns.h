//
//  GPKGDataColumns.h
//  geopackage-ios
//
//  Created by Brian Osborn on 5/19/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPKGContents.h"
#import "GPKGDataColumnConstraints.h"

extern NSString * const DC_TABLE_NAME;
extern NSString * const DC_COLUMN_PK1;
extern NSString * const DC_COLUMN_PK2;
extern NSString * const DC_COLUMN_TABLE_NAME;
extern NSString * const DC_COLUMN_COLUMN_NAME;
extern NSString * const DC_COLUMN_NAME;
extern NSString * const DC_COLUMN_TITLE;
extern NSString * const DC_COLUMN_DESCRIPTION;
extern NSString * const DC_COLUMN_MIME_TYPE;
extern NSString * const DC_COLUMN_CONSTRAINT_NAME;

@interface GPKGDataColumns : NSObject

@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) NSString *columnName;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *theDescription;
@property (nonatomic, strong) NSString *mimeType;
@property (nonatomic, strong) NSString *constraintName;

-(void) setContents: (GPKGContents *) contents;

-(void) setConstraint: (GPKGDataColumnConstraints *) constraint;

@end
