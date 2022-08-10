package com.nordnetab.chcp.main.events;

/**
 * Created by Derek Chia on 29.11.18.
 *
 * Event is send when content manifest diff result.
 */
public class UpdateDownloadProgressEvent extends PluginEventImpl {

    public static final String EVENT_NAME = "chcp_updateDownloadProgressEvent";

    /**
     * Class constructor
     */
    public UpdateDownloadProgressEvent(String fileName) {
        super(EVENT_NAME, null);

        super.data().put("fileName", fileName);
    }
}