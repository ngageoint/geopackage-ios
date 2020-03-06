//
//  GPKGFeatureTableStyles.m
//  geopackage-ios
//
//  Created by Brian Osborn on 1/17/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGFeatureTableStyles.h"

@interface GPKGFeatureTableStyles ()

@property (nonatomic, strong) GPKGFeatureStyleExtension *featureStyleExtension;
@property (nonatomic, strong) NSString *tableName;
@property (nonatomic, strong) GPKGFeatureStyles *cachedTableFeatureStyles;

@end

@implementation GPKGFeatureTableStyles

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTable: (GPKGFeatureTable *) featureTable{
    return [self initWithGeoPackage:geoPackage andTableName:featureTable.tableName];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andGeometryColumns: (GPKGGeometryColumns *) geometryColumns{
    return [self initWithGeoPackage:geoPackage andTableName:geometryColumns.tableName];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andContents: (GPKGContents *) contents{
    return [self initWithGeoPackage:geoPackage andTableName:contents.tableName];
}

-(instancetype) initWithGeoPackage: (GPKGGeoPackage *) geoPackage andTableName: (NSString *) featureTable{
    self = [super init];
    if(self != nil){
        self.featureStyleExtension = [[GPKGFeatureStyleExtension alloc] initWithGeoPackage:geoPackage];
        self.tableName = featureTable;
        self.cachedTableFeatureStyles = [[GPKGFeatureStyles alloc] init];
        if(![geoPackage isFeatureTable:featureTable]){
            [NSException raise:@"Table Type" format:@"Table must be a feature table. Table: %@, ActualType: %@", featureTable, [geoPackage typeOfTable:featureTable]];
        }
    }
    return self;
}

-(GPKGFeatureStyleExtension *) featureStyleExtension{
    return _featureStyleExtension;
}

-(NSString *) tableName{
    return _tableName;
}

-(BOOL) has{
    return [self.featureStyleExtension hasWithTable:self.tableName];
}

-(void) createRelationships{
    [self.featureStyleExtension createRelationshipsWithTable:self.tableName];
}

-(BOOL) hasRelationship{
    return [self.featureStyleExtension hasRelationshipWithTable:self.tableName];
}

-(void) createStyleRelationship{
    [self.featureStyleExtension createStyleRelationshipWithTable:self.tableName];
}

-(BOOL) hasStyleRelationship{
    return [self.featureStyleExtension hasStyleRelationshipWithTable:self.tableName];
}

-(void) createTableStyleRelationship{
    [self.featureStyleExtension createTableStyleRelationshipWithTable:self.tableName];
}

-(BOOL) hasTableStyleRelationship{
    return [self.featureStyleExtension hasTableStyleRelationshipWithTable:self.tableName];
}

-(void) createIconRelationship{
    [self.featureStyleExtension createIconRelationshipWithTable:self.tableName];
}

-(BOOL) hasIconRelationship{
    return [self.featureStyleExtension hasIconRelationshipWithTable:self.tableName];
}

-(void) createTableIconRelationship{
    [self.featureStyleExtension createTableIconRelationshipWithTable:self.tableName];
}

-(BOOL) hasTableIconRelationship{
    return [self.featureStyleExtension hasTableIconRelationshipWithTable:self.tableName];
}

-(void) deleteRelationships{
    [self.featureStyleExtension deleteRelationshipsWithTable:self.tableName];
}

-(void) deleteStyleRelationship{
    [self.featureStyleExtension deleteStyleRelationshipWithTable:self.tableName];
}

-(void) deleteTableStyleRelationship{
    [self.featureStyleExtension deleteStyleRelationshipWithTable:self.tableName];
}

-(void) deleteIconRelationship{
    [self.featureStyleExtension deleteIconRelationshipWithTable:self.tableName];
}

-(void) deleteTableIconRelationship{
    [self.featureStyleExtension deleteTableIconRelationshipWithTable:self.tableName];
}

-(GPKGStyleMappingDao *) styleMappingDao{
    return [self.featureStyleExtension styleMappingDaoWithTable:self.tableName];
}

-(GPKGStyleMappingDao *) tableStyleMappingDao{
    return [self.featureStyleExtension tableStyleMappingDaoWithTable:self.tableName];
}

-(GPKGStyleMappingDao *) iconMappingDao{
    return [self.featureStyleExtension iconMappingDaoWithTable:self.tableName];
}

-(GPKGStyleMappingDao *) tableIconMappingDao{
    return [self.featureStyleExtension tableIconMappingDaoWithTable:self.tableName];
}

-(GPKGStyleDao *) styleDao{
    return [self.featureStyleExtension styleDao];
}

-(GPKGIconDao *) iconDao{
    return [self.featureStyleExtension iconDao];
}

-(GPKGFeatureStyles *) tableFeatureStyles{
    return [self.featureStyleExtension tableFeatureStylesWithTableName:self.tableName];
}

-(GPKGStyles *) tableStyles{
    return [self.featureStyleExtension tableStylesWithTableName:self.tableName];
}

-(GPKGStyles *) cachedTableStyles{
    
    GPKGStyles *styles = self.cachedTableFeatureStyles.styles;
    
    if (styles == nil) {
        @synchronized(self.cachedTableFeatureStyles) {
            styles = self.cachedTableFeatureStyles.styles;
            if (styles == nil) {
                styles = [self tableStyles];
                if (styles == nil) {
                    styles = [[GPKGStyles alloc] initAsTableStyles:YES];
                }
                [self.cachedTableFeatureStyles setStyles:styles];
            }
        }
    }
    
    if ([styles isEmpty]) {
        styles = nil;
    }
    
    return styles;
}

-(GPKGStyleRow *) tableStyleWithGeometryType: (enum SFGeometryType) geometryType{
    return [self.featureStyleExtension tableStyleWithTableName:self.tableName andGeometryType:geometryType];
}

-(GPKGStyleRow *) tableStyleDefault{
    return [self.featureStyleExtension tableStyleDefaultWithTableName:self.tableName];
}

-(GPKGIcons *) tableIcons{
    return [self.featureStyleExtension tableIconsWithTableName:self.tableName];
}

-(GPKGIcons *) cachedTableIcons{
    
    GPKGIcons *icons = self.cachedTableFeatureStyles.icons;
    
    if (icons == nil) {
        @synchronized(self.cachedTableFeatureStyles) {
            icons = self.cachedTableFeatureStyles.icons;
            if (icons == nil) {
                icons = [self tableIcons];
                if (icons == nil) {
                    icons = [[GPKGIcons alloc] initAsTableIcons:YES];
                }
                [self.cachedTableFeatureStyles setIcons:icons];
            }
        }
    }
    
    if ([icons isEmpty]) {
        icons = nil;
    }
    
    return icons;
}

-(GPKGIconRow *) tableIconWithGeometryType: (enum SFGeometryType) geometryType{
    return [self.featureStyleExtension tableIconWithTableName:self.tableName andGeometryType:geometryType];
}

-(GPKGIconRow *) tableIconDefault{
    return [self.featureStyleExtension tableIconDefaultWithTableName:self.tableName];
}

-(GPKGFeatureStyles *) featureStylesWithFeature: (GPKGFeatureRow *) featureRow{
    return [self.featureStyleExtension featureStylesWithFeature:featureRow];
}

-(GPKGFeatureStyles *) featureStylesWithId: (int) featureId{
    return [self.featureStyleExtension featureStylesWithTableName:self.tableName andId:featureId];
}

-(GPKGFeatureStyles *) featureStylesWithIdNumber: (NSNumber *) featureId{
    return [self featureStylesWithId:[featureId intValue]];
}

-(GPKGFeatureStyle *) featureStyleWithFeature: (GPKGFeatureRow *) featureRow{
    return [self featureStyleWithFeature:featureRow andGeometryType:[featureRow geometryType]];
}

-(GPKGFeatureStyle *) featureStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    return [self featureStyleWithId:[featureRow idValue] andGeometryType:geometryType];
}

-(GPKGFeatureStyle *) featureStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    return [self featureStyleWithId:[featureRow idValue] andGeometryType:SF_NONE];
}

