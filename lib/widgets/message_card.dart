import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../model/message.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () => _showCompactOptionsMenu(isMe),
        child: isMe ? _greenMessage() : _blueMessage());
  }

  // sender or another user message
  Widget _blueMessage() {
    // Update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Align message to the left
      children: [
        // Message content and time
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message bubble
              Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .03
                    : mq.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .01),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(color: Colors.deepOrange),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    : ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
              ),

              // Message time below the bubble
              Padding(
                padding: EdgeInsets.only(left: mq.width * .04),
                child: Text(
                  MyDateUtil.getFormattedTime(
                      context: context, time: widget.message.sent),
                  style: const TextStyle(fontSize: 13, color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.end, // Align message to the right for sender
      children: [
        // Message content and time
        Flexible(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.end, // Align content to the right
            children: [
              // Message bubble
              Container(
                padding: EdgeInsets.all(widget.message.type == Type.image
                    ? mq.width * .03
                    : mq.width * .04),
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .01),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  border: Border.all(color: Colors.deepPurple),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                  ),
                ),
                child: widget.message.type == Type.text
                    ? Text(
                        widget.message.msg,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black87),
                      )
                    : ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image, size: 70),
                        ),
                      ),
              ),

              // Message time below the bubble
              Padding(
                padding: EdgeInsets.only(right: mq.width * .04),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Time aligned to the right
                  children: [
                    // For adding some space
                    SizedBox(width: mq.width * .04),

                    // Sent time
                    Text(
                      MyDateUtil.getFormattedTime(
                          context: context, time: widget.message.sent),
                      style:
                          const TextStyle(fontSize: 13, color: Colors.white54),
                    ),

                    const SizedBox(
                      width: 4,
                    ),
                    // Double tick blue icon for message read
                    if (widget.message.read.isNotEmpty)
                      const Icon(Icons.done_all_rounded,
                          color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCompactOptionsMenu(bool isMe) {
    showMenu(
      color: Colors.black12,
      context: context,
      position: RelativeRect.fromLTRB(
          mq.width * .7, mq.height * .1, 0, 0), // Adjust the position as needed
      items: [
        // Copy option
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.copy_all_rounded,
                  color: Color(0xFF9C89FF), size: 26),
              SizedBox(width: mq.width * .02),
              const Text(
                'Copy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),

        // Edit option (only if it's the sender's message and it's a text)
        if (widget.message.type == Type.text && isMe)
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit,
                    color: Theme.of(context).colorScheme.secondary, size: 26),
                SizedBox(width: mq.width * .02),
                const Text(
                  'Edit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

        // Delete option (only if it's the sender's message)
        if (isMe)
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_forever,
                    color: Theme.of(context).colorScheme.primary, size: 26),
                SizedBox(width: mq.width * .02),
                const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
      elevation: 8.0,
    ).then((value) {
      // Handle menu item selection
      if (value == 'copy') {
        Clipboard.setData(ClipboardData(text: widget.message.msg)).then((_) {
          Dialogs.showSnackbar(context, 'Text Copied!');
        });
      } else if (value == 'edit' && isMe) {
        _showMessageUpdateDialog();
      } else if (value == 'delete' && isMe) {
        APIs.deleteMessage(widget.message);
      }
    });
  }

  //dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),

        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),

        //title
        title: const Row(
          children: [
            Icon(
              Icons.message,
              color: Colors.blue,
              size: 28,
            ),
            Text(' Update Message')
          ],
        ),

        //content
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)))),
        ),

        //actions
        actions: [
          //cancel button
          MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              )),

          //update button
          MaterialButton(
              onPressed: () {
                //hide alert dialog
                Navigator.pop(context);
                APIs.updateMessage(widget.message, updatedMsg);
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ))
        ],
      ),
    );
  }
}

//custom options card (for copy, edit, delete, etc.)
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
