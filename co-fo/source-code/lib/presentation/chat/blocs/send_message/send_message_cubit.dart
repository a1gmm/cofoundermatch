import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:uniapp/core/api_service.dart';
import 'package:uniapp/core/injection.dart';

part 'send_message_state.dart';

class SendMessageCubit extends Cubit<SendMessageState> {
  SendMessageCubit() : super(SendMessageInitial());

  Future<void> send({
    required String threadId,
    required String content,
    List<File>? mediaFiles,
  }) async {
    try {
      emit(SendMessageLoading());
      final response = await getIt<SupabaseService>().sendMessage(
        threadId: threadId,
        content: content,
        mediaFiles: mediaFiles,
      );
      emit(SendMessageSuccess(response: response));
    } catch (e) {
      emit(SendMessageError(error: e));
    }
  }
}