-(GPKGFeatureStyle *) featureStyleWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{

    GPKGFeatureStyle *featureStyle = nil;
    
    GPKGStyleRow *style = [self styleWithId:featureId andGeometryType:geometryType];
    GPKGIconRow *icon = [self iconWithId:featureId andGeometryType:geometryType];
    
    if (style != nil || icon != nil) {
        featureStyle = [[GPKGFeatureStyle alloc] initWithStyle:style andIcon:icon];
    }
    
    return featureStyle;
}

-(GPKGFeatureStyle *) featureStyleWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    return [self featureStyleWithId:[featureId intValue] andGeometryType:geometryType];
}

-(GPKGFeatureStyle *) featureStyleDefaultWithId: (int) featureId{
    return [self featureStyleWithId:featureId andGeometryType:SF_NONE];
}

-(GPKGFeatureStyle *) featureStyleDefaultWithIdNumber: (NSNumber *) featureId{
    return [self featureStyleDefaultWithId:[featureId intValue]];
}

-(GPKGStyles *) stylesWithFeature: (GPKGFeatureRow *) featureRow{
    return [self.featureStyleExtension stylesWithFeature:featureRow];
}

-(GPKGStyles *) stylesWithId: (int) featureId{
    return [self.featureStyleExtension stylesWithTableName:self.tableName andId:featureId];
}

