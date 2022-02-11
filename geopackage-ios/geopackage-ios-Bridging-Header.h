//
//  geopackage-ios-Bridging-Header.h
//  geopackage-ios
//
//  Created by Brian Osborn on 11/23/15.
//  Copyright © 2015 NGA. All rights reserved.
//

#ifndef geopackage_ios_Bridging_Header_h
#define geopackage_ios_Bridging_Header_h

#import "sf-wkb-ios-Bridging-Header.h"
#import "sf-proj-ios-Bridging-Header.h"
#import "tiff-ios-Bridging-Header.h"
#import "ogc-api-features-json-ios-Bridging-Header.h"
#import "GPKGBoundingBox.h"
#import "GPKGDateTimeUtils.h"
#import "GPKGGeoPackage.h"
#import "GPKGGeoPackageCache.h"
#import "GPKGGeoPackageConstants.h"
#import "GPKGUtils.h"
#import "geopackage_ios.h"
#import "GPKGAttributesColumn.h"
#import "GPKGAttributesDao.h"
#import "GPKGAttributesRow.h"
#import "GPKGAttributesTable.h"
#import "GPKGAttributesTableReader.h"
#import "GPKGContents.h"
#import "GPKGContentsDao.h"
#import "GPKGContentsDataTypes.h"
#import "GPKGSpatialReferenceSystem.h"
#import "GPKGSpatialReferenceSystemDao.h"
#import "GPKGAlterTable.h"
#import "GPKGConnection.h"
#import "GPKGConnectionFunction.h"
#import "GPKGDataTypes.h"
#import "GPKGFeatureIndexer.h"
#import "GPKGGeoPackageTableCreator.h"
#import "GPKGMappedColumn.h"
#import "GPKGResultSet.h"
#import "GPKGSqlLiteQueryBuilder.h"
#import "GPKGSqlUtils.h"
#import "GPKGTableCreator.h"
#import "GPKGTableMapping.h"
#import "GPKGBaseDao.h"
#import "GPKGColumnValue.h"
#import "GPKGColumnValues.h"
#import "GPKGSQLiteMaster.h"
#import "GPKGSQLiteMasterColumns.h"
#import "GPKGSQLiteMasterQuery.h"
#import "GPKGSQLiteMasterTypes.h"
#import "GPKGGeoPackageMetadata.h"
#import "GPKGGeoPackageMetadataDao.h"
#import "GPKGGeoPackageMetadataTableCreator.h"
#import "GPKGGeometryMetadata.h"
#import "GPKGGeometryMetadataDao.h"
#import "GPKGMetadataDb.h"
#import "GPKGTableMetadata.h"
#import "GPKGTableMetadataDao.h"
#import "GPKGConnectionPool.h"
#import "GPKGDbConnection.h"
#import "GPKGSqliteConnection.h"
#import "GPKGColumnConstraints.h"
#import "GPKGConstraint.h"
#import "GPKGConstraintParser.h"
#import "GPKGConstraintTypes.h"
#import "GPKGRawConstraint.h"
#import "GPKGTableColumn.h"
#import "GPKGTableConstraints.h"
#import "GPKGTableInfo.h"
#import "GPKGUniqueConstraint.h"
#import "GPKGBaseExtension.h"
#import "GPKGCrsWktExtension.h"
#import "GPKGExtensions.h"
#import "GPKGExtensionsDao.h"
#import "GPKGFeatureIndexRTreeResults.h"
#import "GPKGExtensionManager.h"
#import "GPKGGeometryExtensions.h"
#import "GPKGMetadataExtension.h"
#import "GPKGNGAExtensions.h"
#import "GPKGRTreeIndexExtension.h"
#import "GPKGRTreeIndexTableDao.h"
#import "GPKGRTreeIndexTableRow.h"
#import "GPKGSchemaExtension.h"
#import "GPKGWebPExtension.h"
#import "GPKGZoomOtherExtension.h"
#import "GPKGContentsId.h"
#import "GPKGContentsIdDao.h"
#import "GPKGContentsIdExtension.h"
#import "GPKGCoverageData.h"
#import "GPKGCoverageDataAlgorithms.h"
#import "GPKGCoverageDataImage.h"
#import "GPKGCoverageDataPng.h"
#import "GPKGCoverageDataPngImage.h"
#import "GPKGCoverageDataRequest.h"
#import "GPKGCoverageDataResults.h"
#import "GPKGCoverageDataSourcePixel.h"
#import "GPKGCoverageDataTiff.h"
#import "GPKGCoverageDataTiffImage.h"
#import "GPKGCoverageDataTileMatrixResults.h"
#import "GPKGGriddedCoverage.h"
#import "GPKGGriddedCoverageDao.h"
#import "GPKGGriddedCoverageDataTypes.h"
#import "GPKGGriddedCoverageEncodingTypes.h"
#import "GPKGGriddedTile.h"
#import "GPKGGriddedTileDao.h"
#import "GPKGFeatureTableIndex.h"
#import "GPKGGeometryIndex.h"
#import "GPKGGeometryIndexDao.h"
#import "GPKGTableIndex.h"
#import "GPKGTableIndexDao.h"
#import "GPKGFeatureTileLink.h"
#import "GPKGFeatureTileLinkDao.h"
#import "GPKGFeatureTileTableLinker.h"
#import "GPKGPropertiesExtension.h"
#import "GPKGPropertiesManager.h"
#import "GPKGPropertyNames.h"
#import "GPKGExtendedRelation.h"
#import "GPKGExtendedRelationsDao.h"
#import "GPKGRelatedTablesExtension.h"
#import "GPKGRelationTypes.h"
#import "GPKGUserMappingDao.h"
#import "GPKGUserMappingRow.h"
#import "GPKGUserMappingTable.h"
#import "GPKGUserRelatedTable.h"
#import "GPKGDublinCoreMetadata.h"
#import "GPKGDublinCoreTypes.h"
#import "GPKGMediaDao.h"
#import "GPKGMediaRow.h"
#import "GPKGMediaTable.h"
#import "GPKGSimpleAttributesDao.h"
#import "GPKGSimpleAttributesRow.h"
#import "GPKGSimpleAttributesTable.h"
#import "GPKGTileScaling.h"
#import "GPKGTileScalingDao.h"
#import "GPKGTileScalingTypes.h"
#import "GPKGTileTableScaling.h"
#import "GPKGFeatureStyle.h"
#import "GPKGFeatureStyleExtension.h"
#import "GPKGFeatureStyles.h"
#import "GPKGFeatureTableStyles.h"
#import "GPKGIconCache.h"
#import "GPKGIconDao.h"
#import "GPKGIconRow.h"
#import "GPKGIconTable.h"
#import "GPKGIcons.h"
#import "GPKGStyleDao.h"
#import "GPKGStyleMappingDao.h"
#import "GPKGStyleMappingRow.h"
#import "GPKGStyleMappingTable.h"
#import "GPKGStyleRow.h"
#import "GPKGStyleTable.h"
#import "GPKGStyles.h"
#import "GPKGGeoPackageFactory.h"
#import "GPKGGeoPackageManager.h"
#import "GPKGSessionTaskData.h"
#import "GPKGFeatureGenerator.h"
#import "GPKGOAPIFeatureGenerator.h"
#import "GPKGGeometryColumns.h"
#import "GPKGGeometryColumnsDao.h"
#import "GPKGFeatureIndexFeatureResults.h"
#import "GPKGFeatureIndexGeoPackageResults.h"
#import "GPKGFeatureIndexListResults.h"
#import "GPKGFeatureIndexManager.h"
#import "GPKGFeatureIndexMetadataResults.h"
#import "GPKGFeatureIndexResultSetResults.h"
#import "GPKGFeatureIndexResults.h"
#import "GPKGFeatureIndexTypes.h"
#import "GPKGMultipleFeatureIndexResults.h"
#import "GPKGFeatureCache.h"
#import "GPKGFeatureCacheTables.h"
#import "GPKGFeatureColumn.h"
#import "GPKGFeatureDao.h"
#import "GPKGFeatureRow.h"
#import "GPKGFeatureTable.h"
#import "GPKGFeatureTableReader.h"
#import "GPKGManualFeatureQuery.h"
#import "GPKGManualFeatureQueryResults.h"
#import "GPKGGeometryData.h"
#import "GPKGGeometryUtils.h"
#import "GPKGFeatureShape.h"
#import "GPKGFeatureShapes.h"
#import "GPKGLocationBoundingBox.h"
#import "GPKGMapPoint.h"
#import "GPKGMapPointInitializer.h"
#import "GPKGMapPointOptions.h"
#import "GPKGMapShape.h"
#import "GPKGMapShapeConverter.h"
#import "GPKGMapShapePoints.h"
#import "GPKGMapShapeTypes.h"
#import "GPKGMultiPoint.h"
#import "GPKGMultiPolygon.h"
#import "GPKGMultiPolygonPoints.h"
#import "GPKGMultiPolyline.h"
#import "GPKGMultiPolylinePoints.h"
#import "GPKGPolygon.h"
#import "GPKGPolygonHolePoints.h"
#import "GPKGPolygonOptions.h"
#import "GPKGPolygonOrientations.h"
#import "GPKGPolygonPoints.h"
#import "GPKGPolyline.h"
#import "GPKGPolylineOptions.h"
#import "GPKGPolylinePoints.h"
#import "GPKGShapePoints.h"
#import "GPKGShapeWithChildrenPoints.h"
#import "GPKGCompressFormats.h"
#import "GPKGIOUtils.h"
#import "GPKGImageConverter.h"
#import "GPKGProgress.h"
#import "GPKGMapTolerance.h"
#import "GPKGMapUtils.h"
#import "GPKGFeatureInfoBuilder.h"
#import "GPKGStyleCache.h"
#import "GPKGStyleUtils.h"
#import "GPKGMetadata.h"
#import "GPKGMetadataDao.h"
#import "GPKGMetadataScope.h"
#import "GPKGMetadataReference.h"
#import "GPKGMetadataReferenceDao.h"
#import "GPKGProperties.h"
#import "GPKGPropertyConstants.h"
#import "GPKGDataColumns.h"
#import "GPKGDataColumnsDao.h"
#import "GPKGDataColumnConstraints.h"
#import "GPKGDataColumnConstraintsDao.h"
#import "GPKGColor.h"
#import "GPKGColorConstants.h"
#import "GPKGColorUtils.h"
#import "GPKGTileBoundingBoxUtils.h"
#import "GPKGTileGenerator.h"
#import "GPKGTileGrid.h"
#import "GPKGTileUtils.h"
#import "GPKGUrlTileGenerator.h"
#import "GPKGCustomFeaturesTile.h"
#import "GPKGFeatureTileContext.h"
#import "GPKGFeatureTileGenerator.h"
#import "GPKGFeatureTilePointIcon.h"
#import "GPKGFeatureTiles.h"
#import "GPKGNumberFeaturesTile.h"
#import "GPKGTileMatrix.h"
#import "GPKGTileMatrixDao.h"
#import "GPKGTileMatrixSet.h"
#import "GPKGTileMatrixSetDao.h"
#import "GPKGBoundedOverlay.h"
#import "GPKGCompositeOverlay.h"
#import "GPKGFeatureOverlay.h"
#import "GPKGFeatureOverlayQuery.h"
#import "GPKGFeatureRowData.h"
#import "GPKGFeatureTableData.h"
#import "GPKGGeoPackageOverlay.h"
#import "GPKGOverlayFactory.h"
#import "GPKGXYZOverlay.h"
#import "GPKGGeoPackageTile.h"
#import "GPKGGeoPackageTileRetriever.h"
#import "GPKGXYZTileRetriever.h"
#import "GPKGTileCreator.h"
#import "GPKGTileRetriever.h"
#import "GPKGTileColumn.h"
#import "GPKGTileDao.h"
#import "GPKGTileDaoUtils.h"
#import "GPKGTileRow.h"
#import "GPKGTileTable.h"
#import "GPKGTileTableReader.h"
#import "GPKGContentValues.h"
#import "GPKGUserColumn.h"
#import "GPKGUserDao.h"
#import "GPKGUserRow.h"
#import "GPKGUserRowSync.h"
#import "GPKGUserTable.h"
#import "GPKGUserTableReader.h"
#import "GPKGUserCustomColumn.h"
#import "GPKGUserCustomDao.h"
#import "GPKGUserCustomRow.h"
#import "GPKGUserCustomTable.h"
#import "GPKGUserCustomTableReader.h"
#import "GPKGGeoPackageValidate.h"
#import "GPKGUserColumns.h"
#import "GPKGAttributesColumns.h"
#import "GPKGFeatureColumns.h"
#import "GPKGTileColumns.h"
#import "GPKGUserCustomColumns.h"
#import "GPKGFeatureIndexLocation.h"
#import "GPKGFeatureIndexerIdQuery.h"
#import "GPKGFeatureIndexerIdResultSet.h"
#import "GPKGFeaturePreview.h"
#import "GPKGUserTableMetadata.h"
#import "GPKGAttributesTableMetadata.h"
#import "GPKGConstraints.h"
#import "GPKGExtensionManagement.h"
#import "GPKGContentsIdTableCreator.h"
#import "GPKGGeometryIndexTableCreator.h"
#import "GPKGFeatureTileLinkTableCreator.h"
#import "GPKGTileScalingTableCreator.h"
#import "GPKGMediaTableMetadata.h"
#import "GPKGSimpleAttributesTableMetadata.h"
#import "GPKGFeatureTableMetadata.h"
#import "GPKGTileTableMetadata.h"
#import "GPKGNGATableCreator.h"
#import "GPKGTileReprojection.h"
#import "GPKGTileReprojectionZoom.h"
#import "GPKGTileReprojectionOptimize.h"
#import "GPKGPlatteCarreOptimize.h"
#import "GPKGWebMercatorOptimize.h"
#import "GPKGNetworkUtils.h"
#import "GPKGPagination.h"

#endif /* geopackage_ios_Bridging_Header_h */
