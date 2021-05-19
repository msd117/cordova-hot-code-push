package com.nordnetab.chcp.main.config;

import android.text.TextUtils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.nordnetab.chcp.main.model.ManifestDiff;
import com.nordnetab.chcp.main.model.ManifestFile;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Nikolay Demyankov on 22.07.15.
 * <p/>
 * Model for content manifest.
 * Content manifest is a configuration file, that holds the list of all web project files with they hashes.
 * Used to determine which files has been removed from the project, which are added or updated.
 */
public class ContentManifest {

    // region Json

    // keys to parse json
    private static class JsonKeys {
        public static final String FILE_PATH = "file";
        public static final String FILE_HASH = "hash";
    }

    /**
     * Create instance of the object from JSON string.
     * JSON string is a content of the chcp.manifest file.
     *
     * @param json JSON string to parse
     * @return content manifest instance
     */
    public static ContentManifest fromJson(String json) {
        ContentManifest manifest = new ContentManifest();
        try {
            JsonNode filesListNode = new ObjectMapper().readTree(json);
            for (JsonNode fileNode : filesListNode) {
                String fileName = fileNode.get(JsonKeys.FILE_PATH).asText();
                String fileHash = fileNode.get(JsonKeys.FILE_HASH).asText();
                manifest.files.add(new ManifestFile(fileName, fileHash));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        manifest.jsonString = json;

        return manifest;
    }

    /**
     * Convert object into JSON string
     *
     * @return JSON string
     */
    @Override
    public String toString() {
        if (TextUtils.isEmpty(jsonString)) {
            jsonString = generateJson();
        }

        return jsonString;
    }

    private String generateJson() {
        final JsonNodeFactory nodeFactory = JsonNodeFactory.instance;
        ArrayNode filesListNode = nodeFactory.arrayNode();
        for (ManifestFile fileEntry : files) {
            ObjectNode fileNode = nodeFactory.objectNode();
            fileNode.set(JsonKeys.FILE_PATH, nodeFactory.textNode(fileEntry.name));
            fileNode.set(JsonKeys.FILE_HASH, nodeFactory.textNode(fileEntry.hash));
            filesListNode.add(fileNode);
        }

        return filesListNode.toString();
    }

    // endregion

    private final List<ManifestFile> files;
    private String jsonString;

    private ContentManifest() {
        this.files = new ArrayList<ManifestFile>();
    }

    /**
     * Getter for list of web project files.
     *
     * @return list of files
     */
    public List<ManifestFile> getFiles() {
        return files;
    }

    /**
     * Find differences between this manifest and the new one.
     * Current object is considered as an old manifest.
     *
     * @param manifest new manifest, relative to which we will calculate the difference
     * @return calculated difference between manifests
     * @see ManifestDiff
     * @see ManifestFile
     */
    // TODO: need more cleaner way to find differences between two lists
    public ManifestDiff calculateDifference(ContentManifest manifest) {
        final List<ManifestFile> oldManifestFiles = files;
        final List<ManifestFile> newManifestFiles = (manifest != null && manifest.getFiles() != null)
                ? manifest.getFiles() : new ArrayList<ManifestFile>();

        final ManifestDiff diff = new ManifestDiff();
        final List<ManifestFile> changedFiles = diff.changedFiles();
        final List<ManifestFile> deletedFiles = diff.deletedFiles();
        final List<ManifestFile> addedFiles = diff.addedFiles();
        final Map<String,ManifestFile> filesMap = new HashMap<String,ManifestFile> ();
        /**
         * 将oldFiles推入到filesMap中
         */
        for (ManifestFile oldFile : oldManifestFiles) {
            filesMap.put(oldFile.name,oldFile);
        }

        /**
         * 遍历newFiles
         * 1. 如果在filesMap中找不到fileName对应的file,则说明是新加的
         * 2. 如果找到了，且hash值不同，则说明更新的
         * 3. 将2中找到的删除掉，剩下的就是需要移除的
         */
        for (ManifestFile newFile : newManifestFiles){
            final  ManifestFile oldFile = filesMap.get(newFile.name);
            if(oldFile == null){
                // 如果没有则加入
                addedFiles.add(newFile);
            }else {
                // 如果有同名的文件
                 if(!oldFile.hash.equals(newFile.hash)){
                     // 如果同名文件hash值不同则需要改动
                    changedFiles.add(newFile);

                }
                 // 删除文件map中同名文件：不管hash值是否相同
                filesMap.remove(oldFile.name);
            }
        }
        deletedFiles.addAll(filesMap.values());
        return diff;

    }
}
