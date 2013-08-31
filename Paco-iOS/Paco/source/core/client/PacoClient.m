/* Copyright 2013 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "PacoClient.h"

#import "PacoAuthenticator.h"
#import "PacoLocation.h"
#import "PacoModel.h"
#import "PacoScheduler.h"
#import "PacoService.h"
#import "PacoExperimentDefinition.h"
#import "PacoEvent.h"
#import "Reachability.h"
#import "PacoEventManager.h"



static NSString* const kUserEmail = @"PacoClient.userEmail";
static NSString* const kUserPassword = @"PacoClient.userPassword";

@interface PacoPrefetchState : NSObject
@property(atomic, readwrite, assign) BOOL finishLoadingDefinitions;
@property(atomic, readwrite, strong) NSError* errorLoadingDefinitions;

@property(atomic, readwrite, assign) BOOL finishLoadingExperiments;
@property(atomic, readwrite, strong) NSError* errorLoadingExperiments;
@end

@implementation PacoPrefetchState
- (void)reset
{
  self.finishLoadingDefinitions = NO;
  self.errorLoadingDefinitions = NO;
  
  self.finishLoadingExperiments = NO;
  self.errorLoadingExperiments = nil;
}
@end

@interface PacoModel ()
- (BOOL)loadExperimentDefinitionsFromFile;
- (NSError*)loadExperimentInstancesFromFile;
- (void)applyDefinitionJSON:(id)jsonObject;
- (void)deleteExperimentInstance:(PacoExperiment*)experiment;
@end

@interface PacoClient () <PacoLocationDelegate, PacoSchedulerDelegate>
@property (nonatomic, retain, readwrite) PacoAuthenticator *authenticator;
@property (nonatomic, retain, readwrite) PacoLocation *location;
@property (nonatomic, retain, readwrite) PacoModel *model;
@property (nonatomic, strong, readwrite) PacoEventManager* eventManager;
@property (nonatomic, retain, readwrite) PacoScheduler *scheduler;
@property (nonatomic, retain, readwrite) PacoService *service;
@property (nonatomic, strong) Reachability* reachability;
@property (nonatomic, retain, readwrite) NSString *serverDomain;
@property (nonatomic, retain, readwrite) NSString* userEmail;
@property (nonatomic, retain, readwrite) PacoPrefetchState *prefetchState;
@end

@implementation PacoClient

#pragma mark Object Life Cycle
+ (PacoClient *)sharedInstance {
  static PacoClient *client = nil;
  if (!client) {
    client = [[PacoClient alloc] init];
  }
  return client;
}

- (id)init {
  self = [super init];
  if (self) {
    self.authenticator = [[PacoAuthenticator alloc] init];
    self.location = nil;//[[PacoLocation alloc] init];
    self.scheduler = [PacoScheduler schedulerWithDelegate:self];
    self.service = [[PacoService alloc] init];
    _reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    // Start the notifier, which will cause the reachability object to retain itself!
    [_reachability startNotifier];

    self.model = [[PacoModel alloc] init];
    
    _eventManager = [PacoEventManager defaultManager];
    
    self.prefetchState = [[PacoPrefetchState alloc] init];
    
    if (SERVER_DOMAIN_FLAG == 0) {//production
      self.serverDomain = @"https://quantifiedself.appspot.com";
    }else{//localserver
      self.serverDomain = @"http://127.0.0.1";
    }
  }
  return self;
}

#pragma mark Public methods
- (BOOL)isLoggedIn {
  return [self.authenticator isLoggedIn];
}

- (void)timerUpdated {
  [self.scheduler update:self.model.experimentInstances];
}

- (void)handleNotificationTimeOut:(NSString*) experimentInstanceId
               experimentFireDate:(NSDate*) experimentFireId {
//TODO: Implement this method to call the server and let it know about the missed signal
}

//YMZ: TODO: we need to store user email and address inside keychain
//However, if we migrate to OAuth2, it looks like GTMOAuth2ViewControllerTouch
//already handles keychain storage
- (BOOL)isUserAccountStored {
  NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserEmail];
  NSString* pwd = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPassword];
  if ([email length] > 0 && [pwd length] > 0) {
    return YES;
  }
  return NO;
}

- (BOOL)hasJoinedExperimentWithId:(NSString*)definitionId {
  return [self.model isExperimentJoined:definitionId];
}

- (void)storeEmail:(NSString*)email password:(NSString*)password
{
  NSAssert([email length] > 0 && [password length] > 0, @"There isn't any valid user account to stored!");
  [[NSUserDefaults standardUserDefaults] setObject:email forKey:kUserEmail];
  [[NSUserDefaults standardUserDefaults] setObject:password forKey:kUserPassword];
}

- (void)loginWithCompletionHandler:(void (^)(NSError *))completionHandler
{
  if (SKIP_LOG_IN) {
    [self prefetchInBackgroundWithBlock:^{
      [self startLocationTimerIfNeeded];
    }];
    return;
  }
  
  NSString* email = [[NSUserDefaults standardUserDefaults] objectForKey:kUserEmail];
  NSAssert([email length] > 0, @"There isn't any valid user email stored to use!");
  
  NSString* password = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPassword];
  NSAssert([password length] > 0, @"There isn't any valid user password stored to use!");
  
  [self loginWithClientLogin:email password:password completionHandler:completionHandler];
}

- (void)startLocationTimerIfNeeded {
  // if we have experiments, then initialize PacoLocation which starts a timer
  // (no use to use energy heavy location if no experiment exists)
  if (self.model.experimentInstances.count > 0 && self.location == nil) {
    //NOTE: both NSTimer and CLLocationManager need to be initialized in the main thread to work correctly
    //http://stackoverflow.com/questions/7857323/ios5-what-does-discarding-message-for-event-0-because-of-too-many-unprocessed-m
    dispatch_async(dispatch_get_main_queue(), ^{
      NSLog(@"***********  PacoLocation is allocated, timer starts working! ***********");
      self.location = [[PacoLocation alloc] init];
      self.location.delegate = self;      
    });
  }
}

- (void)loginWithClientLogin:(NSString *)email
                    password:(NSString *)password
           completionHandler:(void (^)(NSError *))completionHandler {
  if ([self.authenticator isLoggedIn] && [self.userEmail isEqualToString:email]) {
    if (completionHandler != nil) {
      completionHandler(nil);
    }
  }else{
    [self.authenticator authenticateWithClientLogin:email//@"paco.test.gv@gmail.com"
                                           password:password//@"qwertylkjhgf"
                                  completionHandler:^(NSError *error) {
                                    if (!error) {
                                      // Authorize the service.
                                      self.service.authenticator = self.authenticator;
                                      self.userEmail = email;
                                      
                                      [self storeEmail:email password:password];
                                      
                                      // Fetch the experiment definitions and the events of joined experiments.
                                      [self prefetchInBackgroundWithBlock:^{
                                        // let's handle setting up the notifications after that thread completes
                                        NSLog(@"Paco loginWithClientLogin experiments load has completed.");
                                        [self startLocationTimerIfNeeded];
                                      }];
                                      
                                      [self uploadPendingEventsInBackground];
                                      completionHandler(nil);
                                    } else {
                                      completionHandler(error);
                                    }
                                  }];    
  }
}

- (void)loginWithOAuth2CompletionHandler:(void (^)(NSError *))completionHandler {
  if ([self.authenticator isLoggedIn]) {
    if (completionHandler != nil) {
      completionHandler(nil);
    }
  }else{
    [self.authenticator authenticateWithOAuth2WithCompletionHandler:^(NSError *error) {
      if (!error) {
        // Authorize the service.
        self.service.authenticator = self.authenticator;
        // Fetch the experiment definitions and the events of joined experiments.
        [self prefetchInBackgroundWithBlock:^{
          // let's handle setting up the notifications after that thread completes
          NSLog(@"Paco loginWithOAuth2CompletionHandler experiments load has completed.");
          [self startLocationTimerIfNeeded];
        }];
        completionHandler(nil);
      } else {
        completionHandler(error);
      }
    }];
  }
}

- (void)uploadPendingEventsInBackground {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.eventManager startUploadingEvents];
  });
}

- (BOOL)prefetchedDefinitions
{
  return self.prefetchState.finishLoadingDefinitions;
}

- (NSError*)errorOfPrefetchingDefinitions
{
  return self.prefetchState.errorLoadingDefinitions;
}

- (BOOL)prefetchedExperiments
{
  return self.prefetchState.finishLoadingExperiments;
}

- (NSError*)errorOfPrefetchingexperiments
{
  return self.prefetchState.errorLoadingExperiments;
}


#pragma mark Private methods
- (void)definitionsLoadedWithError:(NSError*)error
{
  if (ADD_TEST_DEFINITION) {
    // for testing purposes let's load a sample experiment
    //[self.model addExperimentDefinition:[PacoExperimentDefinition testPacoExperimentDefinition]];
    [self.model addExperimentDefinition:[PacoExperimentDefinition testDefinitionWithId:@"999999999"]];
  }
  self.prefetchState.finishLoadingDefinitions = YES;
  self.prefetchState.errorLoadingDefinitions = error;
  [[NSNotificationCenter defaultCenter] postNotificationName:PacoFinishLoadingDefinitionNotification object:error];
}

- (void)prefetchInBackgroundWithBlock:(void (^)(void))completionBlock {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.prefetchState reset];
    // Load the experiment definitions.
    
    if (SKIP_LOG_IN) {
      [self definitionsLoadedWithError:nil];
      [self prefetchExperimentsWithBlock:completionBlock];
      return;      
    }
    
    BOOL success = [self.model loadExperimentDefinitionsFromFile];
    if (success) {
      [self definitionsLoadedWithError:nil];
      [self prefetchExperimentsWithBlock:completionBlock];
      return;
    }
    
    [self.service loadAllExperimentsWithCompletionHandler:^(NSArray *experiments, NSError *error) {
      if (error) {
        NSLog(@"Failed to prefetch definitions: %@", [error description]);
        [self definitionsLoadedWithError:error];
        if (completionBlock) {
          completionBlock();
        }
        return;
      }
      
      NSLog(@"Loaded %d experiments", [experiments count]);
      // Convert the JSON response into an object model.
      [self.model applyDefinitionJSON:experiments];
      [self definitionsLoadedWithError:nil];
      
      [self prefetchExperimentsWithBlock:completionBlock];
    }];

  });

}


- (void)experimentsLoadedWithError:(NSError*)error
{
  self.prefetchState.finishLoadingExperiments = YES;
  self.prefetchState.errorLoadingExperiments = error;
  
  [[NSNotificationCenter defaultCenter] postNotificationName:PacoFinishLoadingExperimentNotification object:error];
}


- (void)prefetchExperimentsWithBlock:(void (^)(void))completionBlock {
  NSError* error = [self.model loadExperimentInstancesFromFile];
  [self experimentsLoadedWithError:error];
  if (completionBlock) {
    completionBlock();
  }
}


#pragma mark stop an experiment
- (void)deleteExperimentFromCache:(PacoExperiment*)experiment
{
  //remove experiment from local cache
  [self.model deleteExperimentInstance:experiment];
  
  //TODO: ymz: clear all scheduled notifications and anything else
}


@end
