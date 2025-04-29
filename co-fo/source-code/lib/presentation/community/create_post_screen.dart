import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/community/extra/video_trimmer_screen.dart';
import 'package:uniapp/presentation/community/imports.dart';
import 'package:uniapp/presentation/profile/imports.dart';
import 'package:uniapp/presentation/widgets/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create post')),
      body: Column(
        children: [
          SizedBox(
            width: 1.sw,
            child: Card(
              elevation: 0,
              color: Theme.of(context).primaryColor,
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'I have an idea 💡',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Looking for co-founders to build my startup',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ).p(24),
            ).onTap(
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder:
                      (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (context) => CreatePostCubit()),
                          BlocProvider(create: (context) => MediaPickerCubit()),
                          BlocProvider(create: (context) => VideoPickerCubit()),
                        ],
                        child: CreateProjectModal(type: 'project'),
                      ),
                ),
              ),
            ),
          ),
          Gap(16),
          SizedBox(
            width: 1.sw,
            child: Card(
              elevation: 0,
              color: Color(0xfff97316),
              child: Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'I have skills 🚀',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Ready to join an exciting startup',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ).p(24),
            ).onTap(
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder:
                      (context) => MultiBlocProvider(
                        providers: [
                          BlocProvider(create: (context) => CreatePostCubit()),
                          BlocProvider(create: (context) => MediaPickerCubit()),
                          BlocProvider(create: (context) => VideoPickerCubit()),
                        ],
                        child: CreateProjectModal(type: 'skill'),
                      ),
                ),
              ),
            ),
          ),
        ],
      ).p(16),
    );
  }
}

class CreateProjectModal extends StatefulWidget {
  const CreateProjectModal({super.key, required this.type});
  final String type;

  @override
  State<CreateProjectModal> createState() => _CreateProjectModalState();
}

class _CreateProjectModalState extends State<CreateProjectModal> {
  final _formKey = GlobalKey<FormBuilderState>();
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();

  final List<File> _selectedMedia = [];
  final Map<File, Future<Uint8List?>> _videoThumbnailFutures = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.type.capitalized)),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              if (_selectedMedia.isNotEmpty)
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedMedia.length,
                    itemBuilder: (_, i) {
                      final file = _selectedMedia[i];
                      final isVideo = isVideoFile(file);

                      if (isVideo &&
                          !_videoThumbnailFutures.containsKey(file)) {
                        _videoThumbnailFutures[file] = generateVideoThumbnail(
                          file.path,
                        );
                      }

                      return FutureBuilder<Uint8List?>(
                        future:
                            isVideo
                                ? _videoThumbnailFutures[file]
                                : Future.value(null),
                        builder: (_, snapshot) {
                          Widget mediaWidget;

                          if (isVideo) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              mediaWidget = Container(
                                width: 80,
                                height: 80,
                                color: Colors.black26,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            } else {
                              final thumbnail = snapshot.data;
                              mediaWidget =
                                  thumbnail != null
                                      ? Image.memory(
                                        thumbnail,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                      : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.black45,
                                        child: const Icon(
                                          Icons.videocam,
                                          color: Colors.white70,
                                        ),
                                      );
                            }
                          } else {
                            mediaWidget = Image.file(
                              file,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            );
                          }

                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(7),
                                child: mediaWidget,
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap:
                                      () => setState(() {
                                        _videoThumbnailFutures.remove(file);
                                        _selectedMedia.removeAt(i);
                                      }),
                                  child: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ).pOnly(right: 8);
                        },
                      );
                    },
                  ),
                ).pOnly(bottom: 16),

              FormBuilderTextField(
                name: 'title',
                // style: Theme.of(context).textTheme.bodyMedium,
                autofocus: true,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                inputFormatters: [LengthLimitingTextInputFormatter(25)],
                controller: titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(isDense: true, labelText: 'Title'),
              ),
              const Gap(16),
              FormBuilderTextField(
                name: 'desc',
                maxLines: 3,
                // style: Theme.of(context).textTheme.bodyMedium,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                inputFormatters: [LengthLimitingTextInputFormatter(100)],
                controller: descriptionCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Description',
                  alignLabelWithHint: true,
                ),
              ),
              Gap(16),
              if (_selectedMedia.length < 3)
                MultiBlocListener(
                  listeners: [
                    BlocListener<MediaPickerCubit, MediaPickerState>(
                      listener: (ctx, state) {
                        if (state is MediaPickerSuccess) {
                          setState(() {
                            if (_selectedMedia.length < 3) {
                              _selectedMedia.add(state.image);
                            }
                          });
                        }
                      },
                    ),
                    BlocListener<VideoPickerCubit, VideoPickerState>(
                      listener: (ctx, state) {
                        if (state is VideoPickerSuccess) {
                          Navigator.push<File?>(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder:
                                  (_) =>
                                      VideoTrimmerScreen(vid: state.response),
                            ),
                          ).then((trimmed) {
                            if (trimmed != null) {
                              setState(() {
                                if (_selectedMedia.length < 3) {
                                  _selectedMedia.add(trimmed);
                                }
                              });
                            }
                          });
                        }
                      },
                    ),
                  ],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed:
                            () =>
                                context.read<MediaPickerCubit>().selectImage(),
                        icon: Icon(Symbols.add_photo_alternate),
                      ),
                      IconButton(
                        onPressed:
                            () =>
                                context.read<VideoPickerCubit>().selectVideo(),
                        icon: Icon(Symbols.videocam),
                      ),
                    ],
                  ),
                ),
              Gap(24),
              BlocConsumer<CreatePostCubit, CreatePostState>(
                listener: (context, state) {
                  if (state is CreatePostError) {
                    context.showToast(msg: 'Something went wrong. Try again');
                  }
                  if (state is CreatePostSuccess) {
                    context.showToast(msg: 'Successful');
                    context.pop();
                  }
                },
                builder:
                    (context, state) => switch (state) {
                      CreatePostLoading() =>
                        StandardButton(text: 'Post', onPressed: null).shimmer(),
                      _ => StandardButton(
                        text: 'Post',
                        onPressed: () {
                          context.hideKeyboard(context);
                          if (_formKey.currentState!.validate()) {
                            context.read<CreatePostCubit>().create(
                              description: descriptionCtrl.text.trim(),
                              title: titleCtrl.text.trim(),
                              tag: widget.type,
                              mediaFiles: _selectedMedia,
                            );
                          }
                        },
                      ),
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
