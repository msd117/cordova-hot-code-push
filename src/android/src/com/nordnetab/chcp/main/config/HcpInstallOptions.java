package com.nordnetab.chcp.main.config;

import com.nordnetab.chcp.main.utils.JSONUtils;

import org.json.JSONException;
import org.json.JSONObject;

public class HcpInstallOptions {
    private static  final  String ARG_RELOAD = "reload";
    /** 是否需要重启 */
    private boolean reload;

    public  HcpInstallOptions(final JSONObject json) throws JSONException {
        if (json == null) {
            throw new JSONException("Can't parse null json object");
        }
        this.reload = json.optBoolean(ARG_RELOAD,true) ;
    }

    public boolean  shouldReload(){
        return this.reload;
    }

}
