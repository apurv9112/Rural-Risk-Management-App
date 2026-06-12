import 'package:get_it/get_it.dart';
import 'package:rrm/utils/validation_utils.dart';
import 'package:rrm/widgets/snackbar_widget.dart';

const bool isProduction = false; // Environment routing toggle

GetIt getIt = GetIt.instance;

FormValidations get formValidation => GetIt.I.get<FormValidations>();

void initDependencies() {
  getIt.registerLazySingleton<FormValidations>(() => FormValidations());
  getIt.registerLazySingleton<SnackbarHelper>(() => SnackbarHelper());
}
