import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/constants/campus_locations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/incident_category.dart';
import '../../providers/auth_controller.dart';
import '../../providers/report_form_controller.dart';
import '../../services/incident_repository.dart';
import '../../services/storage_service.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/form_bits.dart';
import '../../widgets/photo_picker_field.dart';
import '../../widgets/primary_button.dart';

class ReportIncidentScreen extends StatelessWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReportFormController(
        repository: context.read<IncidentRepository>(),
        storage: context.read<StorageService>(),
      ),
      child: const _ReportForm(),
    );
  }
}

class _ReportForm extends StatefulWidget {
  const _ReportForm();

  @override
  State<_ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<_ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _spot = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _spot.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto(ReportFormController form) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source != null) await form.pickPhoto(source);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final reporter = context.read<AuthController>().user;
    if (reporter == null) return;

    final form = context.read<ReportFormController>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final submitted = await form.submit(
      reporter: reporter,
      title: _title.text,
      description: _description.text,
      spot: _spot.text,
    );
    if (!mounted || !submitted) return;

    messenger.showSnackBar(const SnackBar(
      content: Text('Report submitted. You can follow it under My Reports.'),
    ));
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ReportFormController>();

    return PopScope(
      canPop: !form.isSubmitting,
      child: Scaffold(
        appBar: AppBar(title: const Text('Report an Incident')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Select a category'),
                  FormField<IncidentCategory>(
                    validator: (_) => form.category == null
                        ? 'Please choose a category'
                        : null,
                    builder: (field) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CategoryGrid(
                          selected: form.category,
                          onSelected: (category) {
                            form.selectCategory(category);
                            field.didChange(category);
                          },
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              field.errorText!,
                              style: const TextStyle(
                                  color: AppColors.danger, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const FieldLabel('Title'),
                  TextFormField(
                    controller: _title,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Briefly describe the issue...',
                    ),
                    validator: Validators.title,
                  ),
                  const SizedBox(height: 6),
                  const FieldLabel('Description'),
                  TextFormField(
                    controller: _description,
                    minLines: 4,
                    maxLines: 7,
                    maxLength: 1000,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Provide more details about the issue, e.g. '
                          'what happened, when it started and how it affects people.',
                      alignLabelWithHint: true,
                    ),
                    validator: Validators.description,
                  ),
                  const SizedBox(height: 6),
                  const FieldLabel('Location'),
                  DropdownButtonFormField<String>(
                    initialValue: form.location,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    decoration: const InputDecoration(
                      hintText: 'Choose a building or area',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    items: [
                      for (final place in CampusLocations.all)
                        DropdownMenuItem(value: place, child: Text(place)),
                    ],
                    onChanged: form.selectLocation,
                    validator: (value) =>
                        value == null ? 'Please choose a location' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _spot,
                    maxLength: 60,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Room or exact spot (optional), e.g. Room 204',
                      prefixIcon: Icon(Icons.meeting_room_outlined),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 22),
                  const FieldLabel('Add a photo', hint: '(optional)'),
                  PhotoPickerField(
                    photo: form.photo,
                    onPick: () => _choosePhoto(form),
                    onRemove: form.removePhoto,
                  ),
                  const SizedBox(height: 24),
                  if (form.error != null) ErrorBanner(message: form.error!),
                  PrimaryButton(
                    label: 'Submit Report',
                    loading: form.isSubmitting,
                    onPressed: _submit,
                  ),
                  if (form.isSubmitting && form.photo != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Uploading your photo, this can take a few seconds...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
