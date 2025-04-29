import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/auth/imports.dart';
import 'package:uniapp/presentation/profile/imports.dart';
import 'package:uniapp/presentation/widgets/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var passwordVisible = true;

  String persistentError = '';

  _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: TextButton(
        onPressed: () => context.pushNamed(AppRouter.signupScreen),
        child: Text(
          'Create account',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).primaryColor,
          ),
        ),
      ).pOnly(bottom: 8),
      body: BlocListener<ReadProfileCubit, ReadProfileState>(
        listener: (context, state) {
          if (state is ReadProfileLoading) {
            context.loaderOverlay.show();
          }
          if (state is ReadProfileError) {
            context.loaderOverlay.hide();
            context.showToast(msg: 'Something went wrong. Try again');
          }
          if (state is ReadProfileSuccess) {
            context.loaderOverlay.hide();
            if (state.response == null ||
                state.response!.username.isEmptyOrNull) {
              context.pushReplacementNamed(AppRouter.completeProfileScreen);
            } else {
              context.pushReplacementNamed(AppRouter.bottomMenuScreen);
            }
          }
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(32),
                SizedBox(height: 200, width: 200, child: Placeholder()),
                Gap(32),

                Center(
                  child: Text(
                    'CO-FOUNDER APP',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Gap(8),
                FormBuilderTextField(
                  name: 'email',
                  autofocus: true,
                  autofillHints: const <String>[AutofillHints.email],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                  inputFormatters: [LengthLimitingTextInputFormatter(50)],
                  controller: emailCtrl,

                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Email',
                  ),
                ),
                const Gap(16),
                FormBuilderTextField(
                  name: 'password',
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(
                      6,
                      errorText: 'Password too short',
                    ),
                  ]),
                  inputFormatters: [LengthLimitingTextInputFormatter(20)],
                  controller: passwordCtrl,
                  obscureText: passwordVisible,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Password',
                    suffixIcon: Icon(
                      passwordVisible
                          ? Symbols.visibility
                          : Symbols.visibility_off,
                    ).onTap(() {
                      passwordVisible = !passwordVisible;
                      _onChange();
                    }),
                  ),
                ),
                Gap(16),
                BlocConsumer<SignInCubit, SignInState>(
                  listener: (context, state) {
                    if (state is SignInLoading) {
                      persistentError = '';
                      _onChange();
                    }
                    if (state is SignInError) {
                      persistentError = state.error.message;
                      _onChange();
                    }
                    if (state is SignInSuccess) {
                      BlocProvider.of<ReadProfileCubit>(
                        context,
                      ).readCurrentUserProfile();
                    }
                  },
                  builder:
                      (context, state) => switch (state) {
                        SignInLoading() =>
                          StandardButton(
                            text: 'Sign in',
                            onPressed: null,
                          ).shimmer(),
                        _ => StandardButton(
                          text: 'Sign in',
                          onPressed: () {
                            context.hideKeyboard(context);
                            if (_formKey.currentState!.validate()) {
                              context.read<SignInCubit>().signin(
                                email: emailCtrl.text.trim(),
                                password: passwordCtrl.text,
                              );
                            }
                          },
                        ),
                      },
                ),
                persistentError.isEmpty
                    ? SizedBox.shrink()
                    : Text(
                      persistentError,
                      style: TextStyle(color: Colors.red),
                    ).pOnly(top: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
