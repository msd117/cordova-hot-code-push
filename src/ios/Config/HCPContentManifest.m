//
//  HCPContentManifest.m
//
//  Created by Nikolay Demyankov on 10.08.15.
//

#import "HCPContentManifest.h"
#import "HCPManifestFile.h"

@interface HCPContentManifest()

@property (nonatomic, readwrite, strong) NSArray *files;

@end

@implementation HCPContentManifest

#pragma mark Public API

- (HCPManifestDiff *)calculateDifference:(HCPContentManifest *)comparedManifest {
    NSMutableArray *addedFiles = [[NSMutableArray alloc] init];
    NSMutableArray *changedFiles = [[NSMutableArray alloc] init];
    NSMutableArray *deletedFiles = [[NSMutableArray alloc] init];
    
    NSMutableDictionary * filesMap = [[NSMutableDictionary alloc ] init];
    
    /**
     * 将oldFiles推入到filesMap中
     */
    for (HCPManifestFile *oldFile in self.files) {
        [filesMap setValue:oldFile forKey:oldFile.name];
    }
    
    /**
     * 遍历newFiles
     * 1. 如果在filesMap中找不到fileName对应的file,则说明是新加的
     * 2. 如果找到了，且hash值不同，则说明更新的
     * 3. 将2中找到的删除掉，剩下的就是需要移除的
     */
    
    for (HCPManifestFile *newFile in comparedManifest.files){
        
        HCPManifestFile * oldFile = [filesMap objectForKey:newFile.name];
        
        if(oldFile == NULL){
            // 如果没有则加入
            [addedFiles addObject:newFile];
        }else {
            // 如果有同名的文件
            if(![oldFile.md5Hash isEqualToString:newFile.md5Hash]){
                // 如果同名文件hash值不同则需要改动
                [changedFiles addObject:newFile];
            }
            [filesMap removeObjectForKey:oldFile.name];
        }
    }
    // 同名的已去除，剩下的就是改动的(新增不再这个字典里)
    [deletedFiles addObjectsFromArray:[filesMap allValues]];
    return [[HCPManifestDiff alloc] initWithAddedFiles:addedFiles changedFiles:changedFiles deletedFiles:deletedFiles];
}


#pragma mark HCPJsonConvertable implmenetation

- (id)toJson {
    NSMutableArray *jsonObject = [[NSMutableArray alloc] init];
    for (HCPManifestFile *manifestFile in self.files) {
        id manifestFileObj = [manifestFile toJson];
        if (manifestFileObj) {
            [jsonObject addObject:manifestFileObj];
        }
    }
    
    return jsonObject;
}

+ (instancetype)instanceFromJsonObject:(id)json {
    if (![json isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    NSArray *jsonObject = json;
    NSMutableArray *manifestFilesList = [[NSMutableArray alloc] initWithCapacity:jsonObject.count];
    for (NSDictionary *manifestFileObject in jsonObject) {
        HCPManifestFile* manifestFile = [HCPManifestFile instanceFromJsonObject:manifestFileObject];
        if (manifestFile) {
            [manifestFilesList addObject:manifestFile];
        }
    }
    
    HCPContentManifest *manifest = [[HCPContentManifest alloc] init];
    manifest.files = manifestFilesList;
    
    return manifest;
}

@end
