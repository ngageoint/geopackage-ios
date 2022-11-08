//
//  GPKGSpatialReferenceSystemDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/15/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGSpatialReferenceSystemDao.h"
#import "PROJProjectionConstants.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGContentsDao.h"
#import "PROJProjectionFactory.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGCrsWktExtension.h"

@interface GPKGSpatialReferenceSystemDao()

@property (nonatomic, strong)  GPKGCrsWktExtension *crsWktExt;

@end

@implementation GPKGSpatialReferenceSystemDao

+(GPKGSpatialReferenceSystemDao *) createWithDatabase: (GPKGConnection *) database{
    return [[GPKGSpatialReferenceSystemDao alloc] initWithDatabase:database];
}

-(instancetype) initWithDatabase: (GPKGConnection *) database{
    self = [super initWithDatabase:database];
    if(self != nil){
        self.tableName = GPKG_SRS_TABLE_NAME;
        self.idColumns = @[GPKG_SRS_COLUMN_PK];
        self.columnNames = @[GPKG_SRS_COLUMN_SRS_NAME, GPKG_SRS_COLUMN_SRS_ID, GPKG_SRS_COLUMN_ORGANIZATION, GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID, GPKG_SRS_COLUMN_DEFINITION, GPKG_SRS_COLUMN_DESCRIPTION];
        [self initializeColumnIndex];
    }
    return self;
}

-(void) setCrsWktExtension: (NSObject *) crsWktExtension{
    self.crsWktExt = (GPKGCrsWktExtension *) crsWktExtension;
}

-(BOOL) hasDefinition_12_063{
    return self.crsWktExt != nil && [self.crsWktExt hasMinimum:GPKG_CRS_WKT_V_1];
}

-(BOOL) hasEpoch{
    return self.crsWktExt != nil && [self.crsWktExt hasMinimum:GPKG_CRS_WKT_V_1_1];
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

-(NSObject *) valueFromObject: (NSObject*) object withColumnIndex: (int) columnIndex{
    
    NSObject *value = nil;
    
    GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem*) object;
    
    switch(columnIndex){
        case 0:
            value = srs.srsName;
            break;
        case 1:
            value = srs.srsId;
            break;
        case 2:
            value = srs.organization;
            break;
        case 3:
            value = srs.organizationCoordsysId;
            break;
        case 4:
            value = srs.definition;
            break;
        case 5:
            value = srs.theDescription;
            break;
        default:
            [NSException raise:@"Illegal Column Index" format:@"Unsupported column index: %d", columnIndex];
            break;
    }
    
    return value;
}

-(PROJProjection *) projection: (NSObject *) object{
    GPKGSpatialReferenceSystem *projectionObject = (GPKGSpatialReferenceSystem*) object;
    PROJProjection *projection = [projectionObject projection];
    return projection;
}

