import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/bloc/auth_bloc.dart';
import 'package:vibra_braille/ui/User/register.dart';
import 'package:vibra_braille/ui/user/verification.dart';

import '../../data/authData.dart';
import '../camera.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginState();

}
class _LoginState extends State<LoginPage> with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool emailError = false;
  bool phoneError = false;

  late TabController _tabController;
  final formKey = GlobalKey<FormState>(debugLabel: '_login');
  late SharedPreferences sp;

  @override
  void initState() {
    super.initState();
    getPreferences().whenComplete( () => {
      if (sp.containsKey("email") ) {
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Camera()), (route) => false)
      }
    });

    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
  }


  Future getPreferences() async{
    sp = await SharedPreferences.getInstance();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome!",
        textAlign: TextAlign.center,
        style: TextStyle(height: 2, fontSize: 45,)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.phone , semanticLabel: "Login with Phone Number"),
              text: "Phone",

            ),
            Tab(
              icon: Icon(Icons.email, semanticLabel: "Login with Email"),
              text: "Email",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: phoneLogin(),
          ),
          Center(
            child: emailLogin(),
          ),
        ],
      ),

    );
  }


  ElevatedButton loginButton(String method) {
    return ElevatedButton(
      onPressed: () {
        if (method == "phone") {
          _validatePhoneNumber();
          if (!phoneError) loginMethod("phone");
        } else if (method == "email") {
          _validateEmail();
          if (!emailError)  loginMethod("email");
        }
      },
      child: const Text("Login", semanticsLabel: "Login",),
    );
  }

  loginMethod(String method) {
    Map<String,String> loginMethod = <String, String>{};
    if (method == "phone") {
      loginMethod["phone_number"] = _phoneController.value.text;
    } else if (method == "email") {
      loginMethod["email"] = _emailController.value.text;
    }
    loginMethod["password"] = _passwordController.value.text;

    Login(loginMethod);
  }


  Row registration() {
    return Row( mainAxisAlignment: MainAxisAlignment.center,
        children: [ const Text("Don't have an account?",
          style: TextStyle(fontWeight: FontWeight.bold),),
          GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(),
                  ),
                );
              },
              child: const Text(" Register Now", semanticsLabel: "Register Now",
                style: TextStyle(fontWeight: FontWeight.bold,
                    color: Colors.blue),)
          )
        ]);
  }


  Column emailLogin() {
    return Column(
      children: [
        TextField(
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            filled: true,
            icon: const Icon(Icons.email),
            hintText: "Enter your email address",
            labelText: "Email",
            errorText: emailError ? 'Enter a valid email address' : null,
          ),
          keyboardType: TextInputType.emailAddress,

        ),
        password(),
        loginButton("email"),
        registration(),
      ],
    );
  }

  Column phoneLogin() {
    return Column(
      children: [
      SizedBox(
        width: 250.0,
        child: TextField(
        controller: _phoneController,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          filled: true,
          icon: const Icon(Icons.phone),
          hintText: "Enter your phone Number",
          labelText: "Phone Number",
          prefixText: '+1 ',
          errorText: phoneError ? "Enter a valid phone number " : null,
        ),

        keyboardType: TextInputType.phone,
        //onSaved: (value) {
          //person.phoneNumber = value;
        //},
        maxLength: 14,
        // TextInputFormatters are applied in sequence.
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          // Fit the validating format.
          UsNumberTextInputFormatter(),
        ],
      ),
      ),

       password(),
       loginButton("phone"),
       registration(),
    ]);
  }

  TextField password() {
    return TextField(
      decoration: InputDecoration(
        filled: true,
        labelText: "Enter password",
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          hoverColor: Colors.transparent,
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            semanticLabel: _obscurePassword
                ? "Password is showing"
                : "Password is hidden",
          ),
        ),
      ),
      maxLength: 8,
      obscureText: _obscurePassword,

      //onFieldSubmitted: (value) {
      //_handleSubmitted();
      //},
    );
  }


  _validatePhoneNumber () {
    final phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(_phoneController.value.text)) {
      setState(() => { phoneError = true });
    } else {
      if (phoneError) { setState(() => {phoneError = false});
      }
    }
  }
   _validateEmail() {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(_emailController.value.text)) {
      setState(() => {emailError = true});
    } else { if (emailError) {setState(() => {emailError = false });
      }
    }

  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }
}

// forgot password
/// Format incoming numeric text to fit the format of (###) ###-#### ##
class UsNumberTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final newTextLength = newValue.text.length;
    final newText = StringBuffer();
    var selectionIndex = newValue.selection.end;
    var usedSubstringIndex = 0;
    if (newTextLength >= 1) {
      newText.write('(');
      if (newValue.selection.end >= 1) selectionIndex++;
    }
    if (newTextLength >= 4) {
      newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}) ');
      if (newValue.selection.end >= 3) selectionIndex += 2;
    }
    if (newTextLength >= 7) {
      newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
      if (newValue.selection.end >= 6) selectionIndex++;
    }
    if (newTextLength >= 11) {
      newText.write('${newValue.text.substring(6, usedSubstringIndex = 10)} ');
      if (newValue.selection.end >= 10) selectionIndex++;
    }
    // Dump the rest.
    if (newTextLength >= usedSubstringIndex) {
      newText.write(newValue.text.substring(usedSubstringIndex));
    }
    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class Login {


  Login(Map<String, String> loginMethod) {
    _login(loginMethod);
  }

  _login(Map<String,String> loginMethod) {
    final bloc = AuthBloc();
    bloc.loginUser.add(loginMethod);
    StreamBuilder<Account?>(
        stream: bloc.loginStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // NOT VERIFIED
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) =>
                VerifyPage(email : snapshot.data!.email, code: snapshot.data!.emailCode,
                    password: loginMethod["password"]!)));
            return const Center(child: CircularProgressIndicator());
          } else {
            setPreferences(snapshot.data!);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Camera()), (route) => false);
            return const Center(child: CircularProgressIndicator());
          }
        });

  }

  setPreferences(Account account) async {
    //SHARED PREFERENCES
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp .setString("email" , account.email);
    sp .setString("username" , account.username);
    sp .setString("phone" , account.phone);
    sp .setString("refreshToken" , account.refreshToken);
    sp .setString("accessToken" , account.accessToken);
  }


}
