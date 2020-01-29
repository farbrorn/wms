/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package se.saljex.wms;

/**
 *
 * @author ulf
 */
public class JsonBuilder {
// Bygg enkel Json utan strukturer
    StringBuffer sb = new StringBuffer();
    
    public void addField(String name, String value) {
        if(sb.length()>0) sb.append(",");
        sb.append(buildField(name, value));
    }

    public String getJsonString() {
        return "{ " + sb.toString() + " }";
    }
    
    public void addResponse(String s) {
        addField("response", s);
    }
    
    public void addResponseTrue() {
        addResponse("true");
    }
    public void addResponseFalse() {
        addResponse("false");
    }
    public void addResponseOK() {
        addResponse("OK");
    }
    public void addResponseError() {
        addResponse("error");
    }
    public void addResponseError(String message) {
        addResponseError();
        addErrorMessage(message);
    }
    
    public void addMessage(String s) {
        addField("message", s);
    }
    public void addErrorMessage(String s) {
        addField("errorMessage", s);
    }
    
    public static String escape(String s) {
        StringBuilder sb = new StringBuilder();
        int len=s.length();
        for (int i=0; i<len; i++) {
            char c = s.charAt(i);
            if (c=='"' || c=='\\') sb.append("\\"+c);
            else if (c=='\n') sb.append("\\n");
            else if (c=='\r') sb.append("\\r");
            else if (c=='\t') sb.append("\\t");
            else if (c=='\f') sb.append("\\f");
            else if (c=='\n') sb.append("\\b");
            else sb.append(c);
        }
        return sb.toString();
    }

    public static String buildField(String name, String value) {
        return "\"" + name + "\": \"" + escape(value) + "\""; 
    }
    
    
}
