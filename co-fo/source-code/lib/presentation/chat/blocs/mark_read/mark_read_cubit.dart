import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'mark_read_state.dart';

class MarkReadCubit extends Cubit<MarkReadState> {
  MarkReadCubit() : super(MarkReadInitial());

  Future<void> mark({required String threadId}) async {
    try {
      emit(MarkReadLoading());
      final response = await getIt<SupabaseService>().markAsRead(
        threadId: threadId,
      );
      emit(MarkReadSuccess(response: response));
    } catch (e) {
      emit(MarkReadError(error: e));
    }
  }
}
