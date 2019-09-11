//
//  GPKGConstraintParser.m
//  geopackage-ios
//
//  Created by Brian Osborn on 9/3/19.
//  Copyright © 2019 NGA. All rights reserved.
//

#import "GPKGConstraintParser.h"
#import "GPKGRawConstraint.h"

/**
 * Constraint name regex
 */
NSString *const CONSTRAINT_NAME_REGEX = @"(?i)(?s)^CONSTRAINT\\s+(\".+\"|\\S+)\\s";

/**
 * Constraint name and definition regex
 */
NSString *const CONSTRAINT_REGEX = @"(?i)(?s)^(CONSTRAINT\\s+(\".+\"|\\S+)\\s)?(.*)";

/**
 * Constraint name pattern name matcher group
 */
int const NAME_EXPRESSION_NAME_GROUP = 1;

/**
 * Constraint name and definition pattern name matcher group
 */
int const CONSTRAINT_EXPRESSION_NAME_GROUP = 2;

/**
 * Constraint name and definition pattern definition matcher group
 */
int const CONSTRAINT_EXPRESSION_DEFINITION_GROUP = 3;


@implementation GPKGConstraintParser

static NSRegularExpression *nameExpression = nil;
static NSRegularExpression *constraintExpression = nil;

+(void) initialize{
    if(nameExpression == nil){
        NSError  *error = nil;
        nameExpression = [NSRegularExpression regularExpressionWithPattern:CONSTRAINT_NAME_REGEX options:0 error:nil];
        if(error){
            [NSException raise:@"Name Regular Expression" format:@"Failed to create name regular expression with error: %@", error];
        }
        error = nil;
        constraintExpression = [NSRegularExpression regularExpressionWithPattern:CONSTRAINT_REGEX options:0 error:nil];
        if(error){
            [NSException raise:@"Constraint Regular Expression" format:@"Failed to create constraint regular expression with error: %@", error];
        }
    }
}

+(GPKGTableConstraints *) tableConstraintsForSQL: (NSString *) tableSql{

    GPKGTableConstraints *constraints = [[GPKGTableConstraints alloc] init];
    
    // Find the start and end of the column definitions and table
    // constraints
    NSInteger start = NSNotFound;
    NSInteger end = NSNotFound;
    if (tableSql != nil) {
        start = [tableSql rangeOfString:@"("].location;
        end = [tableSql rangeOfString:@")" options:NSBackwardsSearch].location;
    }
    
    if (start != NSNotFound && end != NSNotFound) {
        
        NSString *definitions = [[tableSql substringWithRange:NSMakeRange(start + 1, (end - start) - 1)] lowercaseString];
        
        // Parse the column definitions and table constraints, divided by
        // columns when not within parentheses. Create constraints when
        // found.
        int openParentheses = 0;
        int sqlStart = 0;
        
        for (int i = 0; i < definitions.length; i++) {
            unichar character = [definitions characterAtIndex:i];
            if (character == '(') {
                openParentheses++;
            } else if (character == ')') {
                openParentheses--;
            } else if (character == ',' && openParentheses == 0) {
                NSString *constraintSql = [definitions substringWithRange:NSMakeRange(sqlStart, i - sqlStart)];
                [self addConstraints:constraints withSQL:constraintSql];
                sqlStart = i + 1;
            }
        }
        if(sqlStart < definitions.length){
            NSString *constraintSql = [definitions substringWithRange:NSMakeRange(sqlStart, definitions.length - sqlStart)];
            [self addConstraints:constraints withSQL:constraintSql];
        }
    }
    
    return constraints;
}

/**
 * Add constraints of the optional type or all constraints
 *
 * @param constraints
 *            constraints to add to
 * @param constraintSQL
 *            constraint SQL statement
 */
+(void) addConstraints: (GPKGTableConstraints *) constraints withSQL: (NSString *) constraintSql{
    GPKGConstraint *constraint = [self tableConstraintForSQL:constraintSql];
    if(constraint != nil){
        [constraints addTableConstraint:constraint];
    }else{
        GPKGColumnConstraints *columnConstraints = [self columnConstraintsForSQL:constraintSql];
        if([columnConstraints hasConstraints]){
            [constraints addColumnConstraints:columnConstraints];
        }
    }
}

+(GPKGColumnConstraints *) columnConstraintsForSQL: (NSString *) constraintSql{
    return nil; // TODO
}

/**
 * Create a constraint from the SQL parts with the range for the type
 *
 * @param parts
 *            SQL parts
 * @param startIndex
 *            start index (inclusive)
 * @param endIndex
 *            end index (exclusive)
 * @param type
 *            constraint type
 * @return constraint
 */
+(GPKGConstraint *) createConstraintWithParts: (NSArray<NSString *> *) parts andStartIndex: (int) startIndex andEndIndex: (int) endIndex andType: (enum GPKGConstraintType) type{
    
    NSMutableString *sql = [[NSMutableString alloc] init];
    for (int i = startIndex; i < endIndex; i++) {
        if (sql.length > 0) {
            [sql appendString:@" "];
        }
        [sql appendString:[parts objectAtIndex:i]];
    }
    
    NSString *name = [self nameForSQL:sql];
    
    return [[GPKGRawConstraint alloc] initWithType:type andName:name andSql:sql];
}

