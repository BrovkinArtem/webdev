import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:tiatia/pages/Home2.dart';
import 'package:tiatia/utils/colors.dart';
import 'package:tiatia/utils/constants.dart';
import 'package:tiatia/pages/Authorization/SignIn.dart';
import 'package:tiatia/functions/authFunctions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../utils/constants.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String fullname = '';
  bool login = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text('Регистрация'),
        ),
        body: Form(
          key: _formKey,
          child: Center(
              child: Container(
                  width: 400,
                  alignment: Alignment.center,
                  transformAlignment: Alignment.center,
                  padding: EdgeInsets.all(14),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ======== Full Name ========
                        login
                            ? Container()
                            : TextFormField(
                                key: ValueKey('fullname'),
                                decoration: InputDecoration(
                                  hintText: 'Введите полное имя',
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Пожалуйста введите полное имя';
                                  } else {
                                    return null;
                                  }
                                },
                                onSaved: (value) {
                                  setState(() {
                                    fullname = value!;
                                  });
                                },
                              ),

                        // ======== Email ========
                        TextFormField(
                          key: ValueKey('email'),
                          decoration: InputDecoration(
                            hintText: 'Введите email',
                          ),
                          validator: (value) {
                            if (value!.isEmpty || !value.contains('@')) {
                              return 'Пожалуйста введите email правильно';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            setState(() {
                              email = value!;
                            });
                          },
                        ),
                        // ======== Password ========
                        TextFormField(
                          key: ValueKey('password'),
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Введите пароль',
                          ),
                          validator: (value) {
                            if (value!.length < 6) {
                              return 'Пожалуйста введите пароль не менее 6 символов';
                            } else {
                              return null;
                            }
                          },
                          onSaved: (value) {
                            setState(() {
                              password = value!;
                            });
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          height: 55,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                try {
                                  if (login) {
                                    // Вход пользователя
                                    await FirebaseAuth.instance
                                        .signInWithEmailAndPassword(
                                      email: email,
                                      password: password,
                                    );

                                    // Проверка существования аккаунта в Firebase
                                    if (FirebaseAuth.instance.currentUser ==
                                        null) {
                                      // Аккаунт не существует
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Ошибка'),
                                          content:
                                              Text('Аккаунт не существует'),
                                          actions: [
                                            TextButton(
                                              child: Text('ОК'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }
                                  } else {
                                    // Регистрация пользователя
                                    await FirebaseAuth.instance
                                        .createUserWithEmailAndPassword(
                                      email: email,
                                      password: password,
                                    );
                                  }

                                  // Успешная авторизация или регистрация
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home2()),
                                  );
                                } catch (e) {
                                  // Обработка ошибок авторизации или регистрации
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Ошибка'),
                                      content: Text(e.toString()),
                                      actions: [
                                        TextButton(
                                          child: Text('ОК'),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(login
                                ? 'Авторизоваться'
                                : 'Зарегистрироваться'),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              login = !login;
                            });
                          },
                          child: Text(login
                              ? "Не имеете аккаунта? Зарегистрируйтесь"
                              : "Уже имеете аккаунт? Авторизируйтесь"),
                        ),
                      ]))),
        ));
  }
}
