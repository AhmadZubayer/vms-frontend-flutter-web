import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../domain/vehicle.dart';
import '../../domain/vehicle_status.dart';
import '../../domain/vehicle_type.dart';
import '../vehicles_controller.dart';

/// Registers a vehicle, or replaces the details of [vehicle].
///
/// Pops `true` once the API has accepted the change, so the caller can report
/// it; field problems the API reports are shown on the fields themselves.
class VehicleFormSheet extends ConsumerStatefulWidget {
  const VehicleFormSheet({super.key, this.vehicle});

  final Vehicle? vehicle;

  bool get isUpdate => vehicle != null;

  @override
  ConsumerState<VehicleFormSheet> createState() => _VehicleFormSheetState();
}

class _VehicleFormSheetState extends ConsumerState<VehicleFormSheet> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  late final TextEditingController _vehicleNumber;
  late final TextEditingController _brand;
  late final TextEditingController _company;
  late final TextEditingController _model;

  late VehicleType _type;
  late VehicleStatus _status;

  final Map<String, String> _serverErrors = <String, String>{};
  String? _failure;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final Vehicle? vehicle = widget.vehicle;

    _vehicleNumber = TextEditingController(text: vehicle?.vehicleNumber ?? '');
    _brand = TextEditingController(text: vehicle?.brand ?? '');
    _company = TextEditingController(text: vehicle?.company ?? '');
    _model = TextEditingController(text: vehicle?.model ?? '');
    _type = VehicleType.tryParse(vehicle?.type) ?? VehicleType.car;
    _status = VehicleStatus.tryParse(vehicle?.status) ?? VehicleStatus.active;
  }

  @override
  void dispose() {
    _vehicleNumber.dispose();
    _brand.dispose();
    _company.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _saving = true;
      _failure = null;
    });

    final VehicleDraft draft = VehicleDraft(
      vehicleNumber: _vehicleNumber.text.trim(),
      brand: _brand.text.trim(),
      company: _company.text.trim(),
      model: _model.text.trim(),
      type: _type,
      status: _status,
    );

    try {
      final VehicleMutations mutations = ref.read(vehicleMutationsProvider);
      final Vehicle? existing = widget.vehicle;
      if (existing == null) {
        await mutations.create(draft);
      } else {
        await mutations.update(existing.id, draft);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saving = false;
        _failure = error.fieldErrors.isEmpty ? error.message : null;
        _serverErrors
          ..clear()
          ..addAll(error.fieldErrors);
      });
      _form.currentState?.validate();
    } on Object {
      if (mounted) {
        setState(() {
          _saving = false;
          _failure = 'The vehicle could not be saved. Try again.';
        });
      }
    }
  }

  /// A problem the API reported stands until that field is edited.
  void _clearServerError(String field) {
    if (_serverErrors.remove(field) != null) {
      setState(() {});
    }
  }

  String? _validateText(String field, String? value, String label) {
    final String? serverError = _serverErrors[field];
    if (serverError != null) {
      return serverError;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Enter the $label';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 12, 8),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  widget.isUpdate ? 'Update vehicle' : 'Add new vehicle',
                  style: theme.typography.display.xl,
                ),
              ),
              FButton.icon(variant: FButtonVariant.ghost,
                semanticsLabel: 'Close',
                onPress: _saving ? null : () => Navigator.of(context).pop(),
                prefix: const Icon(FLucideIcons.x),
              ),
            ],
          ),
        ),
        const FDivider(),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (_failure != null) ...<Widget>[
                    _FormFailure(message: _failure!),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _vehicleNumber,
                    autofocus: true,
                    maxLength: 64,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle number',
                      helperText: 'Unique across the registry',
                    ),
                    onChanged: (String _) => _clearServerError('vehicleNumber'),
                    validator: (String? value) => _validateText(
                      'vehicleNumber',
                      value,
                      'vehicle number',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _brand,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Brand'),
                    onChanged: (String _) => _clearServerError('brand'),
                    validator: (String? value) =>
                        _validateText('brand', value, 'brand'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _company,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Company'),
                    onChanged: (String _) => _clearServerError('company'),
                    validator: (String? value) =>
                        _validateText('company', value, 'company'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _model,
                    maxLength: 100,
                    decoration: const InputDecoration(labelText: 'Model'),
                    onChanged: (String _) => _clearServerError('model'),
                    validator: (String? value) =>
                        _validateText('model', value, 'model'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<VehicleType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: <DropdownMenuItem<VehicleType>>[
                      for (final VehicleType type in VehicleType.values)
                        DropdownMenuItem<VehicleType>(
                          value: type,
                          child: Text(type.label),
                        ),
                    ],
                    onChanged: (VehicleType? value) {
                      if (value != null) {
                        setState(() => _type = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<VehicleStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: <DropdownMenuItem<VehicleStatus>>[
                      for (final VehicleStatus status in VehicleStatus.values)
                        DropdownMenuItem<VehicleStatus>(
                          value: status,
                          child: Text(status.label),
                        ),
                    ],
                    onChanged: (VehicleStatus? value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const FDivider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FButton(variant: FButtonVariant.ghost, mainAxisSize: MainAxisSize.min,
                onPress: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FButton(mainAxisSize: MainAxisSize.min,
                onPress: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: FCircularProgress(),
                      )
                    : Text(widget.isUpdate ? 'Save changes' : 'Add vehicle'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormFailure extends StatelessWidget {
  const _FormFailure({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colors.error,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            FLucideIcons.circleAlert,
            size: 18,
            color: theme.colors.errorForeground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.typography.body.sm.copyWith(
                color: theme.colors.errorForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
