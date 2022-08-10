package com.nordnetab.chcp.main.events;

import java.util.List;
import java.util.ArrayList;

import com.nordnetab.chcp.main.model.ManifestDiff;
import com.nordnetab.chcp.main.model.ManifestFile;

/**
 * Created by Derek Chia on 29.11.18.
 *
 * Event is send when content manifest diff result.
 */
public class ManifestDiffCompleteEvent extends PluginEventImpl {

    public static final String EVENT_NAME = "chcp_manifestDiffComplete";

    /**
     * Class constructor
     */
    public ManifestDiffCompleteEvent(ManifestDiff manifestDiff) {
        super(EVENT_NAME, null);

        List<String> fileNames = new ArrayList();

        if (manifestDiff != null && manifestDiff.getUpdateFiles() != null) {
            for (ManifestFile curr : manifestDiff.getUpdateFiles()) {
                fileNames.add(curr.name);
            }
        }

        super.data().put("updateFiles", fileNames);
    }
}