//
//  CDVPluginResult+HCPEvents.m
//
//  Created by Nikolay Demyankov on 13.08.15.
//

#import "CDVPluginResult+HCPEvents.h"
#import "HCPApplicationConfig.h"
#import "HCPEvents.h"

#pragma mark Keys for the plugin result data.

// Used by JavaScript library to process the data, that is sent back from native side.
static NSString *const ACTION_KEY = @"action";

static NSString *const DATA_KEY = @"data";
static NSString *const DATA_USER_INFO_CONFIG = @"config";

static NSString *const ERROR_KEY = @"error";
static NSString *const ERROR_USER_INFO_CODE = @"code";
static NSString *const ERROR_USER_INFO_DESCRIPTION = @"description";

@implementation CDVPluginResult (HCPEvents)

#pragma mark Public API

+ (CDVPluginResult *)pluginResultForNotification:(NSNotification *)notification {
    HCPApplicationConfig *appConfig = notification.userInfo[kHCPEventUserInfoApplicationConfigKey];
    NSError *error = notification.userInfo[kHCPEventUserInfoErrorKey];
    NSString *action = notification.name;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    for (NSString *userInfoKey in [notification.userInfo allKeys]) {
        if (![userInfoKey isEqualToString:kHCPEventUserInfoApplicationConfigKey] && ![userInfoKey isEqualToString:kHCPEventUserInfoErrorKey]) {
            [data setValue:notification.userInfo[userInfoKey] forKey:userInfoKey];
        }
    }
    
    if ([data allKeys].count > 0) {
        return [CDVPluginResult pluginResultWithActionName:action applicationConfig:appConfig data:[NSDictionary dictionaryWithDictionary: data] error:error];
    } else {
        return [CDVPluginResult pluginResultWithActionName:action applicationConfig:appConfig error:error];
    }
}

+ (CDVPluginResult *)pluginResultWithActionName:(NSString *)action applicationConfig:(HCPApplicationConfig *)appConfig error:(NSError *)error {
    NSDictionary *data = nil;
    if (appConfig) {
        data = @{DATA_USER_INFO_CONFIG: [appConfig toJson]};
    }
    
    return [self pluginResultWithActionName:action data:data error:error];
}

+ (CDVPluginResult *)pluginResultWithActionName:(NSString *)action applicationConfig:(HCPApplicationConfig *)appConfig data:(NSDictionary *)data error:(NSError *)error {
    if (appConfig) {
        if (data == nil) {
            data = @{DATA_USER_INFO_CONFIG: [appConfig toJson]};
        } else {
            NSMutableDictionary *resultData = [NSMutableDictionary dictionaryWithDictionary:data];
            [resultData setValue:[appConfig toJson] forKey:DATA_USER_INFO_CONFIG];
            data = [NSDictionary dictionaryWithDictionary:resultData];
        }
    }
    
    return [self pluginResultWithActionName:action data:data error:error];
}

+ (CDVPluginResult *)pluginResultWithActionName:(NSString *)action data:(NSDictionary *)data error:(NSError *)error {
    NSMutableDictionary *jsonObject = [[NSMutableDictionary alloc] init];
    if (action) {
        jsonObject[ACTION_KEY] = action;
    }
    
    if (error) {
        jsonObject[ERROR_KEY] = [self constructErrorBlock:error];
    }
    
    if (data) {
        jsonObject[DATA_KEY] = data;
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:kNilOptions error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    // TODO: should be moved to an [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
    return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonString];
}

#pragma mark Private API

/**
 *  Create error block that is send back to JavaScript
 *
 *  @param error error information
 *
 *  @return JSON dictionary with error information
 */
+ (NSDictionary *)constructErrorBlock:(NSError *)error {
    NSString *errorDesc = error.userInfo[NSLocalizedDescriptionKey];
    if (errorDesc == nil) {
        errorDesc = @"";
    }
    
    return @{ERROR_USER_INFO_CODE: @(error.code),
             ERROR_USER_INFO_DESCRIPTION: errorDesc};
}

@end
