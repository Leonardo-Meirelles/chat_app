import 'dart:io';

import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../services/firebase_firestore_service.dart';
import '../services/firebase_storage_service.dart';
import '../widgets/user_image_picker.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _formKey = GlobalKey<FormState>();

  bool _isLogin = true;
  String _emailAddress = '';
  String _password = '';
  String _userName = '';
  File? _image;

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();

    FocusScope.of(context).unfocus();

    if (!isValid || !_isLogin && _image == null) return;

    _formKey.currentState!.save();

    if (_isLogin) {
      logIn();
    } else {
      signIn();
    }
  }

  void logIn() async {
    final (userCredential, userError) = await FirebaseAuthService.loginUser(
        email: _emailAddress, password: _password);

    if (userCredential == null && userError != null) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userError.message ?? 'Authentication failed.'),
        ),
      );
    } else {
      return;
    }
  }

  void signIn() async {
    final (userCredential, userError) = await FirebaseAuthService.createUser(
        email: _emailAddress, password: _password);

    if (userCredential == null && userError != null) {
      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userError.message ?? 'Authentication failed.'),
        ),
      );
    } else {
      final imageUrl = await FirebaseStorageService.storeImage(
        userCredentials: userCredential!,
        file: _image!,
      );

      FirebaseFirestoreService.storeUserData(
        userName: _userName,
        userCredentials: userCredential,
        imageUrl: imageUrl,
      );
      return;
    }
  }

  void onPickImage(File pickedImage) {
    _image = pickedImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Switch(
                              value: _isLogin,
                              onChanged: (value) {
                                setState(() {
                                  _isLogin = value;
                                });
                              },
                            ),
                            const Text('Already have an account'),
                          ],
                        ),
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: onPickImage,
                          ),
                        if (!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            keyboardType: TextInputType.name,
                            autocorrect: false,
                            enableSuggestions: false,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) {
                              if (value == null || value.trim().length < 3) {
                                return 'Please enter a valid 4 characters name';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _userName = value!;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _emailAddress = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Please enter a password with a least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _password = value!;
                          },
                        ),
                        const SizedBox(height: 15),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              width: 1,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onPressed: () => _submit(),
                          child: Text(_isLogin ? 'Log In' : 'Sign Up'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
