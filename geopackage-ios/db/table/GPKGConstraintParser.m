//
//  GPKGConstraintParser.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraintParser.h"

@implementation GPKGConstraintParser

+(GPKGTableConstraints *) tableConstraintsForSQL: (NSString *) tableSql{
    return nil; // TODO
}

+(GPKGColumnConstraints *) columnConstraintsForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

+(GPKGConstraint *) tableConstraintForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

+(BOOL) isTableConstraint: (NSString *) constraintSql{
    return NO; // TODO
}

+(enum GPKGConstraintType) tableTypeForSQL: (NSString *) constraintSql{
    return -1; // TODO
}

-(BOOL) isTableSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type{
    return NO; // TODO
}

+(GPKGConstraint *) columnConstraintForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

+(BOOL) isColumnConstraint: (NSString *) constraintSql{
    return nil; // TODO
}

+(enum GPKGConstraintType) columnTypeForSQL: (NSString *) constraintSql{
    return -1; // TODO
}

-(BOOL) isColumnSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type{
    return NO; // TODO
}

+(GPKGConstraint *) constraintForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

+(BOOL) isConstraint: (NSString *) constraintSql{
    return NO; // TODO
}

+(enum GPKGConstraintType) typeForSQL: (NSString *) constraintSql{
    return -1; // TODO
}

-(BOOL) isSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type{
    return NO; // TODO
}

+(NSString *) nameForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

+(NSArray<NSString *> *) nameAndDefinitionForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

@end
