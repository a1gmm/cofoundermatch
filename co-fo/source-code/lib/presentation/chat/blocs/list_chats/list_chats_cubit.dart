import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'list_chats_state.dart';

class ListChatsCubit extends Cubit<ListChatsState> {
  ListChatsCubit() : super(ListChatsInitial());

  Future<void> list() async {
    try {
      emit(ListChatsLoading());
      final response = await getIt<SupabaseService>().listChats();
      emit(ListChatsSuccess(response: response));
    } catch (e) {
      emit(ListChatsError(error: e));
    }
  }
}
