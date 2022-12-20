//
//  GPKGTileTableMetadata.h
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/20.
//  Copyright © 2020 NGA. All rights reserved.
//

#import "GPKGUserTableMetadata.h"
#import "GPKGTileTable.h"

/**
 * Tile Table Metadata for defining table creation information
 */
@interface GPKGTileTableMetadata : GPKGUserTableMetadata

/**
 * Create metadata
 *
 * @return metadata
 */
+(GPKGTileTableMetadata *) create;

/**
 * Create metadata
 *
 * @param autoincrement
 *            autoincrement ids
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithAutoincrement: (BOOL) autoincrement;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param contentsBoundingBox
 *            contents bounding box
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param contentsBoundingBox
 *            contents bounding box
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param contentsBoundingBox
 *            contents bounding box
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param contentsBoundingBox
 *            contents bounding box
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Create metadata
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 * @return metadata
 */
+(GPKGTileTableMetadata *) createWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Contents bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox *contentsBoundingBox;

/**
 * Contents SRS id
 */
@property (nonatomic, strong) NSNumber *contentsSrsId;

/**
 * Tile bounding box
 */
@property (nonatomic, strong) GPKGBoundingBox *tileBoundingBox;

/**
 * Tile SRS id
 */
@property (nonatomic, strong) NSNumber *tileSrsId;

/**
 * Initialize
 *
 * @return new tile table metadata
 */
-(instancetype) init;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 *
 * @return new tile table metadata
 */
-(instancetype) initWithTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 *
 * @return new tile table metadata
 */
-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Initialize
 *
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 *
 * @return new tile table metadata
 */
-(instancetype) initWithTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

/**
 * Initialize
 *
 * @param dataType
 *            data type
 * @param tableName
 *            table name
 * @param autoincrement
 *            autoincrement ids
 * @param contentsBoundingBox
 *            contents bounding box
 * @param contentsSrsId
 *            contents SRS id
 * @param tileBoundingBox
 *            tile bounding box
 * @param tileSrsId
 *            tile SRS id
 *
 * @return new tile table metadata
 */
-(instancetype) initWithDataType: (NSString *) dataType andTable: (NSString *) tableName andAutoincrement: (BOOL) autoincrement andContentsBoundingBox: (GPKGBoundingBox *) contentsBoundingBox andContentsSrsId: (NSNumber *) contentsSrsId andTileBoundingBox: (GPKGBoundingBox *) tileBoundingBox andTileSrsId: (NSNumber *) tileSrsId;

@end
