//
//  GPKGSpatialReferenceSystemDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGProjectionConstants.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGContentsDao.h"
#import "GPKGProjectionFactory.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"

@implementation GPKGSpatialReferenceSystemDao

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_SRS_TABLE_NAME;
        self.idColumns = @[GPKG_SRS_COLUMN_PK];
        self.columns = @[GPKG_SRS_COLUMN_SRS_NAME, GPKG_SRS_COLUMN_SRS_ID, GPKG_SRS_COLUMN_ORGANIZATION, GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID, GPKG_SRS_COLUMN_DEFINITION, GPKG_SRS_COLUMN_DESCRIPTION];
        [self initializeColumnIndex];
    }
    return self;
}

-(NSObject *) createObject{
    return [[GPKGSpatialReferenceSystem alloc] init];
}

-(void) setValueInObject: (NSObject*) object withColumnIndex: (int) columnIndex withValue: (NSObject *) value{
    
    GPKGSpatialReferenceSystem *setObject = (GPKGSpatialReferenceSystem*) object;
    
    switch(columnIndex){
        case 0:
            setObject.srsName = (NSString *) value;
            break;
        case 1:
            setObject.srsId = (NSNumber *) value;
            break;
        case 2:
            setObject.organization = (NSString *) value;
            break;
        case 3:
            setObject.organizationCoordsysId = (NSNumber *) value;
            break;
        case 4:
            setObject.definition = (NSString *) value;
            break;
        case 5:
            setObject.theDescription = (NSString *) value;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
}

-(NSObject *) getValueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject * value = nil;
    
    GPKGSpatialReferenceSystem *getObject = (GPKGSpatialReferenceSystem*) object;
    
    switch(columnIndex){
        case 0:
            value = getObject.srsName;
            break;
        case 1:
            value = getObject.srsId;
            break;
        case 2:
            value = getObject.organization;
            break;
        case 3:
            value = getObject.organizationCoordsysId;
            break;
        case 4:
            value = getObject.definition;
            break;
        case 5:
            value = getObject.theDescription;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(GPKGProjection *) getProjection: (NSObject *) object{
    GPKGSpatialReferenceSystem *projectionObject = (GPKGSpatialReferenceSystem*) object;
    GPKGProjection * projection = [GPKGProjectionFactory getProjectionWithNumber:projectionObject.organizationCoordsysId];
    return projection;
}

-(GPKGSpatialReferenceSystem *) createWgs84{
    
    GPKGSpatialReferenceSystem * srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createUndefinedCartesian{
    
    GPKGSpatialReferenceSystem * srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createUndefinedGeographic{
    
    GPKGSpatialReferenceSystem * srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createWebMercator{
    
    GPKGSpatialReferenceSystem * srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties getNumberValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties getValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) getOrCreateWithSrsId: (NSNumber*) srsId{
    
    GPKGSpatialReferenceSystem * srs = (GPKGSpatialReferenceSystem *) [self queryForIdObject:srsId];
    
    if(srs == nil){
        
        long id = [srsId integerValue];
        
        if(id == PROJ_EPSG_WORLD_GEODETIC_SYSTEM){
            srs = [self createWgs84];
        } else if(id == PROJ_UNDEFINED_CARTESIAN){
            srs = [self createUndefinedCartesian];
        } else if(id == PROJ_UNDEFINED_GEOGRAPHIC){
            srs = [self createUndefinedGeographic];
        } else if(id == PROJ_EPSG_WEB_MERCATOR){
            srs = [self createWebMercator];
        } else{
            [NSException raise:@"SRS Not Support" format:@"Spatial Reference System not supported for metadata creation: %@", srsId];
        }
        
    }
    
    return srs;
}

-(int) deleteCascade: (GPKGSpatialReferenceSystem *) srs{
    
    int count = 0;
    
    if(srs != nil){
        
        // Delete contents
        GPKGContentsDao * contentsDao = [self getContentsDao];
        GPKGResultSet * contents = [self getContents:srs];
        while([contents moveToNext]){
            GPKGContents * content = (GPKGContents *) [contentsDao getObject:contents];
            [contentsDao delete:content];
        }
        [contents close];
        
        // Delete Geometry Columns
        GPKGGeometryColumnsDao * geometryColumnsDao = [self getGeometryColumnsDao];
        if([geometryColumnsDao tableExists]){
            GPKGResultSet * geometryColumns = [self getGeometryColumns:srs];
            while([geometryColumns moveToNext]){
                GPKGGeometryColumns * geometryColumn = (GPKGGeometryColumns *) [geometryColumnsDao getObject:geometryColumns];
                [geometryColumnsDao delete:geometryColumn];
            }
            [geometryColumns close];
        }
        
        // Delete Tile Matrix Set
        GPKGTileMatrixSetDao * tileMatrixSetDao = [self getTileMatrixSetDao];
        if([tileMatrixSetDao tableExists]){
            GPKGResultSet * tileMatrixSets = [self getTileMatrixSet:srs];
            while([tileMatrixSets moveToNext]){
                GPKGTileMatrixSet * tileMatrixSet = (GPKGTileMatrixSet *) [tileMatrixSetDao getObject:tileMatrixSets];
                [tileMatrixSetDao delete:tileMatrixSet];
            }
            [tileMatrixSets close];
        }
        
        // Delete
        count = [self delete:srs];
    }

    return count;
}

-(int) deleteCascadeWithCollection: (NSArray *) srsCollection{
    int count = 0;
    if(srsCollection != nil){
        for(GPKGSpatialReferenceSystem *srs in srsCollection){
            count += [self deleteCascade:srs];
        }
    }
    return count;
}

-(int) deleteCascadeWhere: (NSString *) where andWhereArgs: (NSArray *) whereArgs{
    int count = 0;
    if(where != nil){
        GPKGResultSet *results = [self queryWhere:where andWhereArgs:whereArgs];
        while([results moveToNext]){
            GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[self getObject:results];
            count += [self deleteCascade:srs];
        }
        [results close];
    }
    return count;
}

-(int) deleteByIdCascade: (NSNumber *) id{
    int count = 0;
    if(id != nil){
        GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *) [self queryForIdObject:id];
        if(srs != nil){
            count = [self deleteCascade:srs];
        }
    }
    return count;
}

-(int) deleteIdsCascade: (NSArray *) idCollection{
    int count = 0;
    if(idCollection != nil){
        for(NSNumber * id in idCollection){
            count += [self deleteByIdCascade:id];
        }
    }
    return count;
}

-(GPKGResultSet *) getContents: (GPKGSpatialReferenceSystem *) srs{
    GPKGContentsDao * dao = [self getContentsDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_CON_COLUMN_SRS_ID andValue:srs.srsId];
    return results;
}

-(GPKGResultSet *) getGeometryColumns: (GPKGSpatialReferenceSystem *) srs{
    GPKGGeometryColumnsDao * dao = [self getGeometryColumnsDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_GC_COLUMN_SRS_ID andValue:srs.srsId];
    return results;
}


-(GPKGResultSet *) getTileMatrixSet: (GPKGSpatialReferenceSystem *) srs{
    GPKGTileMatrixSetDao * dao = [self getTileMatrixSetDao];
    GPKGResultSet * results = [dao queryForEqWithField:GPKG_TMS_COLUMN_SRS_ID andValue:srs.srsId];
    return results;
}

-(GPKGContentsDao *) getContentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

-(GPKGGeometryColumnsDao *) getGeometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}


-(GPKGTileMatrixSetDao *) getTileMatrixSetDao{
    return [[GPKGTileMatrixSetDao alloc] initWithDatabase:self.database];
}

@end
