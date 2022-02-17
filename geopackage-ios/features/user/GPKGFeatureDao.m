//
//  GPKGFeatureDao.m
//  geopackage-ios
//
//  Created by Brian Osborn on 5/21/15.
//  Copyright (c) 2015 NGA. All rights reserved.
//

#import "GPKGFeatureDao.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGContentsDao.h"

@implementation GPKGFeatureDao

-(instancetype) initWithDatabase: (GPKGConnection *) database andTable: (GPKGFeatureTable *) table andGeometryColumns: (GPKGGeometryColumns *) geometryColumns andMetadataDb: (GPKGMetadataDb *) metadataDb{
    self = [super initWithDatabase:database andTable:table];
    if(self != nil){
        self.geometryColumns = geometryColumns;
        self.metadataDb = metadataDb;
        GPKGGeometryColumnsDao *dao = [self geometryColumnsDao];
        if([dao contents:geometryColumns] == nil){
            [NSException raise:@"Missing Contents" format:@"Geometry Columns %@ has null Contents", [dao id:geometryColumns]];
        }
        if([dao srs:geometryColumns] == nil){
            [NSException raise:@"Missing SRS" format:@"Geometry Columns %@ has null Spatial Reference System", [dao id:geometryColumns]];
        }
        
        self.projection = [dao projection:geometryColumns];
    }
    return self;
}

-(NSObject *) createObject{
    return [self newRow];
}

-(GPKGFeatureTable *) featureTable{
    return (GPKGFeatureTable *) self.table;
}

-(GPKGFeatureRow *) row: (GPKGResultSet *) results{
    return (GPKGFeatureRow *) [super row:results];
}

-(GPKGFeatureRow *) featureRow: (GPKGResultSet *) results{
    return (GPKGFeatureRow *) [super row:results];
}

-(GPKGFeatureRow *) rowWithRow: (GPKGRow *) row{
    return (GPKGFeatureRow *) [super rowWithRow:row];
}

-(GPKGUserRow *) newRowWithColumns: (GPKGUserColumns *) columns andValues: (NSMutableArray *) values{
    return [[GPKGFeatureRow alloc] initWithFeatureTable:[self featureTable] andColumns:(GPKGFeatureColumns *) columns andValues:values];
}

-(GPKGFeatureRow *) newRow{
    return [[GPKGFeatureRow alloc] initWithFeatureTable:(GPKGFeatureTable *)self.table];
}

-(NSString *) geometryColumnName{
    return _geometryColumns.columnName;
}

-(enum SFGeometryType) geometryType{
    return [self.geometryColumns geometryType];
}

-(GPKGSpatialReferenceSystem *) srs{
    return [[self geometryColumnsDao] srs:self.geometryColumns];
}

-(NSNumber *) srsId{
    return self.geometryColumns.srsId;
}

-(GPKGFeatureColumn *) idColumn{
    return (GPKGFeatureColumn *) [self pkColumn];
}

-(NSString *) idColumnName{
    return [self pkColumnName];
}

-(NSArray<NSString *> *) idAndGeometryColumnNames{
    return [[self featureTable] idAndGeometryColumnNames];
}

-(GPKGGeometryColumnsDao *) geometryColumnsDao{
    return [[GPKGGeometryColumnsDao alloc] initWithDatabase:self.database];
}

-(GPKGContentsDao *) contentsDao{
    return [[GPKGContentsDao alloc] initWithDatabase:self.database];
}

-(GPKGBoundingBox *) boundingBox{
    return [ self boundingBoxInProjection:self.projection];
}

-(GPKGBoundingBox *) boundingBoxInProjection: (PROJProjection *) projection{
    GPKGGeometryColumnsDao *geometryColumnsDao = [self geometryColumnsDao];
    GPKGContents *contents = [geometryColumnsDao contents:self.geometryColumns];
    GPKGContentsDao * contentsDao = [self contentsDao];
    GPKGBoundingBox *boundingBox = [contentsDao boundingBoxOfContents:contents inProjection:projection];
    return boundingBox;
}

@end