-(GPKGStyles *) stylesWithIdNumber: (NSNumber *) featureId{
    return [self stylesWithId:[featureId intValue]];
}

-(GPKGStyleRow *) styleWithFeature: (GPKGFeatureRow *) featureRow{
    return [self styleWithFeature:featureRow andGeometryType:[featureRow geometryType]];
}

-(GPKGStyleRow *) styleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    return [self styleWithId:[featureRow idValue] andGeometryType:geometryType];
}

-(GPKGStyleRow *) styleDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    return [self styleWithId:[featureRow idValue] andGeometryType:SF_NONE];
}

-(GPKGStyleRow *) styleWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    
    GPKGStyleRow *styleRow = [self.featureStyleExtension styleWithTableName:self.tableName andId:featureId andGeometryType:geometryType andTableStyle:NO];
    
    if (styleRow == nil) {
        
        // Table Style
        GPKGStyles *styles = [self cachedTableStyles];
        if (styles != nil) {
            styleRow = [styles styleForGeometryType:geometryType];
        }
        
    }
    
    return styleRow;
}

-(GPKGStyleRow *) styleWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    return [self styleWithId:[featureId intValue] andGeometryType:geometryType];
}

-(GPKGStyleRow *) styleDefaultWithId: (int) featureId{
    return [self styleWithId:featureId andGeometryType:SF_NONE];
}

-(GPKGStyleRow *) styleDefaultWithIdNumber: (NSNumber *) featureId{
    return [self styleDefaultWithId:[featureId intValue]];
}

-(GPKGIcons *) iconsWithFeature: (GPKGFeatureRow *) featureRow{
    return [self.featureStyleExtension iconsWithFeature:featureRow];
}

-(GPKGIcons *) iconsWithId: (int) featureId{
    return [self.featureStyleExtension iconsWithTableName:self.tableName andId:featureId];
}

-(GPKGIcons *) iconsWithIdNumber: (NSNumber *) featureId{
    return [self iconsWithId:[featureId intValue]];
}

-(GPKGIconRow *) iconWithFeature: (GPKGFeatureRow *) featureRow{
    return [self iconWithFeature:featureRow andGeometryType:[featureRow geometryType]];
}

-(GPKGIconRow *) iconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    return [self iconWithId:[featureRow idValue] andGeometryType:geometryType];
}

-(GPKGIconRow *) iconDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    return [self iconWithId:[featureRow idValue] andGeometryType:SF_NONE];
}

-(GPKGIconRow *) iconWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    
    GPKGIconRow *iconRow = [self.featureStyleExtension iconWithTableName:self.tableName andId:featureId andGeometryType:geometryType andTableIcon:NO];
    
    if (iconRow == nil) {
        
        // Table Icon
        GPKGIcons *icons = [self cachedTableIcons];
        if (icons != nil) {
            iconRow = [icons iconForGeometryType:geometryType];
        }
        
    }
    
    return iconRow;
}

-(GPKGIconRow *) iconWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    return [self iconWithId:[featureId intValue] andGeometryType:geometryType];
}

-(GPKGIconRow *) iconDefaultWithId: (int) featureId{
    return [self iconWithId:featureId andGeometryType:SF_NONE];
}

