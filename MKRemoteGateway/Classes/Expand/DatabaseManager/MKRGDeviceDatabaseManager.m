//
//  MKRGDeviceDatabaseManager.m
//  MKRemoteGateway_Example
//
//  Created by aa on 2023/1/29.
//  Copyright © 2023 aadyx2007@163.com. All rights reserved.
//

#import "MKRGDeviceDatabaseManager.h"

#import <FMDB/FMDB.h>

#import "MKMacroDefines.h"

#import "MKRGDeviceModel.h"

@implementation MKRGDeviceDatabaseManager

+ (BOOL)initDataBase {
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"RGDeviceDB")];
    if (![db open]) {
        return NO;
    }
    NSString *sqlCreateTable = [NSString stringWithFormat:@"create table if not exists RGDeviceTable (deviceType text,clientID text,deviceName text,subscribedTopic text,publishedTopic text,macAddress text, lwtStatus text,lwtTopic text)"];
    BOOL resCreate = [db executeUpdate:sqlCreateTable];
    if (!resCreate) {
        [db close];
        return NO;
    }
    return YES;
}

+ (void)insertDeviceList:(NSArray <MKRGDeviceModel *>*)deviceList
                sucBlock:(void (^)(void))sucBlock
             failedBlock:(void (^)(NSError *error))failedBlock {
    if (!deviceList) {
        [self operationInsertFailedBlock:failedBlock];
        return ;
    }
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"RGDeviceDB")];
    if (![db open]) {
        [self operationInsertFailedBlock:failedBlock];
        return;
    }
    NSString *sqlCreateTable = [NSString stringWithFormat:@"create table if not exists RGDeviceTable (deviceType text,clientID text,deviceName text,subscribedTopic text,publishedTopic text,macAddress text,lwtStatus text,lwtTopic text)"];
    BOOL resCreate = [db executeUpdate:sqlCreateTable];
    if (!resCreate) {
        [db close];
        [self operationInsertFailedBlock:failedBlock];
        return;
    }
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"RGDeviceDB")] inDatabase:^(FMDatabase *db) {
        
        for (MKRGDeviceModel *device in deviceList) {
            BOOL exist = NO;
            FMResultSet * result = [db executeQuery:@"select * from RGDeviceTable where macAddress = ?",device.macAddress];
            while (result.next) {
                if ([device.macAddress isEqualToString:[result stringForColumn:@"macAddress"]]) {
                    exist = YES;
                }
            }
            if (exist) {
                //存在该设备，更新设备
                [db executeUpdate:@"UPDATE RGDeviceTable SET deviceType = ?, clientID = ?, deviceName = ? ,subscribedTopic = ? ,publishedTopic = ?,lwtStatus = ? ,lwtTopic = ? WHERE macAddress = ?",SafeStr(device.deviceType),SafeStr(device.clientID),SafeStr(device.deviceName),SafeStr(device.subscribedTopic),SafeStr(device.publishedTopic),(device.lwtStatus ? @"1" : @"0"),SafeStr(device.lwtTopic),SafeStr(device.macAddress)];
            }else{
                //不存在，插入设备
                [db executeUpdate:@"INSERT INTO RGDeviceTable (deviceType,clientID,deviceName,subscribedTopic,publishedTopic,macAddress,lwtTopic,lwtStatus) VALUES (?,?,?,?,?,?,?,?)",SafeStr(device.deviceType),SafeStr(device.clientID),SafeStr(device.deviceName),SafeStr(device.subscribedTopic),SafeStr(device.publishedTopic),SafeStr(device.macAddress),SafeStr(device.lwtTopic),(device.lwtStatus ? @"1" : @"0")];
            }
        }
        
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
        [db close];
    }];
}

+ (void)deleteDeviceWithMacAddress:(NSString *)macAddress
                          sucBlock:(void (^)(void))sucBlock
                       failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(macAddress)) {
        [self operationDeleteFailedBlock:failedBlock];
        return;
    }
    
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"RGDeviceDB")] inDatabase:^(FMDatabase *db) {
        
        BOOL result = [db executeUpdate:@"DELETE FROM RGDeviceTable WHERE macAddress = ?",macAddress];
        if (!result) {
            [self operationDeleteFailedBlock:failedBlock];
            return;
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
        [db close];
    }];
}

