//
//  HCPFetchUpdateOptions.m
//
//  Created by Nikolay Demyankov on 24.05.16.
//

#import "HCPInstallOptions.h"



@implementation HCPInstallOptions



- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _reload = [dictionary[@"reload"] boolValue];
        
    }
    
    return self;
}

@end
