//
//  DatabaseManager.h
//  WeMakeFriends
//
//  Created by Oslo on 11/1/15.
//  Copyright © 2015 Shih Chi Lin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DatabaseManager : NSObject

@property NSString *documentDir;
@property NSString *databaseFilename;
@property NSMutableArray *columnNames;
@property int updatedRows;
@property long long lastInsertedRowID;

-(instancetype) initWithDatabaseFilename:(NSString *)databaseName;
-(void) copyDatabaseIntoDocumentDir;
-(NSArray *) loadDatafromDB:(NSString *)query;
-(void) executeQuery:(NSString *)query;

@end
