import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uniapp/app/imports.dart';
import 'package:uniapp/presentation/auth/imports.dart';
import 'package:uniapp/presentation/widgets/imports.dart';
import 'package:velocity_x/velocity_x.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  var passwordVisible = true;

  String persistentError = '';

  _onChange() => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        passwordVisible = !passwordVisible;
                        _onChange();
                      },
                      icon: Icon(
                        passwordVisible
                            ? Symbols.visibility
                            : Symbols.visibility_off,
                      ),
                    ),
                  ),
                ),
                Gap(16),
                BlocConsumer<SignUpCubit, SignUpState>(
                  listener: (context, state) {
                    if (state is SignUpLoading) {
                      persistentError = '';
                      _onChange();
                    }
                    if (state is SignUpError) {
                      persistentError = state.error.message;
                      _onChange();
                    }
                    if (state is SignUpSuccess) {
                      context.pushReplacementNamed(
                        AppRouter.completeProfileScreen,
                      );
                    }
                  },
                  builder:
                      (context, state) => switch (state) {
                        SignUpLoading() =>
                          StandardButton(
                            text: 'Sign up',
                            onPressed: null,
                          ).shimmer(),
                        _ => StandardButton(
                          text: 'Sign up',
                          onPressed: () {
                            context.hideKeyboard(context);
                            if (_formKey.currentState!.validate()) {
                              context.read<SignUpCubit>().signup(
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