-(GPKGSpatialReferenceSystem *) createWgs84{
    
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    if([self hasDefinition_12_063]){
        [srs setDefinition_12_063:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84 andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
        [self.crsWktExt updateDefinition:srs.definition_12_063 withSrsId:srs.srsId];
    }
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createUndefinedCartesian{
    
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    if([self hasDefinition_12_063]){
        [srs setDefinition_12_063:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_CARTESIAN andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
        [self.crsWktExt updateDefinition:srs.definition_12_063 withSrsId:srs.srsId];
    }
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createUndefinedGeographic{
    
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    if([self hasDefinition_12_063]){
        [srs setDefinition_12_063:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_UNDEFINED_GEOGRAPHIC andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
        [self.crsWktExt updateDefinition:srs.definition_12_063 withSrsId:srs.srsId];
    }
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createWebMercator{
    
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    if([self hasDefinition_12_063]){
        [srs setDefinition_12_063:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WEB_MERCATOR andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
        [self.crsWktExt updateDefinition:srs.definition_12_063 withSrsId:srs.srsId];
    }
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) createWgs84Geographical3D{
    
    GPKGSpatialReferenceSystem *srs = [[GPKGSpatialReferenceSystem alloc] init];
    [srs setSrsName:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_SRS_NAME]];
    [srs setSrsId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_SRS_ID]];
    [srs setOrganization:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_ORGANIZATION]];
    [srs setOrganizationCoordsysId:[GPKGProperties numberValueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_ORGANIZATION_COORDSYS_ID]];
    [srs setDefinition:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_DEFINITION]];
    [srs setTheDescription:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_DESCRIPTION]];
    [self create:srs];
    if([self hasDefinition_12_063]){
        [srs setDefinition_12_063:[GPKGProperties valueOfBaseProperty:GPKG_PROP_SRS_WGS_84_3D andProperty:GPKG_PROP_SRS_DEFINITION_12_063]];
        [self.crsWktExt updateDefinition:srs.definition_12_063 withSrsId:srs.srsId];
    }
    
    return srs;
}

-(NSString *) definition_12_063WithSrsId: (NSNumber *) srsId{
    NSString *definition = nil;
    if([self hasDefinition_12_063]){
        definition = [self.crsWktExt definitionWithSrsId:srsId];
    }
    return definition;
}

-(NSDecimalNumber *) epochWithSrsId: (NSNumber *) srsId{
    NSDecimalNumber *epoch = nil;
    if([self hasEpoch]){
        epoch = [self.crsWktExt epochWithSrsId:srsId];
    }
    return epoch;
}

-(void) setExtensionWithSrs: (GPKGSpatialReferenceSystem *) srs{
    if(srs != nil){
        NSNumber *srsId = srs.srsId;
        NSString *definition = [self definition_12_063WithSrsId:srsId];
        if(definition != nil){
            [srs setDefinition_12_063:definition];
        }
        NSDecimalNumber *epoch = [self epochWithSrsId:srsId];
        if(epoch != nil){
            [srs setEpoch:epoch];
        }
    }
}

-(void) setExtensionWithSrsArray: (NSArray *) srsArray{
    for(GPKGSpatialReferenceSystem *srs in srsArray){
        [self setExtensionWithSrs:srs];
    }
}

-(void) updateDefinition_12_063: (NSString *) definition withSrsId: (NSNumber *) srsId{
    if([self hasDefinition_12_063]){
        if(definition == nil){
            definition = @"";
        }
        [self.crsWktExt updateDefinition:definition withSrsId:srsId];
    }
}

-(void) updateEpoch: (NSDecimalNumber *) epoch withSrsId: (NSNumber *) srsId{
    if([self hasEpoch]){
        [self.crsWktExt updateEpoch:epoch withSrsId:srsId];
    }
}

-(void) updateExtensionWithSrs: (GPKGSpatialReferenceSystem *) srs{
    if(srs != nil){
        NSNumber *srsId = srs.srsId;
        [self updateDefinition_12_063:srs.definition_12_063 withSrsId:srsId];
        [self updateEpoch:srs.epoch withSrsId:srsId];
    }
}

-(NSObject *) queryForIdObject: (NSObject *) idValue{
    NSObject *result = [super queryForIdObject:idValue];
    [self setExtensionWithSrs:(GPKGSpatialReferenceSystem *) result];
    return result;
}

-(NSObject *) queryForMultiIdObject: (NSArray *) idValues{
    NSObject *result = [super queryForMultiIdObject:idValues];
    [self setExtensionWithSrs:(GPKGSpatialReferenceSystem *) result];
    return result;
}

-(NSObject *) object: (GPKGResultSet *) results{
    NSObject *result = [super object:results];
    [self setExtensionWithSrs:(GPKGSpatialReferenceSystem *) result];
    return result;
}

-(NSObject *) firstObject: (GPKGResultSet *)results{
    NSObject *result = [super firstObject:results];
    [self setExtensionWithSrs:(GPKGSpatialReferenceSystem *) result];
    return result;
}

-(NSObject *) queryForSameId: (NSObject *) object{
    NSObject *result = [super queryForSameId:object];
    [self setExtensionWithSrs:(GPKGSpatialReferenceSystem *) result];
    return result;
}

-(int) update: (NSObject *) object{
    int result = [super update:object];
    [self updateExtensionWithSrs:(GPKGSpatialReferenceSystem *) object];
    return result;
}

-(long long) create: (NSObject *) object{
    long long result = [super create:object];
    [self updateExtensionWithSrs:(GPKGSpatialReferenceSystem *) object];
    return result;
}

-(long long) insert: (NSObject *) object{
    long long result = [super insert:object];
    [self updateExtensionWithSrs:(GPKGSpatialReferenceSystem *) object];
    return result;
}

-(long long) createIfNotExists: (NSObject *) object{
    long long result = [super createIfNotExists:object];
    if(result != -1){
        [self updateExtensionWithSrs:(GPKGSpatialReferenceSystem *) object];
    }
    return result;
}

-(long long) createOrUpdate: (NSObject *) object{
    long long result = [super createOrUpdate:object];
    [self updateExtensionWithSrs:(GPKGSpatialReferenceSystem *) object];
    return result;
}

-(GPKGSpatialReferenceSystem *) srsWithEpsg: (NSNumber*) epsg{
    return [self srsWithOrganization:PROJ_AUTHORITY_EPSG andCoordsysId:epsg];
}

-(GPKGSpatialReferenceSystem *) srsWithOrganization: (NSString *) organization andCoordsysId: (NSNumber *) coordsysId{
    
    GPKGSpatialReferenceSystem *srs = [self queryForOrganization:organization andCoordsysId:coordsysId];
    
    srs = [self createIfNeededWithSrs:srs andOrganization:organization andCoordsysId:coordsysId];
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) srsWithProjection: (PROJProjection *) projection{
    NSNumber *coordsysId = [NSNumber numberWithInteger:[[projection code] integerValue]];
    return [self srsWithOrganization:[projection authority] andCoordsysId:coordsysId];
}

-(GPKGSpatialReferenceSystem *) queryForOrganization: (NSString *) organization andCoordsysId: (NSNumber *) coordsysId{
    GPKGSpatialReferenceSystem *srs = nil;
    
    GPKGColumnValues *values = [[GPKGColumnValues alloc] init];
    [values addColumn:GPKG_SRS_COLUMN_ORGANIZATION withValue:organization];
    [values addColumn:GPKG_SRS_COLUMN_ORGANIZATION_COORDSYS_ID withValue:coordsysId];
    
    GPKGResultSet *results = [self queryForFieldValues:values];
    if(results.count > 0){
        if(results.count > 1){
            [NSException raise:@"Unexpected Result" format:@"More than one SpatialReferenceSystem returned for Organization: %@, Organization Coordsys Id: %@", organization, coordsysId];
        }
        srs = (GPKGSpatialReferenceSystem *) [self firstObject:results];
    }
    [results close];
    
    return srs;
}

-(GPKGSpatialReferenceSystem *) queryForProjection: (PROJProjection *) projection{
    NSNumber *coordsysId = [NSNumber numberWithInteger:[[projection code] integerValue]];
    return [self queryForOrganization:[projection authority] andCoordsysId:coordsysId];
}

-(GPKGSpatialReferenceSystem *) createIfNeededWithSrs: (GPKGSpatialReferenceSystem *) srs andOrganization: (NSString *) organization andCoordsysId: (NSNumber *) coordsysId{
    
    if(srs == nil){
        
        long idValue = [coordsysId integerValue];
        
        if([organization caseInsensitiveCompare:PROJ_AUTHORITY_EPSG] == NSOrderedSame){
            
            if(idValue == PROJ_EPSG_WORLD_GEODETIC_SYSTEM){
                srs = [self createWgs84];
            } else if(idValue == PROJ_EPSG_WEB_MERCATOR){
                srs = [self createWebMercator];
            }else if(idValue == PROJ_EPSG_WORLD_GEODETIC_SYSTEM_GEOGRAPHICAL_3D){
                srs = [self createWgs84Geographical3D];
            } else{
                [NSException raise:@"SRS Not Support" format:@"Spatial Reference System not supported for metadata creation: Organization: %@, id: %@", organization, coordsysId];
            }
            
        }else if([organization caseInsensitiveCompare:PROJ_AUTHORITY_NONE] == NSOrderedSame){
            
            if(idValue == PROJ_UNDEFINED_CARTESIAN){
                srs = [self createUndefinedCartesian];
            } else if(idValue == PROJ_UNDEFINED_GEOGRAPHIC){
                srs = [self createUndefinedGeographic];
            } else{
                [NSException raise:@"SRS Not Support" format:@"Spatial Reference System not supported for metadata creation: Organization: %@, id: %@", organization, coordsysId];
            }
            
        }else{
            [NSException raise:@"SRS Not Support" format:@"Spatial Reference System not supported for metadata creation: Organization: %@, id: %@", organization, coordsysId];
        }
        
    }else{
        [self setExtensionWithSrs:srs];
    }
    
    return srs;
}

-(int) deleteCascade: (GPKGSpatialReferenceSystem *) srs{
    
    int count = 0;
    
    if(srs != nil){
        
        // Delete contents
        GPKGContentsDao *contentsDao = [self contentsDao];
        GPKGResultSet *contents = [self contents:srs];
        while([contents moveToNext]){
            GPKGContents *content = (GPKGContents *) [contentsDao object:contents];
            [contentsDao delete:content];
        }
        [contents close];
        
        // Delete Geometry Columns
        GPKGGeometryColumnsDao *geometryColumnsDao = [self geometryColumnsDao];
        if([geometryColumnsDao tableExists]){
            GPKGResultSet *geometryColumns = [self geometryColumns:srs];
            while([geometryColumns moveToNext]){
                GPKGGeometryColumns *geometryColumn = (GPKGGeometryColumns *) [geometryColumnsDao object:geometryColumns];
                [geometryColumnsDao delete:geometryColumn];
            }
            [geometryColumns close];
        }
        
        // Delete Tile Matrix Set
        GPKGTileMatrixSetDao *tileMatrixSetDao = [self tileMatrixSetDao];
        if([tileMatrixSetDao tableExists]){
            GPKGResultSet *tileMatrixSets = [self tileMatrixSet:srs];
            while([tileMatrixSets moveToNext]){
                GPKGTileMatrixSet *tileMatrixSet = (GPKGTileMatrixSet *) [tileMatrixSetDao object:tileMatrixSets];
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
        NSMutableArray *srsArray = [NSMutableArray array];
        GPKGResultSet *results = [self queryWhere:where andWhereArgs:whereArgs];
        while([results moveToNext]){
            GPKGSpatialReferenceSystem *srs = (GPKGSpatialReferenceSystem *)[self object:results];
            [srsArray addObject:srs];
        }
        [results close];
        for(GPKGSpatialReferenceSystem *srs in srsArray){
            count += [self deleteCascade:srs];
        }
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
        for(NSNumber *id in idCollection){
            count += [self deleteByIdCascade:id];
        }
    }
    return count;
}

-(GPKGResultSet *) contents: (GPKGSpatialReferenceSystem *) srs{
    GPKGContentsDao *dao = [self contentsDao];
    GPKGResultSet *results = [dao queryForEqWithField:GPKG_CON_COLUMN_SRS_ID andValue:srs.srsId];
    return results;
}

-(GPKGResultSet *) geometryColumns: (GPKGSpatialReferenceSystem *) srs{
    GPKGGeometryColumnsDao *dao = [self geometryColumnsDao];
    GPKGResultSet *results = [dao queryForEqWithField:GPKG_GC_COLUMN_SRS_ID andValue:srs.srsId];
    return results;
}


-(GPKGResultSet *) tileMatrixSet: (GPKGSpatialReferenceSystem *) srs{
    GPKGTileMatrixSetDao *dao = [self tileMatrixSetDao];
    GPKGResultSet *results = [dao queryForEqWithField:GPKG_TMS_COLUMN_SRS_ID andValue:srs.srsId];
    return results;
}

-(GPKGContentsDao *) contentsDao{
    return [GPKGContentsDao createWithDatabase:self.database];
}

-(GPKGGeometryColumnsDao *) geometryColumnsDao{
    return [GPKGGeometryColumnsDao createWithDatabase:self.database];
}


-(GPKGTileMatrixSetDao *) tileMatrixSetDao{
    return [GPKGTileMatrixSetDao createWithDatabase:self.database];
}

@end
