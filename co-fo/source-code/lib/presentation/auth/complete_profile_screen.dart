import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:uniapp/app/app_router.dart';
import 'package:uniapp/presentation/auth/imports.dart';
import 'package:uniapp/presentation/widgets/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  final usernameCtrl = TextEditingController();
  final titleCtrl = TextEditingController();
  final tagsController = TextEditingController();
  final bioCtrl = TextEditingController();
  final userTypeCtrl = TextEditingController();

  List<String> userSkills = [];
  int maxTags = 5;

  @override
  initState() {
    super.initState();
    _initData();
  }

  _onChanged() => setState(() {});

  bool isValidTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isEmpty) return false;
    if (trimmedTag.length > 20) return false;
    return true;
  }

  _initData() {
    userTypeCtrl.text = 'ideator';
    _onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete profile')),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              Wrap(
                spacing: 4,
                children: [
                  ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    label: const Text('I am an ideator'),
                    selected: userTypeCtrl.text == 'ideator',
                    onSelected: (isSelected) {
                      userTypeCtrl.text = isSelected ? 'ideator' : '';
                      _onChanged();
                    },
                  ),
                  ChoiceChip(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    label: const Text('I am a builder'),
                    selected: userTypeCtrl.text == 'builder',
                    onSelected: (isSelected) {
                      userTypeCtrl.text = isSelected ? 'builder' : '';
                      _onChanged();
                    },
                  ),
                ],
              ),
              Gap(16),
              FormBuilderTextField(
                name: 'username',
                autofocus: true,
                style: Theme.of(context).textTheme.bodyMedium,
                autofillHints: const <String>[AutofillHints.name],
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                controller: usernameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Username',
                  hintText: 'e.g James Doe',
                ),
              ),
              const Gap(16),
              FormBuilderTextField(
                name: 'title',
                style: Theme.of(context).textTheme.bodyMedium,

                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
                inputFormatters: [LengthLimitingTextInputFormatter(50)],
                controller: titleCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  isDense: true,
                  labelText: 'Title',
                  hintText: 'e.g Fullstack developer',
                ),
              ),
              Gap(16),
              FormBuilderTextField(
                name: 'bio',
                autofocus: true,
                style: Theme.of(context).textTheme.bodyMedium,

                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(
                    4,
                    errorText: 'Bio too short',
                  ),
                ]),
                inputFormatters: [LengthLimitingTextInputFormatter(250)],
                controller: bioCtrl,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  isDense: true,
                  labelText: 'Bio',
                  hintText: 'e.g I am a passionnate fullstack developer...',
                ),
              ),
              const Gap(16),
              FormBuilderTextField(
                name: 'tags',
                controller: tagsController,
                keyboardType: TextInputType.text,
                style: Theme.of(context).textTheme.bodyMedium,
                textInputAction: TextInputAction.done,
                onChanged: (value) {
                  final tagsList =
                      value!
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .where(isValidTag)
                          .toList();

                  if (tagsList.length <= maxTags) {
                    userSkills = tagsList;
                    _formKey.currentState?.fields['tags']?.validate();
                    _onChanged();
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Skills cannot be empty';
                  }

                  final tagsList =
                      value
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                  if (tagsList.length > maxTags) {
                    _onChanged();
                    return 'You can only add $maxTags skills';
                  }

                  if (tagsList.any((tag) => tag.length > 20)) {
                    return 'Each skill should be a max of 20 characters.';
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'AI, Docker, ML',
                  hintStyle: TextStyle(color: Colors.grey),
                  labelText: 'Skills',
                  isDense: true,
                  helperMaxLines: 2,
                  helperText:
                      'Separate skills with a comma (,). Max of 5 skills',
                  helperStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const Gap(8),
              if (tagsController.text.isEmpty)
                const SizedBox.shrink()
              else
                Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        children:
                            userSkills
                                .map(
                                  (e) => Chip(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.3),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity(
                                      horizontal: -3,
                                      vertical: -3,
                                    ),
                                    label: Text(e),
                                    onDeleted: () {
                                      setState(() {
                                        userSkills.remove(e);
                                        tagsController.text = userSkills.join(
                                          ', ',
                                        );
                                      });
                                    },
                                  ).pSymmetric(h: 2),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              const Gap(24),
              BlocConsumer<CompleteProfileCubit, CompleteProfileState>(
                listener: (context, state) {
                  if (state is CompleteProfileSuccess) {
                    context.showToast(msg: 'Successful');
                    context.pushReplacementNamed(AppRouter.bottomMenuScreen);
                  }
                  if (state is CompleteProfileError) {
                    context.showToast(msg: 'Something went wrong. Try again.');
                  }
                },
                builder:
                    (context, state) => switch (state) {
                      CompleteProfileLoading() =>
                        StandardButton(
                          text: 'Submit',
                          onPressed: null,
                        ).shimmer(),
                      _ => StandardButton(
                        text: 'Submit',
                        onPressed: () {
                          context.read<CompleteProfileCubit>().completeProfile(
                            username: usernameCtrl.text.trim(),
                            userType: userTypeCtrl.text,
                            bio: bioCtrl.text.trim(),
                            skills: userSkills,
                            title: titleCtrl.text,
                          );
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
