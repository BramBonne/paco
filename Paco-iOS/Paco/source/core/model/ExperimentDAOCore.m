//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/northropo/Project/paco/Shared/src/com/pacoapp/paco/shared/model2/ExperimentDAOCore.java
//


#include "ExperimentDAOCore.h"
#include "IOSClass.h"
#include "J2ObjC_source.h"
#include "ListMaker.h"
#include "Validator.h"
#include "java/lang/Boolean.h"
#include "java/lang/Integer.h"
#include "java/lang/Long.h"
#include "java/util/ArrayList.h"
#include "java/util/Date.h"
#include "java/util/List.h"

@interface PAExperimentDAOCore () {
 @public
  JavaLangBoolean *recordPhoneDetails_;
  id<JavaUtilList> extraDataCollectionDeclarations_;
  JavaUtilDate *earliestStartDate_;
  JavaUtilDate *latestEndDate_;
}
@end

J2OBJC_FIELD_SETTER(PAExperimentDAOCore, recordPhoneDetails_, JavaLangBoolean *)
J2OBJC_FIELD_SETTER(PAExperimentDAOCore, extraDataCollectionDeclarations_, id<JavaUtilList>)
J2OBJC_FIELD_SETTER(PAExperimentDAOCore, earliestStartDate_, JavaUtilDate *)
J2OBJC_FIELD_SETTER(PAExperimentDAOCore, latestEndDate_, JavaUtilDate *)

J2OBJC_INITIALIZED_DEFN(PAExperimentDAOCore)

id<JavaUtilList> PAExperimentDAOCore_EXTRA_DATA_COLLECTION_DECLS_;

@implementation PAExperimentDAOCore

- (instancetype)initWithJavaLangLong:(JavaLangLong *)id_
                        withNSString:(NSString *)title
                        withNSString:(NSString *)description_
                        withNSString:(NSString *)informedConsentForm
                        withNSString:(NSString *)creatorEmail
                        withNSString:(NSString *)joinDate
                 withJavaLangBoolean:(JavaLangBoolean *)recordPhoneDetails
                 withJavaLangBoolean:(JavaLangBoolean *)deleted2
                    withJavaUtilList:(id<JavaUtilList>)extraDataCollectionDeclarationsList
                        withNSString:(NSString *)organization
                        withNSString:(NSString *)contactPhone
                        withNSString:(NSString *)contactEmail
                    withJavaUtilDate:(JavaUtilDate *)earliestStartDate
                    withJavaUtilDate:(JavaUtilDate *)latestEndDate {
  PAExperimentDAOCore_initWithJavaLangLong_withNSString_withNSString_withNSString_withNSString_withNSString_withJavaLangBoolean_withJavaLangBoolean_withJavaUtilList_withNSString_withNSString_withNSString_withJavaUtilDate_withJavaUtilDate_(self, id_, title, description_, informedConsentForm, creatorEmail, joinDate, recordPhoneDetails, deleted2, extraDataCollectionDeclarationsList, organization, contactPhone, contactEmail, earliestStartDate, latestEndDate);
  return self;
}

- (instancetype)init {
  PAExperimentDAOCore_init(self);
  return self;
}

- (NSString *)getTitle {
  return title_;
}

- (void)setTitleWithNSString:(NSString *)title {
  self->title_ = title;
}

- (NSString *)getDescription {
  return description__;
}

- (void)setDescriptionWithNSString:(NSString *)description_ {
  self->description__ = description_;
}

- (NSString *)getInformedConsentForm {
  return informedConsentForm_;
}

- (void)setInformedConsentFormWithNSString:(NSString *)informedConsentForm {
  self->informedConsentForm_ = informedConsentForm;
}

- (NSString *)getCreator {
  return creator_;
}

- (void)setCreatorWithNSString:(NSString *)creator {
  self->creator_ = creator;
}

- (NSString *)getJoinDate {
  return joinDate_;
}

- (void)setJoinDateWithNSString:(NSString *)joinDate {
  self->joinDate_ = joinDate;
}

- (JavaLangLong *)getId {
  return id__;
}

- (void)setIdWithJavaLangLong:(JavaLangLong *)id_ {
  self->id__ = id_;
}

- (void)setRecordPhoneDetailsWithJavaLangBoolean:(JavaLangBoolean *)recordDetails {
  if (recordDetails != nil) {
    self->recordPhoneDetails_ = recordDetails;
  }
}

- (JavaLangBoolean *)getDeleted {
  return deleted_;
}

