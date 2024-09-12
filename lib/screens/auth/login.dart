import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

// services
import 'package:flut_mart/services/auth.service.dart';
import 'package:flut_mart/services/token.service.dart';

// helpers
import 'package:flut_mart/utils/helper/responsive.dart';

// widgets
import 'package:flut_mart/widgets/input.dart';
import 'package:flut_mart/widgets/snackbar.dart';
import 'package:flut_mart/widgets/submit_button.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();

  // method to login user
  void _loginUser() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        KSnackBar.show(
          context: context,
          label: 'Please fill all fields',
          type: 'error',
        );
        return;
      }

      final response = await _authApiService.loginUser(email, password);
      final token = response['access_token'];
      await TokenService.saveToken(token);

      if (mounted) {
        KSnackBar.show(
          context: context,
          label: 'Login Successful',
          type: 'success',
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/app',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        KSnackBar.show(
          context: context,
          label: 'Invalid Credentials',
          type: 'error',
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Responsive.isMobile(context)
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/animations/auth.json',
                      height: 350,
                    ),
                  ),
                  _loginSection(
                    context,
                    _emailController,
                    _passwordController,
                    _loginUser,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Lottie.asset(
                      'assets/animations/auth.json',
                      height: 500,
                    ),
                  ),
                  SizedBox(
                    width: 300,
                    child: _loginSection(
                      context,
                      _emailController,
                      _passwordController,
                      _loginUser,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

Widget _loginSection(
    BuildContext context, emailController, passwordController, loginUser) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Login',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        'Enter your credentials to login.',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
      ),
      const SizedBox(height: 30),
      KInputField(
        labelText: 'Email',
        icon: Icons.email,
        controller: emailController,
      ),
      const SizedBox(height: 8),
      KInputField(
        labelText: 'Password',
        icon: Icons.lock,
        controller: passwordController,
        obscureText: true,
      ),
      const SizedBox(height: 30),
      Row(
        children: [
          Expanded(
            child: SubmitButton(
              onSubmit: loginUser,
              text: 'Submit',
            ),
          ),
        ],
      ),
      const SizedBox(height: 30),
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Don\'t have an account? ',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/signup');
              },
              child: Text(
                'SignUp',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
