import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:io_expense_data/models/budget_data.dart';
import '/UI/budget/progress_calculator.dart';
import '/models/transaction_data.dart';
import '/helper/database_helper.dart';

class NotificationService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  BudgetProgressCalculator calculateProgress = BudgetProgressCalculator();

  static void init() {
    AwesomeNotifications().initialize(
      '/assets://expense_app_logo.webp',
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );
  }

  static void showNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'high_importance_channel',
        title: 'Simple Notification',
        body: 'Simple body',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        autoDismissible: true,
        category: NotificationCategory.Reminder,
      ),
    );
  }

  void showBudgetStatusNotification(transaction_data transaction) async {
    final category = transaction.category;
    final date = transaction.date.toString();

    budget_data budget = await _dbHelper.getBudgetByCategory(category, date);
    final totalSpent =
        await calculateProgress.calculateCategoryProgress(budget);

    if (totalSpent == 1) {
      showBudgetOverSpentNoti(category);
    } else if (totalSpent == 0.75) {
      showBudgetAlmostOverSpentNoti(category);
    }
  }

  void showBudgetAlmostOverSpentNoti(String category) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: 'high_importance_channel',
        title: 'Budget Almost Over Spent: $category',
        body: 'You have spent 75% of your budget',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        autoDismissible: true,
        category: NotificationCategory.Reminder,
      ),
    );
  }

  void showBudgetOverSpentNoti(String category) async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 12,
        channelKey: 'high_importance_channel',
        title: 'Budget Over Spent: $category',
        body: 'You have spent more than your budget',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
        autoDismissible: true,
        category: NotificationCategory.Reminder,
      ),
    );
  }
}
