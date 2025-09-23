import 'package:flutter/material.dart';
import 'notification_model.dart';

void showNotificationModal(
  BuildContext context,
  List<NotificationModel> notifications,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(12.0),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(notif.title),
              subtitle: notif.type == "mood"
                  ? Row(
                      children: [
                        IconButton(
                          icon: const Text(
                            "😄",
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            /* Save mood happy */
                          },
                        ),
                        IconButton(
                          icon: const Text(
                            "😐",
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            /* Save mood neutral */
                          },
                        ),
                        IconButton(
                          icon: const Text(
                            "☹️",
                            style: TextStyle(fontSize: 24),
                          ),
                          onPressed: () {
                            /* Save mood sad */
                          },
                        ),
                      ],
                    )
                  : Text(notif.body),
              trailing: notif.type == "chat"
                  ? ElevatedButton(
                      onPressed: () {
                        // Navigate to chat
                      },
                      child: const Text("Chat Now"),
                    )
                  : null,
            ),
          );
        },
      ),
    ),
  );
}
