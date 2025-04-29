import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'list_messages_state.dart';

class ListMessagesCubit extends Cubit<ListMessagesState> {
  ListMessagesCubit() : super(ListMessagesInitial());

  Future<void> list({required String threadId}) async {
    try {
      emit(ListMessagesLoading());
      final response = await getIt<SupabaseService>().listThreadMessages(
        threadId: threadId,
      );
      emit(ListMessagesSuccess(response: response));
    } catch (e) {
      emit(ListMessagesError(error: e));
    }
  }
}
