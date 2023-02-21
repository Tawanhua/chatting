import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Chatting',
                  style: GoogleFonts.josefinSans(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 250,
                  height: 250,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                  )),
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Email',
                  ),
                  onChanged: (value) => setState(
                    () {
                      email = value;
                    },
                  ),
                  validator: (val) {
                    return RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                            .hasMatch(val!)
                        ? null
                        : "Please enter a valid email";
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Password',
                  ),
                  onChanged: (value) => setState(
                    () {
                      password = value;
                    },
                  ),
                  validator: (value) {
                    if (value!.length < 6) {
                      return 'Password must be at least 6 characters';
                    } else {
                      return null;
                    }
                  },
                ),
                ElevatedButton(
                  onPressed: login(),
                  child: const Text('Test'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  login() {
    if (formKey.currentState!.validate()) {}
  }
}


// Seperate textformfield