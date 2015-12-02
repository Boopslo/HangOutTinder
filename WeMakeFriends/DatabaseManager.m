//
//  DatabaseManager.m
//  WeMakeFriends
//
//  Created by Oslo on 11/1/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager ()

@property NSMutableArray *arrayResult;

-(void) runQuery:(const char *)query isQueryExecutable:(BOOL)isExecutable;

@end


@implementation DatabaseManager

-(instancetype)initWithDatabaseFilename:(NSString *)databaseName {
    self = [super init];
    if (self) {
        //specify the path to the documents directory of the app
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        self.documentDir = [path objectAtIndex:0];
        // store database filename as argument  to another property
        self.databaseFilename = databaseName;
        // copy database file from app bundle to the documents directory
        [self copyDatabaseIntoDocumentDir];
    }
    return self;
}

-(void)copyDatabaseIntoDocumentDir {
    NSString *destinationPath = [self.documentDir stringByAppendingPathComponent:self.databaseFilename];
    // check if the database file exists in the documents dir or not, if not, we copy from app bundle
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]) {
        // create the path at mainBundle to copy from
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:self.databaseFilename];
        NSError *error;
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:destinationPath error:&error];
        // print error message out if any
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

-(void)runQuery:(const char *)query isQueryExecutable:(BOOL)isExecutable {
    sqlite3 *sqliteDB ;
    // set the database path to where the database file is
    NSString *dbPath = [self.documentDir stringByAppendingPathComponent:self.databaseFilename];
    // initialize the array result mutable array
    if (_arrayResult != nil) {
        [self.arrayResult removeAllObjects];
        self.arrayResult = nil;
    }
    self.arrayResult = [[NSMutableArray alloc] init];
    
    if (self.columnNames != nil) {
        [self.columnNames removeAllObjects];
        self.columnNames = nil;
    }
    self.columnNames = [[NSMutableArray alloc] init];
    
    // need to open the database to make usage
    BOOL isOpen = sqlite3_open([dbPath UTF8String], &sqliteDB);
    // successfully opened
    if (isOpen == SQLITE_OK) {
        sqlite3_stmt *compileStatement;
        // load all data from the database to memory
        BOOL prepareStatement = sqlite3_prepare_v2(sqliteDB, query, -1, &compileStatement, NULL);
        if (prepareStatement == SQLITE_OK) {
            // if the query is not executable, means that it is really querying the data
            if (!isExecutable) {
                // temp array to collect data
                NSMutableArray *tempArray = [[NSMutableArray alloc] init];
                
                // loop through the database row by row, use the sqlite3_step function
                while (sqlite3_step(compileStatement) == SQLITE_ROW) {
                    // re-initialize it every loop
                    tempArray = [[NSMutableArray alloc] init];
                    int totalColumns = sqlite3_column_count(compileStatement) ;
                    for (int i = 0; i < totalColumns; i++) {
                        // use standard C way to store strings: char *
                        char *databaseDataChars = (char *)sqlite3_column_text(compileStatement, i);
                        // add contents in the columns to the temp array, waiting to store in results array
                        if (databaseDataChars != NULL) {
                            [tempArray addObject:[NSString stringWithUTF8String:databaseDataChars]];
                        }
                        
                        // keep the columns names reserved
                        if (self.columnNames.count != totalColumns) {
                            databaseDataChars = (char *)sqlite3_column_name(compileStatement, i);
                            [self.columnNames addObject:[NSString stringWithUTF8String:databaseDataChars]];
                        }
                    }
                    
                    // store each row into the temp array
                    if (tempArray.count > 0) {
                        [self.arrayResult addObject:tempArray];
                    }
                }
            } else {
                // if the query is exexcutable, means it is an insert, update or delete statement
                
                // execute the query
                int executeQuery = sqlite3_step(compileStatement);
                if (executeQuery == SQLITE_DONE) {
                    self.updatedRows = sqlite3_changes(sqliteDB);
                    self.lastInsertedRowID = sqlite3_last_insert_rowid(sqliteDB);
                } else {
                    NSLog(@"execute query failed: %s", sqlite3_errmsg(sqliteDB));
                }
            }
        } else {
            NSLog(@"prepare failed: %s", sqlite3_errmsg(sqliteDB));
        }
        sqlite3_finalize(compileStatement);
    } else {
        NSLog(@"open database failed: %s", sqlite3_errmsg(sqliteDB));
    }
    // close the database after using it
    sqlite3_close(sqliteDB);
}


-(NSArray *)loadDatafromDB:(NSString *)query {
    [self runQuery:[query UTF8String] isQueryExecutable:NO];
    return (NSArray *)_arrayResult;
}

-(void)executeQuery:(NSString *)query {
    [self runQuery:[query UTF8String] isQueryExecutable:YES];
}

@end
