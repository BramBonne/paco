package com.pacoapp.paco.sensors.android;

import java.util.List;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.IBinder;
import android.os.PowerManager;
import android.util.Log;

import com.pacoapp.paco.PacoConstants;
import com.pacoapp.paco.UserPreferences;
import com.pacoapp.paco.model.Event;
import com.pacoapp.paco.model.EventUtil;
import com.pacoapp.paco.model.Experiment;
import com.pacoapp.paco.model.ExperimentProviderUtil;
import com.pacoapp.paco.model.Output;
import com.pacoapp.paco.net.SyncService;
import com.pacoapp.paco.shared.model2.ExperimentGroup;
import com.pacoapp.paco.shared.model2.InterruptCue;
import com.pacoapp.paco.shared.model2.InterruptTrigger;
import com.pacoapp.paco.shared.model2.PacoAction;
import com.pacoapp.paco.shared.model2.PacoNotificationAction;
import com.pacoapp.paco.shared.scheduling.ActionSpecification;
import com.pacoapp.paco.shared.util.ExperimentHelper;
import com.pacoapp.paco.shared.util.ExperimentHelper.Trio;
import com.pacoapp.paco.shared.util.TimeUtil;
import com.pacoapp.paco.triggering.AndroidActionExecutor;
import com.pacoapp.paco.triggering.NotificationCreator;

public class BroadcastTriggerService extends Service {

  @Override
  public IBinder onBind(Intent intent) {
    return null;
  }

  public void onStart(Intent intent, int startId) {
    super.onStart(intent, startId);
    if (intent == null) {
      Log.e(PacoConstants.TAG, "Null intent on broadcast trigger!");
      return;
    }
    final Bundle extras = intent.getExtras();

    PowerManager pm = (PowerManager) getSystemService(Context.POWER_SERVICE);
    final PowerManager.WakeLock wl = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK,
                                                    "Paco BroadcastTriggerService wakelock");
    wl.acquire();