/**
 * Attempt to get the constraint by parsing the SQL statement
 *
 * @param constraintSql
 *            constraint SQL statement
 * @param table
 *            true to search for a table constraint, false to search for a
 *            column constraint
 * @return constraint or null
 */
+(GPKGConstraint *) constraintForSQL: (NSString *) constraintSql asTable: (BOOL) table{
    
    GPKGConstraint *constraint = nil;
    
    NSArray<NSString *> *nameAndDefinition = [self nameAndDefinitionForSQL:constraintSql];
    
    NSString *definition = [nameAndDefinition objectAtIndex:1];
    if(definition != nil){
        
        NSArray<NSString *> *parts = [definition componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray<NSString *> *filteredParts = [parts filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
        NSString *prefix = [filteredParts objectAtIndex:0];
        enum GPKGConstraintType type = -1;
        if(table){
            type = [GPKGConstraintTypes tableTypeOfValue:prefix];
        }else{
            type = [GPKGConstraintTypes columnTypeOfValue:prefix];
        }
        
        if((int)type >= 0){
            constraint = [[GPKGRawConstraint alloc] initWithType:type andName:[nameAndDefinition objectAtIndex:0] andSql:[constraintSql lowercaseString]];
        }
    }
    
    return constraint;
}

+(GPKGConstraint *) tableConstraintForSQL: (NSString *) constraintSql{
    return [self constraintForSQL:constraintSql asTable:YES];
}

+(BOOL) isTableConstraint: (NSString *) constraintSql{
    return [self tableConstraintForSQL:constraintSql] != nil;
}

+(enum GPKGConstraintType) tableTypeForSQL: (NSString *) constraintSql{
    enum GPKGConstraintType type = -1;
    GPKGConstraint *constraint = [self tableConstraintForSQL:constraintSql];
    if(constraint != nil){
        type = constraint.type;
    }
    return type;
}

+(BOOL) isTableSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type{
    BOOL isType = NO;
    enum GPKGConstraintType constraintType = [self tableTypeForSQL:constraintSql];
    if ((int)constraintType >= 0) {
        isType = type == constraintType;
    }
    return isType;
}

+(GPKGConstraint *) columnConstraintForSQL: (NSString *) constraintSql{
    return [self constraintForSQL:constraintSql asTable:NO];
}

+(BOOL) isColumnConstraint: (NSString *) constraintSql{
    return [self columnConstraintForSQL:constraintSql] != nil;
}

+(enum GPKGConstraintType) columnTypeForSQL: (NSString *) constraintSql{
    enum GPKGConstraintType type = -1;
    GPKGConstraint *constraint = [self columnConstraintForSQL:constraintSql];
    if(constraint != nil){
        type = constraint.type;
    }
    return type;
}

+(BOOL) isColumnSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type{
    BOOL isType = NO;
    enum GPKGConstraintType constraintType = [self columnTypeForSQL:constraintSql];
    if ((int)constraintType >= 0) {
        isType = type == constraintType;
    }
    return isType;
}

+(GPKGConstraint *) constraintForSQL: (NSString *) constraintSql{
    GPKGConstraint *constraint = [self tableConstraintForSQL:constraintSql];
    if (constraint == nil) {
        constraint = [self columnConstraintForSQL:constraintSql];
    }
    return constraint;
}

+(BOOL) isConstraint: (NSString *) constraintSql{
    return [self constraintForSQL:constraintSql] != nil;
}

+(enum GPKGConstraintType) typeForSQL: (NSString *) constraintSql{
    enum GPKGConstraintType type = -1;
    GPKGConstraint *constraint = [self constraintForSQL:constraintSql];
    if (constraint != nil) {
        type = constraint.type;
    }
    return type;
}

+(BOOL) isSQL: (NSString *) constraintSql type: (enum GPKGConstraintType) type{
    BOOL isType = NO;
    enum GPKGConstraintType constraintType = [self typeForSQL:constraintSql];
    if ((int)constraintType >= 0) {
        isType = type == constraintType;
    }
    return isType;
}

+(NSString *) nameForSQL: (NSString *) constraintSql{
    NSString *name = nil;
    /* TODO
    Matcher matcher = NAME_PATTERN.matcher(constraintSql);
    if (matcher.find()) {
        name = CoreSQLUtils
        .quoteUnwrap(matcher.group(NAME_PATTERN_NAME_GROUP));
    }
     */
    return name;
}

+(NSArray<NSString *> *) nameAndDefinitionForSQL: (NSString *) constraintSql{
    NSArray<NSString *> *parts = nil;
    /* TODO
    Matcher matcher = CONSTRAINT_PATTERN.matcher(constraintSql.trim());
    if (matcher.find()) {
        String name = CoreSQLUtils
        .quoteUnwrap(matcher.group(CONSTRAINT_PATTERN_NAME_GROUP));
        if (name != null) {
            name = name.trim();
        }
        String definition = matcher
        .group(CONSTRAINT_PATTERN_DEFINITION_GROUP);
        if (definition != null) {
            definition = definition.trim();
        }
        parts = new String[] { name, definition };
    }
     */
    return parts;
}

@end
