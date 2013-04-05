package com.google.android.apps.paco;

import java.util.Locale;

import com.google.paco.shared.client.LocaleHelper;

public abstract class AndroidLocaleHelper<T> extends LocaleHelper<T>{

  @Override
  protected String getLanguage() {
    return Locale.getDefault().getLanguage();
  }

  
}

