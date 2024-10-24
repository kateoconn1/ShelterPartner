import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shelter_partner/view_models/auth_view_model.dart';
import 'package:shelter_partner/view_models/device_settings_view_model.dart';
import 'package:shelter_partner/views/components/navigation_button_view.dart';
import 'package:shelter_partner/views/components/number_stepper_view.dart';
import 'package:shelter_partner/views/components/picker_view.dart';
import 'package:shelter_partner/views/components/switch_toggle_view.dart';
import 'package:shelter_partner/views/components/text_field_view.dart';
import 'package:shelter_partner/views/pages/main_filter_page.dart';

class DeviceSettingsPage extends ConsumerStatefulWidget {
  const DeviceSettingsPage({super.key});

  @override
  _DeviceSettingsPageState createState() => _DeviceSettingsPageState();
}

class _DeviceSettingsPageState extends ConsumerState<DeviceSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final shelterAsyncValue = ref.watch(deviceSettingsViewModelProvider);

    return shelterAsyncValue.when(
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text("Device Settings"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text("Device Settings"),
        ),
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
      data: (user) => Scaffold(
        appBar: AppBar(
          title: const Text("Device Settings"),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        PickerView(
                          title: "Main Sort",
                          options: const ["Last Let Out", "Alphabetical"],
                          value:
                              user?.deviceSettings.mainSort ?? "Last Let Out",
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue.isNotEmpty) {
                              ref
                                  .read(
                                      deviceSettingsViewModelProvider.notifier)
                                  .modifyDeviceSettingString(
                                      user!.id, "mainSort", newValue);
                            }
                          },
                        ),
                        PickerView(
                          title: "Visitor Sort",
                          options: const ["Location", "Alphabetical"],
                          value: user?.deviceSettings.visitorSort ??
                              "Alphabetical",
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue.isNotEmpty) {
                              ref
                                  .read(
                                      deviceSettingsViewModelProvider.notifier)
                                  .modifyDeviceSettingString(
                                      user!.id, "visitorSort", newValue);
                            }
                          },
                        ),
                        PickerView(
                          title: "Mode",
                          options: const [
                            "Admin",
                            "Volunteer",
                            "Visitor",
                            "Volunteer & Visitor"
                          ],
                          value: user?.deviceSettings.mode ?? "Admin",
                          onChanged: (String? newValue) {
                            if (newValue != null && newValue.isNotEmpty) {
                              ref
                                  .read(
                                      deviceSettingsViewModelProvider.notifier)
                                  .modifyDeviceSettingString(
                                      user!.id, "mode", newValue);

                              final appUser =
                                  ref.read(appUserProvider.notifier).state;
                              final updatedAppUser = appUser!.copyWith(
                                deviceSettings: appUser.deviceSettings
                                    .copyWith(mode: newValue),
                              );

                              if (context.mounted && newValue != 'Visitor') {
                                context.go('/animals');
                              } else {
                                context.go('/visitors');
                              }

                              // Update the provider with the new state
                              ref.read(appUserProvider.notifier).state =
                                  updatedAppUser;
                            }
                          },
                        ),
                      ]),
                    ),
                  ),
                  Card(
                    child: NavigationButton(
                      title: "Main Filter",
                      route: '/settings/device-settings/main-filter',
                      extra: FilterParameters(
                        collection: 'users',
                        documentID: shelterAsyncValue.value!.id,
                        filterFieldPath: 'deviceSettings.mainFilter',
                      ),
                    ),
                  ),
                  Card(
                    child: NavigationButton(
                      title: "Visitor Filter",
                      route: '/settings/device-settings/visitor-filter',
                      extra: FilterParameters(
                        collection: 'users',
                        documentID: shelterAsyncValue.value!.id,
                        filterFieldPath: 'deviceSettings.visitorFilter',
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        TextFieldView(
                            title: "Custom Form URL",
                            hint: "Custom Form URL",
                            value:
                                user?.deviceSettings.customFormURL as String ??
                                    "",
                            onSaved: (String value) {
                              ref
                                  .read(
                                      deviceSettingsViewModelProvider.notifier)
                                  .modifyDeviceSettingString(
                                      user!.id, "customFormURL", value);
                            }),
                      ]),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        NumberStepperView(
                          title: "Minimum Duration",
                          label: "minutes",
                          value: user?.deviceSettings.minimumLogMinutes ?? 0,
                          increment: () {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .incrementAttribute(
                                    user!.id, "minimumLogMinutes");
                          },
                          decrement: () {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .decrementAttribute(
                                    user!.id, "minimumLogMinutes");
                          },
                        ),
                        
                      ]),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        SwitchToggleView(
                          title: "Photo Uploads Allowed",
                          value:
                              user?.deviceSettings.photoUploadsAllowed ?? false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(
                                    user!.id, "photoUploadsAllowed");
                          },
                        ),
                        SwitchToggleView(
                          title: "Allow Bulk Take Out",
                          value: user?.deviceSettings.allowBulkTakeOut ?? false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(user!.id, "allowBulkTakeOut");
                          },
                        ),
                        
                        SwitchToggleView(
                          title: "Require Let Out Type",
                          value:
                              user?.deviceSettings.requireLetOutType ?? false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(user!.id, "requireLetOutType");
                          },
                        ),
                        SwitchToggleView(
                          title: "Require Early Put Back Reason",
                          value:
                              user?.deviceSettings.requireEarlyPutBackReason ??
                                  false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(
                                    user!.id, "requireEarlyPutBackReason");
                          },
                        ),
                        SwitchToggleView(
                          title: "Require Name",
                          value: user?.deviceSettings.requireName ?? false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(user!.id, "requireName");
                          },
                        ),
                        SwitchToggleView(
                          title: "Create Logs When Under Minimum Duration",
                          value: user?.deviceSettings
                                  .createLogsWhenUnderMinimumDuration ??
                              false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(user!.id,
                                    "createLogsWhenUnderMinimumDuration");
                          },
                        ),
                        
                        SwitchToggleView(
                          title: "Show Custom Form",
                          value: user?.deviceSettings.showCustomForm ?? false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(user!.id, "showCustomForm");
                          },
                        ),
                        SwitchToggleView(
                          title: "Append Animal Data To URL",
                          value: user?.deviceSettings.appendAnimalDataToURL ??
                              false,
                          onChanged: (bool newValue) {
                            ref
                                .read(deviceSettingsViewModelProvider.notifier)
                                .toggleAttribute(
                                    user!.id, "appendAnimalDataToURL");
                          },
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
