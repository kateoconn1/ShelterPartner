import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shelter_partner/models/animal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shelter_partner/models/log.dart';
import 'package:shelter_partner/view_models/device_settings_view_model.dart';
import 'package:shelter_partner/view_models/shelter_details_view_model.dart';
import 'package:shelter_partner/view_models/take_out_confirmation_view_model.dart';
import 'package:shelter_partner/views/components/add_note_view.dart';
import 'package:shelter_partner/views/components/put_back_confirmation_view.dart';
import 'package:shelter_partner/views/components/take_out_confirmation_view.dart';
import 'package:uuid/uuid.dart';

class AnimalCardView extends ConsumerStatefulWidget {
  final Animal animal;

  const AnimalCardView({super.key, required this.animal});

  @override
  _AnimalCardViewState createState() => _AnimalCardViewState();
}

/// Helper method to calculate time ago from a given DateTime
String _timeAgo(DateTime dateTime, bool inKennel) {
  final Duration difference = DateTime.now().difference(dateTime);

  if (difference.inDays > 8) {
    return '${(difference.inDays / 7).floor()} weeks${inKennel ? ' ago' : ''}';
  } else if (difference.inDays >= 1) {
    return '${difference.inDays} days${inKennel ? ' ago' : ''}';
  } else if (difference.inHours >= 1) {
    return '${difference.inHours} hours${inKennel ? ' ago' : ''}';
  } else if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} minutes${inKennel ? ' ago' : ''}';
  } else {
    return inKennel ? 'Just now' : '0 minutes';
  }
}