+ (void)readLocalDeviceWithSucBlock:(void (^)(NSArray <MKRGDeviceModel *> *deviceList))sucBlock
                        failedBlock:(void (^)(NSError *error))failedBlock {
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"RGDeviceDB")];
    if (![db open]) {
        [self operationGetDataFailedBlock:failedBlock];
        return;
    }
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"RGDeviceDB")] inDatabase:^(FMDatabase *db) {
        NSMutableArray *tempDataList = [NSMutableArray array];
        FMResultSet * result = [db executeQuery:@"SELECT * FROM RGDeviceTable"];
        while ([result next]) {
            MKRGDeviceModel *dataModel = [[MKRGDeviceModel alloc] init];
            dataModel.clientID = [result stringForColumn:@"clientID"];
            dataModel.deviceName = [result stringForColumn:@"deviceName"];
            dataModel.subscribedTopic = [result stringForColumn:@"subscribedTopic"];
            dataModel.publishedTopic = [result stringForColumn:@"publishedTopic"];
            dataModel.macAddress = [result stringForColumn:@"macAddress"];
            dataModel.deviceType = [result stringForColumn:@"deviceType"];
            dataModel.lwtTopic = [result stringForColumn:@"lwtTopic"];
            dataModel.lwtStatus = ([[result stringForColumn:@"lwtStatus"] integerValue] == 1);
        
            [tempDataList addObject:dataModel];
        }
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock(tempDataList);
            });
        }
        [db close];
    }];
}

+ (void)updateLocalName:(NSString *)localName
             macAddress:(NSString *)macAddress
               sucBlock:(void (^)(void))sucBlock
            failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(localName) || !ValidStr(macAddress)) {
        [self operationDeleteFailedBlock:failedBlock];
        return;
    }
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"RGDeviceDB")];
    if (![db open]) {
        [self operationInsertFailedBlock:failedBlock];
        return;
    }
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"RGDeviceDB")] inDatabase:^(FMDatabase *db) {
        
        BOOL exist = NO;
        FMResultSet * result = [db executeQuery:@"select * from RGDeviceTable where macAddress = ?",macAddress];
        while (result.next) {
            if ([macAddress isEqualToString:[result stringForColumn:@"macAddress"]]) {
                exist = YES;
            }
        }
        if (!exist) {
            [self operationUpdateFailedBlock:failedBlock];
            [db close];
            return;
        }
        //存在该设备，更新设备
        [db executeUpdate:@"UPDATE RGDeviceTable SET deviceName = ? WHERE macAddress = ?",localName,macAddress];
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
        [db close];
    }];
}

+ (void)updateClientID:(NSString *)clientID
       subscribedTopic:(NSString *)subscribedTopic
        publishedTopic:(NSString *)publishedTopic
             lwtStatus:(BOOL)lwtStatus
              lwtTopic:(NSString *)lwtTopic
            macAddress:(NSString *)macAddress
              sucBlock:(void (^)(void))sucBlock
           failedBlock:(void (^)(NSError *error))failedBlock {
    if (!ValidStr(clientID) || !ValidStr(macAddress) || !ValidStr(subscribedTopic) || !ValidStr(publishedTopic)) {
        [self operationDeleteFailedBlock:failedBlock];
        return;
    }
    if (lwtStatus && !ValidStr(lwtTopic)) {
        [self operationDeleteFailedBlock:failedBlock];
        return;
    }
    FMDatabase* db = [FMDatabase databaseWithPath:kFilePath(@"RGDeviceDB")];
    if (![db open]) {
        [self operationInsertFailedBlock:failedBlock];
        return;
    }
    [[FMDatabaseQueue databaseQueueWithPath:kFilePath(@"RGDeviceDB")] inDatabase:^(FMDatabase *db) {
        
        BOOL exist = NO;
        FMResultSet * result = [db executeQuery:@"select * from RGDeviceTable where macAddress = ?",macAddress];
        while (result.next) {
            if ([macAddress isEqualToString:[result stringForColumn:@"macAddress"]]) {
                exist = YES;
            }
        }
        if (!exist) {
            [self operationUpdateFailedBlock:failedBlock];
            [db close];
            return;
        }
        //存在该设备，更新设备
        [db executeUpdate:@"UPDATE RGDeviceTable SET clientID = ?, subscribedTopic = ? ,publishedTopic = ? , lwtStatus = ?,lwtTopic = ? WHERE macAddress = ?",SafeStr(clientID),SafeStr(subscribedTopic),SafeStr(publishedTopic),(lwtStatus ? @"1" : @"0"),SafeStr(lwtTopic),SafeStr(macAddress)];
        if (sucBlock) {
            moko_dispatch_main_safe(^{
                sucBlock();
            });
        }
        [db close];
    }];
}

+ (void)operationFailedBlock:(void (^)(NSError *error))block msg:(NSString *)msg{
    if (block) {
        NSError *error = [[NSError alloc] initWithDomain:@"com.moko.databaseOperation"
                                                    code:-111111
                                                userInfo:@{@"errorInfo":msg}];
        moko_dispatch_main_safe(^{
            block(error);
        });
    }
}

+ (void)operationInsertFailedBlock:(void (^)(NSError *error))block{
    [self operationFailedBlock:block msg:@"insert data error"];
}

+ (void)operationUpdateFailedBlock:(void (^)(NSError *error))block{
    [self operationFailedBlock:block msg:@"update data error"];
}

+ (void)operationDeleteFailedBlock:(void (^)(NSError *error))block{
    [self operationFailedBlock:block msg:@"fail to delete"];
}

+ (void)operationGetDataFailedBlock:(void (^)(NSError *error))block{
    [self operationFailedBlock:block msg:@"get data error"];
}

@end