- (void)setDeletedWithJavaLangBoolean:(JavaLangBoolean *)deleted {
  self->deleted_ = deleted;
}

- (id<JavaUtilList>)getExtraDataCollectionDeclarations {
  return extraDataCollectionDeclarations_;
}

- (void)setExtraDataCollectionDeclarationsWithJavaUtilList:(id<JavaUtilList>)extraDataCollectionDeclarations {
  self->extraDataCollectionDeclarations_ = extraDataCollectionDeclarations;
}

- (NSString *)getOrganization {
  return organization_;
}

- (void)setOrganizationWithNSString:(NSString *)organization {
  self->organization_ = organization;
}

- (NSString *)getContactEmail {
  return contactEmail_;
}

- (void)setContactEmailWithNSString:(NSString *)contactEmail {
  self->contactEmail_ = contactEmail;
}

- (NSString *)getContactPhone {
  return contactPhone_;
}

- (void)setContactPhoneWithNSString:(NSString *)contactPhone {
  self->contactPhone_ = contactPhone;
}

- (JavaLangBoolean *)getRecordPhoneDetails {
  return recordPhoneDetails_;
}

- (void)validateWithWithPAValidator:(id<PAValidator>)validator {
  [((id<PAValidator>) nil_chk(validator)) isNotNullAndNonEmptyStringWithNSString:title_ withNSString:@"Experiment title cannot be null"];
  [validator isValidEmailWithNSString:creator_ withNSString:@"Experiment creator must be a valid email address"];
  if (contactEmail_ != nil && ((jint) [contactEmail_ length]) > 0) {
    [validator isValidEmailWithNSString:contactEmail_ withNSString:@"Experiment contact must be a valid email address"];
  }
  [validator isNotNullWithId:deleted_ withNSString:@"deleted is not properly initialized"];
  [validator isNotNullWithId:recordPhoneDetails_ withNSString:@"recordPhoneDetails is not properly initialized"];
  [validator isNotNullCollectionWithJavaUtilCollection:extraDataCollectionDeclarations_ withNSString:@"extra data declaration if you use extra data"];
  if (joinDate_ != nil) {
    [validator isValidDateStringWithNSString:joinDate_ withNSString:@"join date should be a valid date string"];
  }
  if (organization_ != nil && ((jint) [organization_ length]) > 0) {
    [validator isNotNullAndNonEmptyStringWithNSString:organization_ withNSString:@"organization must be non null if it is specified"];
  }
}

- (JavaUtilDate *)getEarliestStartDate {
  return earliestStartDate_;
}

- (void)setEarliestStartDateWithJavaUtilDate:(JavaUtilDate *)earliestStartDate {
  self->earliestStartDate_ = earliestStartDate;
}

- (JavaUtilDate *)getLatestEndDate {
  return latestEndDate_;
}

- (void)setLatestEndDateWithJavaUtilDate:(JavaUtilDate *)latestEndDate {
  self->latestEndDate_ = latestEndDate;
}

+ (void)initialize {
  if (self == [PAExperimentDAOCore class]) {
    PAExperimentDAOCore_EXTRA_DATA_COLLECTION_DECLS_ = [[JavaUtilArrayList alloc] init];
    {
      [PAExperimentDAOCore_EXTRA_DATA_COLLECTION_DECLS_ addWithId:JavaLangInteger_valueOfWithInt_(PAExperimentDAOCore_APP_USAGE_BROWSER_HISTORY_DATA_COLLECTION)];
      [PAExperimentDAOCore_EXTRA_DATA_COLLECTION_DECLS_ addWithId:JavaLangInteger_valueOfWithInt_(PAExperimentDAOCore_LOCATION_DATA_COLLECTION)];
      [PAExperimentDAOCore_EXTRA_DATA_COLLECTION_DECLS_ addWithId:JavaLangInteger_valueOfWithInt_(PAExperimentDAOCore_PHONE_DETAILS)];
    }
    J2OBJC_SET_INITIALIZED(PAExperimentDAOCore)
  }
}