class _AnimalCardViewState extends ConsumerState<AnimalCardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _curvedAnimation;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // 2 seconds duration
    );

    // Non-linear progress curve: slow at first, speeding up later
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // Listen for animation completion
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Reset the animation instantly
        _controller.reset();

        // Retrieve the latest animal state
        final currentAnimal = widget.animal;

        // Animation completed, show confirmation dialog
        if (currentAnimal.inKennel) {
          final deviceDetails = ref.read(deviceSettingsViewModelProvider).value;
          if (deviceDetails != null &&
              (deviceDetails.deviceSettings.requireName ||
                  deviceDetails.deviceSettings.requireLetOutType)) {
            _showTakeOutConfirmationDialog();
          } else {
            ref
                .read(takeOutConfirmationViewModelProvider(widget.animal)
                    .notifier)
                .takeOutAnimal(
                    widget.animal,
                    Log(
                      id: const Uuid().v4().toString(),
                      type: '',
                      author: '',
                      earlyReason: '',
                      startTime: Timestamp.now(),
                      endTime: widget.animal.logs.last.endTime,
                    ));
          }
        } else {
            _showPutBackConfirmationDialog();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String getScaledDownUrl(String url) {
    final parts = url.split('.');
    if (parts.length > 1) {
      parts[parts.length - 2] += '_100x100';
    }
    return parts.join('.');
  }

  Future<void> _showTakeOutConfirmationDialog() async {
    // Show the custom confirmation widget using the ref object
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return TakeOutConfirmationView(
          animal: widget.animal,
        );
      },
    );
  }

  Future<void> showErrorDialog(
      {required BuildContext context, required String message}) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPutBackConfirmationDialog() async {
    // Show the custom confirmation dialog using the helper
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return PutBackConfirmationView(
          animal: widget.animal,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;
    final shelterDetailsAsync = ref.watch(shelterDetailsViewModelProvider);

    // Determine if shelterID is available
    bool canInteract = false;
    shelterDetailsAsync.when(
      data: (shelter) {
        if (shelter != null && shelter.id.isNotEmpty) {
          canInteract = true;
        }
      },
      loading: () {
        canInteract = false;
      },
      error: (error, stack) {
        canInteract = false;
      },
    );

    return Card(
      color:
          animal.inKennel ? Colors.lightBlue.shade100 : Colors.orange.shade100,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Updated Animal details: name and information grid
            Column(
              children: [
                GestureDetector(
                  onTapDown: canInteract
                      ? (_) {
                          setState(() {
                            isPressed = true;
                          });
                          _controller.forward();
                        }
                      : null,
                  onTapCancel: () {
                    setState(() {
                      isPressed = false;
                    });
                    _controller.reverse();
                  },
                  onLongPressStart: canInteract
                      ? (_) {
                          setState(() {
                            isPressed =
                                true; // Set isPressed to true when long press starts
                          });
                          _controller.forward();
                        }
                      : null,
                  onLongPressEnd: canInteract
                      ? (_) {
                          setState(() {
                            isPressed =
                                false; // Set isPressed to false when long press ends
                          });
                          _controller
                              .reverse(); // Reverse animation when user lets go
                        }
                      : null,
                  onLongPressCancel: canInteract
                      ? () {
                          setState(() {
                            isPressed =
                                false; // Set isPressed to false when long press is canceled
                          });
                          _controller.reverse();
                        }
                      : null,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background stroke (semi-transparent)
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.black
                            .withOpacity(0.2), // Semi-transparent stroke
                      ),

                      // Circular progress animation
                      AnimatedBuilder(
                        animation: _curvedAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width: 115,
                            height: 115,
                            child: CircularProgressIndicator(
                              value: _curvedAnimation.value,
                              strokeWidth:
                                  15, // Match the lineWidth from SwiftUI
                              valueColor: AlwaysStoppedAnimation<Color>(
                                animal.inKennel
                                    ? Colors.orange.shade100
                                    : Colors.lightBlue
                                        .shade100, // Change color based on `inCage`
                              ),
                            ),
                          );
                        },
                      ),

                      // Image with shadow and scale effect
                      AnimatedScale(
                        scale: isPressed ? 1.0 : 1.025, // Scale effect on press
                        duration: const Duration(
                            milliseconds: 0), // Match SwiftUI scaling duration
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.6), // Shadow color
                                blurRadius: 0.9, // Blur radius for the shadow
                                spreadRadius: 0, // Spread radius for the shadow
                                offset: isPressed
                                    ? const Offset(0, 0)
                                    : const Offset(
                                        1, 1), // Offset for the shadow
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                isPressed
                                    ? Colors.black.withOpacity(0.03)
                                    : Colors.transparent, // Darken when pressed
                                BlendMode.darken, // Apply darkening effect
                              ),
                              child: CachedNetworkImage(
                                imageUrl:
                                    getScaledDownUrl(animal.photos.first.url),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .start, // Ensures content aligns to the top
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            animal.name,
                            style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (animal.symbol.isNotEmpty)
                            _buildIcon(animal.symbol, animal.symbolColor)
                        ],
                      ),
                      PopupMenuButton<String>(
                        offset: const Offset(0,
                            40), // Adjust the offset to attach to one of the corners
                        onSelected: (value) {
                          // Handle menu item selection
                          switch (value) {
                            case 'Details':
                              context.push('/animals/details', extra: animal);
                              // Navigator.of(context,).push(
                              // MaterialPageRoute(
                              //   builder: (context) =>
                              //     AnimalsAnimalDetailPage(animal: animal),
                              // ),
                              // );
                              break;
                            case 'Add Note':
                              // show a sheet on top of the current screen with the AddNoteView
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    AddNoteView(animal: animal),
                              );

                              break;
                            // Add more cases as needed
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return {'Details', 'Add Note'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                        icon: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 5), // Adjust spacing between name and chips
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _buildInfoChip(
                        icon: Icons.location_on,
                        label: animal.location,
                      ),
                      _buildInfoChip(
                        icon: Icons.shopping_bag,
                        label: animal.adoptionCategory,
                      ),
                      _buildInfoChip(
                        icon: Icons.face,
                        label: animal.behaviorCategory,
                      ),
                      _buildInfoChip(
                        icon: Icons.location_city,
                        label: animal.locationCategory,
                      ),
                      _buildInfoChip(
                        icon: Icons.health_and_safety,
                        label: animal.medicalCategory,
                      ),
                      _buildInfoChip(
                        icon: Icons.volunteer_activism,
                        label: animal.volunteerCategory,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                    Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      // Display the top 3 most popular tags as chips
                      for (final tag in (animal.tags..sort((a, b) => b.count.compareTo(a.count))).take(3))
                      _buildTagChip(label: tag.title),
                    ],
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 16.0, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        "${_timeAgo(widget.animal.inKennel ? animal.logs.last.endTime.toDate() : animal.logs.last.startTime.toDate(), widget.animal.inKennel)}${animal.logs.last.type.isNotEmpty ? ' (${animal.logs.last.type})' : ''}",
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.person_2_outlined,
                          size: 16.0, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        animal.logs.last.author,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildInfoChip({
  required IconData icon,
  required String label,
  double textSize = 10.0,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.5)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 12,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: textSize),
        ),
      ],
    ),
  );
}

Widget _buildTagChip({
  required String label,
  double textSize = 10.0,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.25),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.black.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.sell,
          size: 12,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: Colors.black, fontSize: textSize),
        ),
      ],
    ),
  );
}

Icon _buildIcon(String symbol, String symbolColor) {
  IconData iconData;

  switch (symbol) {
    case 'pets':
      iconData = Icons.pets;
      break;
    case 'location_on':
      iconData = Icons.location_on;
      break;
    case 'star':
      iconData = Icons.star;
      break;
    default:
      iconData = Icons.help_outline;
  }

  return Icon(
    iconData,
    color: _parseColor(symbolColor),
    shadows: [
      Shadow(
        blurRadius: 1.0,
        color: Colors.black.withOpacity(0.7),
        offset: const Offset(0.35, 0.35),
      ),
    ],
  );
}

Color _parseColor(String colorString) {
  colorString = colorString.replaceAll('#', '');

  if (colorString.length == 6) {
    colorString = 'FF$colorString';
  }

  return Color(int.parse(colorString, radix: 16));
}
