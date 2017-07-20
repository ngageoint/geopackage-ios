//
//  GPKGUserDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/20/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGUserDao.h"
#import "GPKGUserRow.h"
#import "GPKGProjectionTransform.h"
#import "GPKGProjectionConstants.h"
#import "GPKGTileBoundingBoxUtils.h"

@implementation GPKGUserDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGUserTable *) table{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.table = table;
        self.tableName = table.tableName;
        GPKGUserColumn * pkColumn = [table getPkColumn];
        if(pkColumn != nil){
            self.idColumns = @[pkColumn.name];
        }else{
            self.idColumns = @[];
        }
        self.columns = table.columnNames;
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGUserRow alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGUserRow *setObject = (GPKGUserRow*) object;
    [setObject setValueNoValidationWithIndex:columnIndex andValue:value];
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    GPKGUserRow *getObject = (GPKGUserRow*) object;
    NSObject * value = [getObject getDatabaseValueWithIndex:columnIndex];

    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    return self.projection;
}

-(GPKGUserRow *) getRow: (GPKGResultSet *) results{
    
    GPKGUserRow * row = nil;
    
    if(self.table != nil){
        
        int columns = [self.table columnCount];
        
        NSMutableArray *columnTypes = [[NSMutableArray alloc] initWithCapacity:columns];
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:columns];
        
        [results getRowPopulateValues:values andColumnTypes:columnTypes];
        
        row = [self newRowWithColumnTypes:columnTypes andValues:values];
    }
    
    return row;
}

-(long long) insert: (NSObject *) object{
    long long id = [super insert:object];
    [self setId:object withIdValue:[NSNumber numberWithLongLong:id]];
    return id;
}

-(GPKGUserRow *) newRowWithColumnTypes: (NSArray *) columnTypes andValues: (NSMutableArray *) values{
    return [[GPKGUserRow alloc] init];
}

-(GPKGBoundingBox *) getBoundingBox{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(int) getZoomLevel{
    if(self.projection == nil){
        [NSException raise:@"No Projection" format:@"No projection was set which is required to determine the zoom level"];
    }
    int zoomLevel = 0;
    GPKGBoundingBox * boundingBox = [self getBoundingBox];
    if(boundingBox != nil){
        
        if([self.projection getUnit] == GPKG_UNIT_DEGREES){
            boundingBox = [GPKGTileBoundingBoxUtils boundDegreesBoundingBoxWithWebMercatorLimits:boundingBox];
        }
        GPKGProjectionTransform * webMercatorTransform = [[GPKGProjectionTransform alloc] initWithFromProjection:self.projection andToEpsg:PROJ_EPSG_WEB_MERCATOR];
        GPKGBoundingBox * webMercatorBoundingBox = [webMercatorTransform transformWithBoundingBox:boundingBox];
        zoomLevel = [GPKGTileBoundingBoxUtils getZoomLevelWithWebMercatorBoundingBox:webMercatorBoundingBox];
    }
    return zoomLevel;
}

@end