-(GPKGIconRow *) iconDefaultWithIdNumber: (NSNumber *) featureId{
    return [self iconDefaultWithId:[featureId intValue]];
}

-(void) setTableFeatureStyles: (GPKGFeatureStyles *) featureStyles{
    [self.featureStyleExtension setTableFeatureStylesWithTableName:self.tableName andFeatureStyles:featureStyles];
    [self clearCachedTableFeatureStyles];
}

-(void) setTableStyles: (GPKGStyles *) styles{
    [self.featureStyleExtension setTableStylesWithTableName:self.tableName andStyles:styles];
    [self clearCachedTableStyles];
}

-(void) setTableStyleDefault: (GPKGStyleRow *) style{
    [self.featureStyleExtension setTableStyleDefaultWithTableName:self.tableName andStyle:style];
    [self clearCachedTableStyles];
}

-(void) setTableStyle: (GPKGStyleRow *) style withGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setTableStyleWithTableName:self.tableName andGeometryType:geometryType andStyle:style];
    [self clearCachedTableStyles];
}

-(void) setTableIcons: (GPKGIcons *) icons{
    [self.featureStyleExtension setTableIconsWithTableName:self.tableName andIcons:icons];
    [self clearCachedTableIcons];
}

-(void) setTableIconDefault: (GPKGIconRow *) icon{
    [self.featureStyleExtension setTableIconDefaultWithTableName:self.tableName andIcon:icon];
    [self clearCachedTableIcons];
}

-(void) setTableIcon: (GPKGIconRow *) icon withGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setTableIconWithTableName:self.tableName andGeometryType:geometryType andIcon:icon];
    [self clearCachedTableIcons];
}

-(void) setFeatureStyles: (GPKGFeatureStyles *) featureStyles withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setFeatureStylesWithFeature:featureRow andFeatureStyles:featureStyles];
}

-(void) setFeatureStyles: (GPKGFeatureStyles *) featureStyles withId: (int) featureId{
    [self.featureStyleExtension setFeatureStylesWithTableName:self.tableName andId:featureId andFeatureStyles:featureStyles];
}

-(void) setFeatureStyles: (GPKGFeatureStyles *) featureStyles withIdNumber: (NSNumber *) featureId{
    [self setFeatureStyles:featureStyles withId:[featureId intValue]];
}

-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setFeatureStyleWithFeature:featureRow andFeatureStyle:featureStyle];
}

-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setFeatureStyleWithFeature:featureRow andGeometryType:geometryType andFeatureStyle:featureStyle];
}

-(void) setFeatureStyleDefault: (GPKGFeatureStyle *) featureStyle withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setFeatureStyleDefaultWithFeature:featureRow andFeatureStyle:featureStyle];
}

-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setFeatureStyleWithTableName:self.tableName andId:featureId andGeometryType:geometryType andFeatureStyle:featureStyle];
}

-(void) setFeatureStyle: (GPKGFeatureStyle *) featureStyle withIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self setFeatureStyle:featureStyle withId:[featureId intValue] andGeometryType:geometryType];
}

-(void) setFeatureStyleDefault: (GPKGFeatureStyle *) featureStyle withId: (int) featureId{
    [self.featureStyleExtension setFeatureStyleDefaultWithTableName:self.tableName andId:featureId andFeatureStyle:featureStyle];
}

-(void) setFeatureStyleDefault: (GPKGFeatureStyle *) featureStyle withIdNumber: (NSNumber *) featureId{
    [self setFeatureStyleDefault:featureStyle withId:[featureId intValue]];
}

-(void) setStyles: (GPKGStyles *) styles withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setStylesWithFeature:featureRow andStyles:styles];
}

-(void) setStyles: (GPKGStyles *) styles withId: (int) featureId{
    [self.featureStyleExtension setStylesWithTableName:self.tableName andId:featureId andStyles:styles];
}

-(void) setStyles: (GPKGStyles *) styles withIdNumber: (NSNumber *) featureId{
    [self setStyles:styles withId:[featureId intValue]];
}

-(void) setStyle: (GPKGStyleRow *) style withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setStyleWithFeature:featureRow andStyle:style];
}

-(void) setStyle: (GPKGStyleRow *) style withFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setStyleWithFeature:featureRow andGeometryType:geometryType andStyle:style];
}

