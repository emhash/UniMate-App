import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../home_screen.dart';
import '../auth/register_screen.dart';
import '../auth/final_registration_screen.dart';
import '../../services/api_services.dart'; // Ensure this import is present

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum LoginCase {
  validationError, // case 0
  approved, // case 1
  pendingApproval, // case 2
  completeRegistration, // case 3
  completeRegistrationApproved, // case 4
  registrationNeeded, // case 5
  unauthorizedRole, // case 6
  unknown, // case -1
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _obscureText = true;

  LoginCase getLoginCase(int apiCase) {
    switch (apiCase) {
      case 0:
        return LoginCase.validationError;
      case 1:
        return LoginCase.approved;
      case 2:
        return LoginCase.pendingApproval;
      case 3:
        return LoginCase.completeRegistration;
      case 4:
        return LoginCase.completeRegistrationApproved;
      case 5:
        return LoginCase.registrationNeeded;
      case 6:
        return LoginCase.unauthorizedRole;
      default:
        return LoginCase.unknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'UniMate',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      // Add more robust email validation if necessary
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Don't have an account? Register here",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Step 1: Perform Login
        final response = await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Debug: Print the login response
        print('Login Response: $response');

        final int apiCase = response['case'] ?? -1;
        final String message = response['message'] ?? 'An error occurred.';
        final LoginCase loginCase = getLoginCase(apiCase);

        switch (loginCase) {
          case LoginCase.approved:
            // Case 1: Account is approved → Navigate to HomeScreen
            final String token = response['token'];
            final String userEmail = response['user']['email'];
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userEmail: userEmail,
                  token: token,
                ),
              ),
            );
            break;

          case LoginCase.completeRegistration:
            // Case 3: Details not filled and not approved → Navigate to FinalRegistrationScreen
            final String token = response['token'];
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => FinalRegistrationScreen(token: token),
              ),
            );
            break;

          case LoginCase.pendingApproval:
          case LoginCase.completeRegistrationApproved:
            // Cases 2 and 4: Show an orange SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange,
              ),
            );
            break;

          case LoginCase.registrationNeeded:
          case LoginCase.unauthorizedRole:
            // Cases 5 and 6: Show a red SnackBar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
            break;

          case LoginCase.validationError:
            // Case 0: Validation errors
            final Map<String, dynamic> errors =
                response['message'] as Map<String, dynamic>;
            String errorMessage = errors.values
                .map((errorList) => (errorList as List<dynamic>).join(', '))
                .join('\n');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
            break;

          case LoginCase.unknown:
          default:
            // Case -1 and any unexpected cases
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.red,
              ),
            );
            break;
        }
      } catch (e) {
        // Handle exceptions during login → Show a red SnackBar with the exception message
        print('Error during login: $e'); // Debug: Print the error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        // Stop the loading indicator
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
