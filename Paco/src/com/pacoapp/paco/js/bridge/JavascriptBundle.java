package com.pacoapp.paco.js.bridge;

import android.os.Bundle;
import android.webkit.JavascriptInterface;

import java.util.ArrayList;
import java.util.List;

/**
 * Javascript interface providing an interface for passed extras to custom Javascript code
 */
public class JavascriptBundle {
  Bundle bundle;

  public JavascriptBundle(Bundle bundle) {
    this.bundle = bundle;
  }

  @JavascriptInterface
  public String getString(String key) {
    return bundle.getString(key);
  }

  @JavascriptInterface
  public List<String> keySet() {
    return new ArrayList(bundle.keySet());
  }
}