+ (const J2ObjcClassInfo *)__metadata {
  static const J2ObjcMethodInfo methods[] = {
    { "initWithJavaLangLong:withNSString:withNSString:withNSString:withNSString:withNSString:withJavaLangBoolean:withJavaLangBoolean:withJavaUtilList:withNSString:withNSString:withNSString:withJavaUtilDate:withJavaUtilDate:", "ExperimentDAOCore", NULL, 0x1, NULL, NULL },
    { "init", "ExperimentDAOCore", NULL, 0x1, NULL, NULL },
    { "getTitle", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setTitleWithNSString:", "setTitle", "V", 0x1, NULL, NULL },
    { "getDescription", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setDescriptionWithNSString:", "setDescription", "V", 0x1, NULL, NULL },
    { "getInformedConsentForm", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setInformedConsentFormWithNSString:", "setInformedConsentForm", "V", 0x1, NULL, NULL },
    { "getCreator", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setCreatorWithNSString:", "setCreator", "V", 0x1, NULL, NULL },
    { "getJoinDate", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setJoinDateWithNSString:", "setJoinDate", "V", 0x1, NULL, NULL },
    { "getId", NULL, "Ljava.lang.Long;", 0x1, NULL, NULL },
    { "setIdWithJavaLangLong:", "setId", "V", 0x1, NULL, NULL },
    { "setRecordPhoneDetailsWithJavaLangBoolean:", "setRecordPhoneDetails", "V", 0x1, NULL, NULL },
    { "getDeleted", NULL, "Ljava.lang.Boolean;", 0x1, NULL, NULL },
    { "setDeletedWithJavaLangBoolean:", "setDeleted", "V", 0x1, NULL, NULL },
    { "getExtraDataCollectionDeclarations", NULL, "Ljava.util.List;", 0x1, NULL, NULL },
    { "setExtraDataCollectionDeclarationsWithJavaUtilList:", "setExtraDataCollectionDeclarations", "V", 0x1, NULL, NULL },
    { "getOrganization", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setOrganizationWithNSString:", "setOrganization", "V", 0x1, NULL, NULL },
    { "getContactEmail", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setContactEmailWithNSString:", "setContactEmail", "V", 0x1, NULL, NULL },
    { "getContactPhone", NULL, "Ljava.lang.String;", 0x1, NULL, NULL },
    { "setContactPhoneWithNSString:", "setContactPhone", "V", 0x1, NULL, NULL },
    { "getRecordPhoneDetails", NULL, "Ljava.lang.Boolean;", 0x1, NULL, NULL },
    { "validateWithWithPAValidator:", "validateWith", "V", 0x1, NULL, NULL },
    { "getEarliestStartDate", NULL, "Ljava.util.Date;", 0x1, NULL, NULL },
    { "setEarliestStartDateWithJavaUtilDate:", "setEarliestStartDate", "V", 0x1, NULL, NULL },
    { "getLatestEndDate", NULL, "Ljava.util.Date;", 0x1, NULL, NULL },
    { "setLatestEndDateWithJavaUtilDate:", "setLatestEndDate", "V", 0x1, NULL, NULL },
  };
  static const J2ObjcFieldInfo fields[] = {
    { "APP_USAGE_BROWSER_HISTORY_DATA_COLLECTION_", NULL, 0x19, "I", NULL, NULL, .constantValue.asInt = PAExperimentDAOCore_APP_USAGE_BROWSER_HISTORY_DATA_COLLECTION },
    { "LOCATION_DATA_COLLECTION_", NULL, 0x19, "I", NULL, NULL, .constantValue.asInt = PAExperimentDAOCore_LOCATION_DATA_COLLECTION },
    { "PHONE_DETAILS_", NULL, 0x19, "I", NULL, NULL, .constantValue.asInt = PAExperimentDAOCore_PHONE_DETAILS },
    { "EXTRA_DATA_COLLECTION_DECLS_", NULL, 0x19, "Ljava.util.List;", &PAExperimentDAOCore_EXTRA_DATA_COLLECTION_DECLS_, "Ljava/util/List<Ljava/lang/Integer;>;",  },
    { "title_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "description__", "description", 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "creator_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "organization_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "contactEmail_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "contactPhone_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "joinDate_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "id__", "id", 0x4, "Ljava.lang.Long;", NULL, NULL,  },
    { "informedConsentForm_", NULL, 0x4, "Ljava.lang.String;", NULL, NULL,  },
    { "recordPhoneDetails_", NULL, 0x2, "Ljava.lang.Boolean;", NULL, NULL,  },
    { "extraDataCollectionDeclarations_", NULL, 0x2, "Ljava.util.List;", NULL, "Ljava/util/List<Ljava/lang/Integer;>;",  },
    { "deleted_", NULL, 0x4, "Ljava.lang.Boolean;", NULL, NULL,  },
    { "earliestStartDate_", NULL, 0x2, "Ljava.util.Date;", NULL, NULL,  },
    { "latestEndDate_", NULL, 0x2, "Ljava.util.Date;", NULL, NULL,  },
  };
  static const J2ObjcClassInfo _PAExperimentDAOCore = { 2, "ExperimentDAOCore", "com.pacoapp.paco.shared.model2", NULL, 0x1, 31, methods, 18, fields, 0, NULL, 0, NULL, NULL, NULL };
  return &_PAExperimentDAOCore;
}

@end

void PAExperimentDAOCore_initWithJavaLangLong_withNSString_withNSString_withNSString_withNSString_withNSString_withJavaLangBoolean_withJavaLangBoolean_withJavaUtilList_withNSString_withNSString_withNSString_withJavaUtilDate_withJavaUtilDate_(PAExperimentDAOCore *self, JavaLangLong *id_, NSString *title, NSString *description_, NSString *informedConsentForm, NSString *creatorEmail, NSString *joinDate, JavaLangBoolean *recordPhoneDetails, JavaLangBoolean *deleted2, id<JavaUtilList> extraDataCollectionDeclarationsList, NSString *organization, NSString *contactPhone, NSString *contactEmail, JavaUtilDate *earliestStartDate, JavaUtilDate *latestEndDate) {
  NSObject_init(self);
  self->recordPhoneDetails_ = JavaLangBoolean_valueOfWithBoolean_(NO);
  self->deleted_ = JavaLangBoolean_valueOfWithBoolean_(NO);
  self->id__ = id_;
  self->title_ = title;
  self->description__ = description_;
  self->informedConsentForm_ = informedConsentForm;
  self->creator_ = creatorEmail;
  self->organization_ = organization;
  self->contactEmail_ = contactEmail;
  self->contactPhone_ = contactPhone;
  self->joinDate_ = joinDate;
  [self setRecordPhoneDetailsWithJavaLangBoolean:recordPhoneDetails];
  self->deleted_ = JavaLangBoolean_valueOfWithBoolean_(self->deleted_ != nil ? [self->deleted_ booleanValue] : NO);
  self->extraDataCollectionDeclarations_ = PAListMaker_paramOrNewListWithJavaUtilList_withIOSClass_(extraDataCollectionDeclarationsList, JavaLangInteger_class_());
  self->earliestStartDate_ = earliestStartDate;
  self->latestEndDate_ = latestEndDate;
}

PAExperimentDAOCore *new_PAExperimentDAOCore_initWithJavaLangLong_withNSString_withNSString_withNSString_withNSString_withNSString_withJavaLangBoolean_withJavaLangBoolean_withJavaUtilList_withNSString_withNSString_withNSString_withJavaUtilDate_withJavaUtilDate_(JavaLangLong *id_, NSString *title, NSString *description_, NSString *informedConsentForm, NSString *creatorEmail, NSString *joinDate, JavaLangBoolean *recordPhoneDetails, JavaLangBoolean *deleted2, id<JavaUtilList> extraDataCollectionDeclarationsList, NSString *organization, NSString *contactPhone, NSString *contactEmail, JavaUtilDate *earliestStartDate, JavaUtilDate *latestEndDate) {
  PAExperimentDAOCore *self = [PAExperimentDAOCore alloc];
  PAExperimentDAOCore_initWithJavaLangLong_withNSString_withNSString_withNSString_withNSString_withNSString_withJavaLangBoolean_withJavaLangBoolean_withJavaUtilList_withNSString_withNSString_withNSString_withJavaUtilDate_withJavaUtilDate_(self, id_, title, description_, informedConsentForm, creatorEmail, joinDate, recordPhoneDetails, deleted2, extraDataCollectionDeclarationsList, organization, contactPhone, contactEmail, earliestStartDate, latestEndDate);
  return self;
}

void PAExperimentDAOCore_init(PAExperimentDAOCore *self) {
  NSObject_init(self);
  self->recordPhoneDetails_ = JavaLangBoolean_valueOfWithBoolean_(NO);
  self->deleted_ = JavaLangBoolean_valueOfWithBoolean_(NO);
  self->extraDataCollectionDeclarations_ = [[JavaUtilArrayList alloc] init];
}

PAExperimentDAOCore *new_PAExperimentDAOCore_init() {
  PAExperimentDAOCore *self = [PAExperimentDAOCore alloc];
  PAExperimentDAOCore_init(self);
  return self;
}

J2OBJC_CLASS_TYPE_LITERAL_SOURCE(PAExperimentDAOCore)