-(void) setStyleDefault: (GPKGStyleRow *) style withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setStyleDefaultWithFeature:featureRow andStyle:style];
}

-(void) setStyle: (GPKGStyleRow *) style withId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setStyleWithTableName:self.tableName andId:featureId andGeometryType:geometryType andStyle:style];
}

-(void) setStyle: (GPKGStyleRow *) style withIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self setStyle:style withId:[featureId intValue] andGeometryType:geometryType];
}

-(void) setStyleDefault: (GPKGStyleRow *) style withId: (int) featureId{
    [self.featureStyleExtension setStyleDefaultWithTableName:self.tableName andId:featureId andStyle:style];
}

-(void) setStyleDefault: (GPKGStyleRow *) style withIdNumber: (NSNumber *) featureId{
    [self setStyleDefault:style withId:[featureId intValue]];
}

-(void) setIcons: (GPKGIcons *) icons withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setIconsWithFeature:featureRow andIcons:icons];
}

-(void) setIcons: (GPKGIcons *) icons withId: (int) featureId{
    [self.featureStyleExtension setIconsWithTableName:self.tableName andId:featureId andIcons:icons];
}

-(void) setIcons: (GPKGIcons *) icons withIdNumber: (NSNumber *) featureId{
    [self setIcons:icons withId:[featureId intValue]];
}

-(void) setIcon: (GPKGIconRow *) icon withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setIconWithFeature:featureRow andIcon:icon];
}

-(void) setIcon: (GPKGIconRow *) icon withFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setIconWithFeature:featureRow andGeometryType:geometryType andIcon:icon];
}

-(void) setIconDefault: (GPKGIconRow *) icon withFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension setIconDefaultWithFeature:featureRow andIcon:icon];
}

-(void) setIcon: (GPKGIconRow *) icon withId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension setIconWithTableName:self.tableName andId:featureId andGeometryType:geometryType andIcon:icon];
}

-(void) setIcon: (GPKGIconRow *) icon withIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self setIcon:icon withId:[featureId intValue] andGeometryType:geometryType];
}

-(void) setIconDefault: (GPKGIconRow *) icon withId: (int) featureId{
    [self.featureStyleExtension setIconDefaultWithTableName:self.tableName andId:featureId andIcon:icon];
}

-(void) setIconDefault: (GPKGIconRow *) icon withIdNumber: (NSNumber *) featureId{
    [self setIconDefault:icon withId:[featureId intValue]];
}

-(void) deleteAllFeatureStyles{
    [self.featureStyleExtension deleteAllFeatureStylesWithTableName:self.tableName];
    [self clearCachedTableFeatureStyles];
}

-(void) deleteAllStyles{
    [self.featureStyleExtension deleteAllStylesWithTableName:self.tableName];
    [self clearCachedTableStyles];
}

-(void) deleteAllIcons{
    [self.featureStyleExtension deleteAllIconsWithTableName:self.tableName];
    [self clearCachedTableIcons];
}

-(void) deleteTableFeatureStyles{
    [self.featureStyleExtension deleteTableFeatureStylesWithTableName:self.tableName];
    [self clearCachedTableFeatureStyles];
}

-(void) deleteTableStyles{
    [self.featureStyleExtension deleteTableStylesWithTableName:self.tableName];
    [self clearCachedTableStyles];
}

-(void) deleteTableStyleDefault{
    [self.featureStyleExtension deleteTableStyleDefaultWithTableName:self.tableName];
    [self clearCachedTableStyles];
}

-(void) deleteTableStyleWithGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension deleteTableStyleWithTableName:self.tableName andGeometryType:geometryType];
    [self clearCachedTableStyles];
}

-(void) deleteTableIcons{
    [self.featureStyleExtension deleteTableIconsWithTableName:self.tableName];
    [self clearCachedTableIcons];
}

-(void) deleteTableIconDefault{
    [self.featureStyleExtension deleteTableIconDefaultWithTableName:self.tableName];
    [self clearCachedTableIcons];
}

-(void) deleteTableIconWithGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension deleteTableIconWithTableName:self.tableName andGeometryType:geometryType];
    [self clearCachedTableIcons];
}

