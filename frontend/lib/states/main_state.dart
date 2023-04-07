import 'dart:async';
import 'package:dafluta/dafluta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fucking_do_it/dialogs/confirmation_dialog.dart';
import 'package:fucking_do_it/dialogs/create_task_dialog.dart';
import 'package:fucking_do_it/dialogs/options_dialog.dart';
import 'package:fucking_do_it/models/task.dart';
import 'package:fucking_do_it/utils/navigation.dart';
import 'package:fucking_do_it/utils/repository.dart';

class MainState extends BaseState {
  List<Task>? tasksAssignedToMe;
  List<Task>? tasksCreated;
  List<Task>? tasksInProgress;
  List<Task>? tasksInReview;
  StreamSubscription? subscriptionAssignedToMe;
  StreamSubscription? subscriptionCreated;
  StreamSubscription? subscriptionInProgress;
  StreamSubscription? subscriptionInReview;

  @override
  void onLoad() {
    subscriptionAssignedToMe ??= Repository.listenAssignedToMe(onTasksAssignedToMe);
    subscriptionCreated ??= Repository.listenAssignedToMe(onTasksCreated);
    subscriptionInProgress ??= Repository.listenAssignedToMe(onTasksInProgress);
    subscriptionInReview ??= Repository.listenAssignedToMe(onTasksInReview);
  }

  @override
  void onDestroy() {
    subscriptionAssignedToMe?.cancel();
    subscriptionCreated?.cancel();
    subscriptionInProgress?.cancel();
    subscriptionInReview?.cancel();
  }

  Future onTasksAssignedToMe(List<Task> tasks) async {
    tasksAssignedToMe = tasks;
    tasksAssignedToMe!.sort((a, b) => a.compareTo(b));
    notify();
  }

  Future onTasksCreated(List<Task> tasks) async {
    tasksCreated = tasks;
    tasksCreated!.sort((a, b) => a.compareTo(b));
    notify();
  }

  Future onTasksInProgress(List<Task> tasks) async {
    tasksInProgress = tasks;
    tasksInProgress!.sort((a, b) => a.compareTo(b));
    notify();
  }

  Future onTasksInReview(List<Task> tasks) async {
    tasksInReview = tasks;
    tasksInReview!.sort((a, b) => a.compareTo(b));
    notify();
  }

  void onTaskSelected(Task task) {
    onOptionsSelected(task);
  }

  void onOptionsSelected(Task task) {
    OptionsDialog.show(options: [
      Option(
        text: 'Option 1',
        callback: () => onTaskSelected(task),
      ),
      /*Option(
        text: Localized.get.optionUpdate,
        callback: () => onUpdateTask(task),
      ),*/
      Option(
        text: 'Option 2',
        callback: () => ConfirmationDialog.show(
          message: 'Really?',
          callback: () => onTaskDeleted(task),
        ),
      ),
    ]);
  }

  void onTaskDeleted(Task task) {
    tasksAssignedToMe!.remove(task);
    notify();
    Repository.delete(task);
  }

  void onCreateTask(BuildContext context) => CreateTaskDialog.show(context);

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigation.authScreen();
  }
}
