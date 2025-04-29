import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uniapp/data/source/local/models/current_user.dart';

@lazySingleton
class SupabaseService {
  factory SupabaseService() => _instance;
  SupabaseService._internal();
  static final SupabaseService _instance = SupabaseService._internal();

  final _client = Supabase.instance.client;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future signout() async {
    return _client.auth.signOut();
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  Future<dynamic> uploadProfileImage({required File img}) async {
    final bytes = await img.readAsBytes();
    final fileExt = img.path.split('.').last;
    final fileName = '${_client.auth.currentUser!.id}.$fileExt';
    final filePath = fileName;
    await _client.storage
        .from('fs')
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final imageUrlResponse = await _client.storage
        .from('fs')
        .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
    await _client
        .from('profiles')
        .update({'avatar': imageUrlResponse})
        .eq('user_id', _client.auth.currentUser!.id);
    return imageUrlResponse;
  }

  Future<dynamic> completeUserProfile({
    required String username,
    required String userType,
    required String bio,
    required List<String> skills,
    required String title,
  }) async {
    final profile =
        await _client.from('profiles').insert({
          'username': username,
          'user_type': userType,
          'bio': bio,
          'skills': skills,
          'title': title,
          'user_id': _client.auth.currentUser!.id,
        }).select();
    return CurrentUser.fromJson(profile[0]);
  }

  Future<CurrentUser> updateUserProfile({
    required String username,
    required String userType,
    required String bio,
    required List<String> skills,
    required String title,
  }) async {
    final profile =
        await _client
            .from('profiles')
            .update({
              'username': username,
              'user_type': userType,
              'bio': bio,
              'skills': skills,
              'title': title,
            })
            .eq('user_id', _client.auth.currentUser!.id)
            .select();
    return CurrentUser.fromJson(profile[0]);
  }

  Future<CurrentUser?> getUserProfile() async {
    final dynamic profile = await _client
        .from('profiles')
        .select()
        .eq('user_id', _client.auth.currentUser!.id);
    if ((profile as List).isEmpty) {
      return null;
    } else {
      return CurrentUser.fromJson(profile[0]);
    }
  }

  // TODO: Pagination
  Future<dynamic> listOtherUsers({required String userType}) async {
    return await _client
        .from('profiles')
        .select()
        .eq('user_type', userType)
        .neq('user_id', _client.auth.currentUser!.id);
  }

  Future<dynamic> swipeUsers({
    required String swipeeId,
    required bool liked,
  }) async {
    return await _client.rpc(
      'swipe_user',
      params: {
        '_swiper': _client.auth.currentUser!.id,
        '_swipee': swipeeId,
        '_liked': liked,
      },
    );
  }

  Future<dynamic> fetchMembers({required String userType}) async {
    return await _client
        .rpc(
          'get_discoverable_users',
          params: {'_me': _client.auth.currentUser!.id, '_utype': userType},
        )
        .select();
  }

  Future<dynamic> likePost({required String postId}) async {
    return await _client.rpc(
      'toggle_like',
      params: {'user_id': _client.auth.currentUser!.id, 'post_id': postId},
    );
  }

  // TODO: Pagination
  Future<dynamic> listCommunityPosts() async {
    return await _client
        .from('community_posts_with_likes')
        .select('*, profiles(user_id, username, avatar)')
        .order('created_at');
  }

  Future<dynamic> listMemberCommunityPosts({required String memberId}) async {
    return await _client
        .from('community_posts_with_likes')
        .select('*, profiles(user_id, username, avatar)')
        .eq('user_id', memberId)
        .order('created_at');
  }

  Future<dynamic> listUserCommunityPosts() async {
    return await _client
        .from('user_community_posts_with_likes')
        .select('*, profiles(user_id, username, avatar)')
        .order('created_at');
  }

  Future<dynamic> createComment({
    required String commentText,
    required String postId,
  }) async {
    return await _client
        .from('comments')
        .insert({
          'comment_text': commentText,
          'post_id': postId,
          'user_id': _client.auth.currentUser!.id,
        })
        .select('*,profiles(user_id, username, avatar)');
  }

  Future<dynamic> listComments({required String postId}) async {
    return await _client
        .from('comments')
        .select('*,profiles(user_id, username, avatar)')
        .eq('post_id', postId)
        .order('created_at');
  }

  Future<dynamic> listChats() async {
    return await _client.rpc(
      'get_user_chat_threads',
      params: {'_me': _client.auth.currentUser!.id},
    );
  }

  Future<dynamic> sendMessage({
    required String threadId,
    required String content,
    List<File>? mediaFiles,
  }) async {
    List<String> mediaUrls = [];

    if (mediaFiles != null) {
      for (final file in mediaFiles) {
        final url = await uploadPostMedia(
          mediaFile: file,
          folder: 'threads/$threadId',
        );
        if (url != null) {
          mediaUrls.add(url);
        } else {
          return null;
        }
      }
    }
    return await _client
        .rpc(
          'send_message',
          params: {
            '_thread_id': threadId,
            '_sender_id': _client.auth.currentUser!.id,
            '_content': content,
            if (mediaUrls.isNotEmpty) '_media': mediaUrls,
          },
        )
        .select();
  }

  Future<dynamic> markAsRead({required String threadId}) async {
    return await _client.rpc(
      'mark_thread_as_read',
      params: {'_thread_id': threadId, '_me': _client.auth.currentUser!.id},
    );
  }

  Future<dynamic> listThreadMessages({required String threadId}) async {
    return await _client.rpc(
      'get_thread_messages',
      params: {
        '_me': _client.auth.currentUser!.id,
        '_thread_id': threadId,
        '_limit': 50,
        '_offset': 0,
      },
    );
  }

  Future forgotPassword({required String email}) async {
    return await _client.auth.resetPasswordForEmail(email);
  }

  // POST WITH MEDIA
  String _getContentType(String fileExt) {
    switch (fileExt.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  Future<String?> uploadPostMedia({
    required File mediaFile,
    required String folder,
  }) async {
    try {
      final bytes = await mediaFile.readAsBytes();
      final fileExt = mediaFile.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$folder/$fileName';

      await _client.storage
          .from('fs')
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: _getContentType(fileExt),
              upsert: false,
            ),
          );

      final imageUrlResponse = await _client.storage
          .from('fs')
          .createSignedUrl(filePath, 60 * 60 * 24 * 365 * 10);
      return imageUrlResponse;
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> createPost({
    List<File>? mediaFiles,
    required String title,
    required String description,
    required String tag,
  }) async {
    List<String> mediaUrls = [];
    if (mediaFiles != null) {
      for (final file in mediaFiles) {
        final url = await uploadPostMedia(mediaFile: file, folder: 'posts');
        if (url != null) {
          mediaUrls.add(url);
        } else {
          //  deleting already uploaded files for full rollback
          return null;
        }
      }
    }

    final postData = {
      'user_id': _client.auth.currentUser!.id,
      'title': title,
      'description': description,
      if (mediaUrls.isNotEmpty) 'media': mediaUrls,
      'tag': tag,
    };

    final response = await _client.from('community_posts').insert(postData);

    if (response != null) {
      //  delete the uploaded media if post creation fails
      return null;
    }
    return null;
  }

  Future<dynamic> deletePost({
    required String postId,
    required List<String>? mediaUrl,
  }) async {
    await _client.from('community_posts').delete().eq('id', postId);
    if (mediaUrl != null) {
      await _client.storage.from('fs').remove(mediaUrl);
    }
    return null;
  }
}