-(void) clearCachedTableFeatureStyles{
    @synchronized (self.cachedTableFeatureStyles) {
        [self.cachedTableFeatureStyles setStyles:nil];
        [self.cachedTableFeatureStyles setIcons:nil];
    }
}

-(void) clearCachedTableStyles{
    @synchronized (self.cachedTableFeatureStyles) {
        [self.cachedTableFeatureStyles setStyles:nil];
    }
}

-(void) clearCachedTableIcons{
    @synchronized (self.cachedTableFeatureStyles) {
        [self.cachedTableFeatureStyles setIcons:nil];
    }
}

-(void) deleteFeatureStyles{
    [self.featureStyleExtension deleteFeatureStylesWithTableName:self.tableName];
}

-(void) deleteStyles{
    [self.featureStyleExtension deleteStylesWithTableName:self.tableName];
}

-(void) deleteStylesWithFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension deleteStylesWithFeature:featureRow];
}

-(void) deleteStylesWithId: (int) featureId{
    [self.featureStyleExtension deleteStylesWithTableName:self.tableName andId:featureId];
}

-(void) deleteStylesWithIdNumber: (NSNumber *) featureId{
    [self deleteStylesWithId:[featureId intValue]];
}

-(void) deleteStyleDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension deleteStyleDefaultWithFeature:featureRow];
}

-(void) deleteStyleDefaultWithId: (int) featureId{
    [self.featureStyleExtension deleteStyleDefaultWithTableName:self.tableName andId:featureId];
}

-(void) deleteStyleDefaultWithIdNumber: (NSNumber *) featureId{
    [self deleteStyleDefaultWithId:[featureId intValue]];
}

-(void) deleteStyleWithFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension deleteStyleWithFeature:featureRow];
}

-(void) deleteStyleWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension deleteStyleWithFeature:featureRow andGeometryType:geometryType];
}

-(void) deleteStyleWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension deleteStyleWithTableName:self.tableName andId:featureId andGeometryType:geometryType];
}

-(void) deleteStyleWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteStyleWithId:[featureId intValue] andGeometryType:geometryType];
}

-(void) deleteIcons{
    [self.featureStyleExtension deleteIconsWithTableName:self.tableName];
}

-(void) deleteIconsWithFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension deleteIconsWithFeature:featureRow];
}

-(void) deleteIconsWithId: (int) featureId{
    [self.featureStyleExtension deleteIconsWithTableName:self.tableName andId:featureId];
}

-(void) deleteIconsWithIdNumber: (NSNumber *) featureId{
    [self deleteIconsWithId:[featureId intValue]];
}

-(void) deleteIconDefaultWithFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension deleteIconDefaultWithFeature:featureRow];
}

-(void) deleteIconDefaultWithId: (int) featureId{
    [self.featureStyleExtension deleteIconDefaultWithTableName:self.tableName andId:featureId];
}

-(void) deleteIconDefaultWithIdNumber: (NSNumber *) featureId{
    [self deleteIconDefaultWithId:[featureId intValue]];
}

-(void) deleteIconWithFeature: (GPKGFeatureRow *) featureRow{
    [self.featureStyleExtension deleteIconWithFeature:featureRow];
}

-(void) deleteIconWithFeature: (GPKGFeatureRow *) featureRow andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension deleteIconWithFeature:featureRow andGeometryType:geometryType];
}

-(void) deleteIconWithId: (int) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self.featureStyleExtension deleteIconWithTableName:self.tableName andId:featureId andGeometryType:geometryType];
}

-(void) deleteIconWithIdNumber: (NSNumber *) featureId andGeometryType: (enum SFGeometryType) geometryType{
    [self deleteIconWithId:[featureId intValue] andGeometryType:geometryType];
}

-(NSArray<NSNumber *> *) allTableStyleIds{
    return [self.featureStyleExtension allTableStyleIdsWithTableName:self.tableName];
}

-(NSArray<NSNumber *> *) allTableIconIds{
    return [self.featureStyleExtension allTableIconIdsWithTableName:self.tableName];
}

-(NSArray<NSNumber *> *) allStyleIds{
    return [self.featureStyleExtension allStyleIdsWithTableName:self.tableName];
}

-(NSArray<NSNumber *> *) allIconIds{
    return [self.featureStyleExtension allIconIdsWithTableName:self.tableName];
}

@end
