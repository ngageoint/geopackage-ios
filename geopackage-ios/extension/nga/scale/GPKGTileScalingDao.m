//
//  GPKGTileScalingDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 3/12/18.
//  Copyright © 2018 NGA. All rights reserved.
//

#import "GPKGTileScalingDao.h"

@implementation GPKGTileScalingDao

+(GPKGTileScalingDao *) createWithGeoPackage: (GPKGGeoPackage *) geoPackage{
    return [self createWithDatabase:geoPackage.database];
}

+(GPKGTileScalingDao *) createWithDatabase: (GPKGConnection *) database{
    return [[GPKGTileScalingDao alloc] initWithDatabase:database];
}


-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_TS_TABLE_NAME;
        self.idColumns = @[GPKG_TS_COLUMN_PK];
        self.columnNames = @[GPKG_TS_COLUMN_TABLE_NAME, GPKG_TS_COLUMN_SCALING_TYPE, GPKG_TS_COLUMN_ZOOM_IN, GPKG_TS_COLUMN_ZOOM_OUT];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGTileScaling alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGTileScaling *setObject = (GPKGTileScaling*) object;
    
    switch(columnIndex){
        case 0:
            setObject.tableName = (NSString *) value;
            break;
        case 1:
            setObject.scalingType = (NSString *) value;
            break;
        case 2:
            setObject.zoomIn = (NSNumber *) value;
            break;
        case 3:
            setObject.zoomOut = (NSNumber *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGTileScaling *scaling = (GPKGTileScaling*) object;
    
    switch(columnIndex){
        case 0:
            value = scaling.tableName;
            break;
        case 1:
            value = scaling.scalingType;
            break;
        case 2:
            value = scaling.zoomIn;
            break;
        case 3:
            value = scaling.zoomOut;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

@end
