import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
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
      final Vehicle? existing = widget.vehicle;
      if (existing == null) {
        await ref.createVehicle(draft);
      } else {
        await ref.updateVehicle(existing.id, draft);
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.isUpdate ? 'Update vehicle' : 'Add new vehicle',
                  style: context.theme.typography.display.lg,
                ),
              ),
              FButton.icon(
                variant: FButtonVariant.ghost,
                semanticsLabel: 'Close',
                onPress: _saving ? null : () => Navigator.of(context).pop(),
                child: const Icon(FLucideIcons.x),
              ),
            ],
          ),
        ),
        const FDivider(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  if (_failure != null)
                    FAlert(
                      variant: FAlertVariant.destructive,
                      icon: const Icon(FLucideIcons.circleAlert),
                      title: Text(_failure!),
                    ),
                  FTextFormField(
                    control: FTextFieldControl.managed(
                      controller: _vehicleNumber,
                      onChange: (_) => _clearServerError('vehicleNumber'),
                    ),
                    autofocus: true,
                    enabled: !_saving,
                    maxLength: 64,
                    textCapitalization: TextCapitalization.characters,
                    label: const Text('Vehicle number'),
                    description: const Text('Unique across the registry'),
                    validator: (value) =>
                        _validateText('vehicleNumber', value, 'vehicle number'),
                  ),
                  FTextFormField(
                    control: FTextFieldControl.managed(
                      controller: _brand,
                      onChange: (_) => _clearServerError('brand'),
                    ),
                    enabled: !_saving,
                    maxLength: 100,
                    label: const Text('Brand'),
                    validator: (value) =>
                        _validateText('brand', value, 'brand'),
                  ),
                  FTextFormField(
                    control: FTextFieldControl.managed(
                      controller: _company,
                      onChange: (_) => _clearServerError('company'),
                    ),
                    enabled: !_saving,
                    maxLength: 100,
                    label: const Text('Company'),
                    validator: (value) =>
                        _validateText('company', value, 'company'),
                  ),
                  FTextFormField(
                    control: FTextFieldControl.managed(
                      controller: _model,
                      onChange: (_) => _clearServerError('model'),
                    ),
                    enabled: !_saving,
                    maxLength: 100,
                    label: const Text('Model'),
                    validator: (value) =>
                        _validateText('model', value, 'model'),
                  ),
                  FSelect<VehicleType>(
                    label: const Text('Type'),
                    enabled: !_saving,
                    items: {
                      for (final type in VehicleType.values) type.label: type,
                    },
                    control: FSelectControl.lifted(
                      value: _type,
                      onChange: (value) {
                        if (value != null) setState(() => _type = value);
                      },
                    ),
                  ),
                  FSelect<VehicleStatus>(
                    label: const Text('Status'),
                    enabled: !_saving,
                    items: {
                      for (final status in VehicleStatus.values)
                        status.label: status,
                    },
                    control: FSelectControl.lifted(
                      value: _status,
                      onChange: (value) {
                        if (value != null) setState(() => _status = value);
                      },
                    ),
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
            children: [
              FButton(
                variant: FButtonVariant.outline,
                mainAxisSize: MainAxisSize.min,
                onPress: _saving ? null : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              FButton(
                mainAxisSize: MainAxisSize.min,
                onPress: _saving ? null : _save,
                child: _saving
                    ? FCircularProgress(
                        style: .delta(
                          iconStyle: .delta(
                            color: context.theme.colors.primaryForeground,
                          ),
                        ),
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