    Runnable runnable = new Runnable() {
      public void run() {
        try {
          propagateToExperimentsThatCare(extras);
        } finally {
          wl.release();
          stopSelf();
        }
      }
    };
    (new Thread(runnable)).start();
  }

  protected synchronized void propagateToExperimentsThatCare(Bundle extras) {

    final int triggerEvent = extras.getInt(Experiment.TRIGGER_EVENT);
    final String sourceIdentifier = extras.getString(Experiment.TRIGGER_SOURCE_IDENTIFIER);
    final String timeStr = extras.getString(Experiment.TRIGGERED_TIME);

    // TODO pass the duration along to the experiment somehow (either log it at
    // the moment it happened, or, pass it in the notification (yuck)?
    final long duration = extras.getLong(Experiment.TRIGGER_PHONE_CALL_DURATION);

    DateTime time = null;
    if (timeStr != null) {
      time = DateTimeFormat.forPattern(TimeUtil.DATETIME_FORMAT).parseDateTime(timeStr);
    }

    ExperimentProviderUtil eu = new ExperimentProviderUtil(this);
    DateTime now = new DateTime();
    NotificationCreator notificationCreator = NotificationCreator.create(this);
    List<Experiment> joined = eu.getJoinedExperiments();

    for (Experiment experiment : joined) {
      if (!experiment.isRunning(now) && triggerEvent != InterruptCue.PACO_EXPERIMENT_ENDED_EVENT
          && triggerEvent != InterruptCue.PACO_EXPERIMENT_JOINED_EVENT) {
        // TODO This doesn't work if the experiment for experiment ended events
        // because the experiment is already over.
        Log.i(PacoConstants.TAG, "Skipping experiment: " + experiment.getExperimentDAO().getTitle());
        continue;
      }
      Log.i(PacoConstants.TAG, "We have an experiment that is running");
      List<ExperimentGroup> groupsListening = ExperimentHelper.isBackgroundListeningForSourceId(experiment.getExperimentDAO(),
                                                                                                sourceIdentifier);
      persistBroadcastData(eu, experiment, groupsListening, extras);

      List<Trio<ExperimentGroup, InterruptTrigger, InterruptCue>> triggersThatMatch = ExperimentHelper.shouldTriggerBy(experiment.getExperimentDAO(),
                                                                                                         triggerEvent,
                                                                                                         sourceIdentifier);
      if (ExperimentHelper.declaresAccessibilityLogging(experiment.getExperimentDAO())) {
        List<ExperimentGroup> accessibilityGroupsListening = ExperimentHelper.isListeningForAccessibilityEvents(experiment.getExperimentDAO());
        persistAccessibilityData(eu, experiment, accessibilityGroupsListening, extras.getBundle(RuntimePermissionMonitorService.PACO_ACTION_ACCESSIBILITY_PAYLOAD));
      }

      Log.i(PacoConstants.TAG, "triggers that match count: " + triggersThatMatch.size());
      for (Trio<ExperimentGroup, InterruptTrigger, InterruptCue> triggerInfo : triggersThatMatch) {
        final InterruptTrigger actionTrigger = triggerInfo.second;

        String uniqueStringForTrigger = createUniqueStringForTrigger(experiment, triggerInfo);
        if (!recentlyTriggered(experiment, uniqueStringForTrigger, actionTrigger.getMinimumBuffer())) {
          setRecentlyTriggered(now, uniqueStringForTrigger);

          List<PacoAction> actions = actionTrigger.getActions();
          for (PacoAction pacoAction : actions) {
            final ExperimentGroup group = triggerInfo.first;
            final Long actionTriggerSpecId = triggerInfo.third != null ? triggerInfo.third.getId() : null;
            if (pacoAction.getActionCode() == pacoAction.NOTIFICATION_TO_PARTICIPATE_ACTION_CODE) {
              ActionSpecification timeExperiment = new ActionSpecification(time, experiment.getExperimentDAO(), group,
                                                                           actionTrigger,
                                                                           (PacoNotificationAction) pacoAction,
                                                                           actionTriggerSpecId);
              Log.i(PacoConstants.TAG, "creating a notification");
              final long delay = ((PacoNotificationAction) pacoAction).getDelay();
              notificationCreator.createNotificationsForTrigger(experiment, triggerInfo, delay, time, triggerEvent,
                                                                sourceIdentifier, timeExperiment);
              Log.i(PacoConstants.TAG, "created a notification");
            } else if (pacoAction.getActionCode() == PacoAction.EXECUTE_SCRIPT_ACTION_CODE) {
              AndroidActionExecutor.runAction(getApplicationContext(), pacoAction, experiment,
                                              experiment.getExperimentDAO(), group, actionTriggerSpecId, actionTrigger.getId());
            }
          }
        }
      }
    }
  }

  private void setRecentlyTriggered(DateTime now, String uniqueStringForTrigger) {
    UserPreferences prefs = new UserPreferences(getApplicationContext());
    prefs.setRecentlyTriggeredTime(uniqueStringForTrigger, now);

  }

  private boolean recentlyTriggered(Experiment experiment, String uniqueStringForTrigger, int minimumBuffer) {
    UserPreferences prefs = new UserPreferences(getApplicationContext());
    DateTime recentlyTriggered = prefs.getRecentlyTriggeredTime(uniqueStringForTrigger);
    return recentlyTriggered != null && recentlyTriggered.plusMinutes(minimumBuffer).isAfterNow();
  }

  public String createUniqueStringForTrigger(Experiment experiment, Trio<ExperimentGroup, InterruptTrigger, InterruptCue> triggerInfo) {
    // only create a key down to the trigger -
    return experiment.getId() + ":"
            + triggerInfo.first.getName() + ":"
            + triggerInfo.second.getId();
  }

  /*
   * create and persist event containing any payload data sent along in original PACO_INTENT broadcast
   */
  private void persistBroadcastData(ExperimentProviderUtil eu, Experiment experiment,
                                    List<ExperimentGroup> groupsListening, Bundle extras) {
    long nowMillis = new DateTime().getMillis();
    Bundle payload = extras.getBundle(BroadcastTriggerReceiver.PACO_ACTION_PAYLOAD);
    if (payload == null) {
      Log.v(PacoConstants.TAG, "Not persisting broadcast data without payload");
      return;
    }
    for (ExperimentGroup experimentGroup : groupsListening) {

      Event event = EventUtil.createEvent(experiment, experimentGroup.getName(), nowMillis, null, null, null);
      persistEventBundle(eu, event, payload);
    }
    notifySyncService();
  }

  /**
   * Persist data related to accessibility events, sent along as part of the
   * PACO_ACTION_ACCESSIBILITY_PAYLOAD bundle.
   * @param experimentProviderUtil an initialized ExperimentProviderUtil
   * @param experiment the experiment for which to save the events
   * @param payload the PACO_ACTION_ACCESSIBILITY_PAYLOAD bundle
   */
  private void persistAccessibilityData(ExperimentProviderUtil experimentProviderUtil,
                                        Experiment experiment, List<ExperimentGroup> groupsListening,
                                        Bundle payload) {
    if (payload == null) {
      Log.v(PacoConstants.TAG, "No accessibility data for this trigger.");
      return;
    }
    Log.v(PacoConstants.TAG, "Persisting accessibility data for experiment " + experiment.getExperimentDAO().getTitle());
    long nowMillis = new DateTime().getMillis();
    for (ExperimentGroup experimentGroup : groupsListening) {
      Event event = EventUtil.createEvent(experiment, experimentGroup.getName(), nowMillis, null, null, null);
      persistEventBundle(experimentProviderUtil, event, payload);
    }
    notifySyncService();
  }

  /**
   * Helper function for persistAccessibilityData() and persistBroadcastData().
   * Stores all information in a Bundle in a given Event
   * @param experimentProviderUtil an initialized ExperimentProviderUtil
   * @param event Event for which the data should be stored
   * @param payload The data, as key-value pairs
   */
  private void persistEventBundle(ExperimentProviderUtil experimentProviderUtil, Event event, Bundle payload) {
    for (String key : payload.keySet()) {
      if (payload.get(key) == null) {
        continue;
      }
      Output output = new Output();
      output.setEventId(event.getId());
      output.setName(key);
      output.setAnswer(payload.get(key).toString());
      event.addResponse(output);
    }
    experimentProviderUtil.insertEvent(event);
  }

  private void notifySyncService() {
    startService(new Intent(this, SyncService.class));
  }
}
