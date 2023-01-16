import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'purchase_cubit.freezed.dart';
part 'purchase_state.dart';

@injectable
class PurchaseCubit extends Cubit<PurchaseState> {
  PurchaseCubit() : super(const PurchaseState.initial());
}
