import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibra_braille/ui/register.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginState();

}
class _LoginState extends State<LoginPage> with TickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  StreamController<ErrorAnimationType>? _errorController;
  String _codeButtonText = "Send Code";
  late TabController _tabController;
  final formKey = GlobalKey<FormState>(debugLabel: '_login');
  String _codeFillText = "";

  @override
  void initState() {
    super.initState();
    _errorController = StreamController<ErrorAnimationType>();
    _tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    );
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


  ElevatedButton login(String method) {
    return ElevatedButton(
      onPressed: () {
        if (method == "phone") {
          // send request by phone
        } else if (method == "email") {
          // send request by email/password
        }
      },
      child: const Text("Login", semanticsLabel: "Login",),
    );
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
            errorText: _validateEmail,
          ),

          keyboardType: TextInputType.emailAddress,
          //onSaved: (value) {
            //person.email = value;
          //},
        ),
        TextField(
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
        ),
        login("email"),
        registration(),
      ],
    );
  }

  Column phoneLogin() {
    return Column(
      children: [
      Row( children: [
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
          errorText: _validatePhoneNumber,
        ),

        keyboardType: TextInputType.phone,
        //onSaved: (value) {
          //person.phoneNumber = value;
        //},
        maxLength: 14,
        onChanged: (value) { setState(() {
        _codeButtonText = "Send Code";
        _codeFillText = "";
        }); },
        // TextInputFormatters are applied in sequence.
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          // Fit the validating format.
          UsNumberTextInputFormatter(),
        ],
      ),
      ),
        ElevatedButton(onPressed: () {
          // try autofill
          const snackBar = SnackBar(
                 content: Text('Code resent!'),
               );

          if (_codeButtonText == "Resend Code") {
            ScaffoldMessenger.of(context).showSnackBar(snackBar
                );
          }
            setState((){
            _codeFillText = "Code Sent! Enter sent code";
            if (_phoneController.value.text.length == 14) {
              _codeButtonText = "Resend Code";
            } //ELSEEE VALIDATOR !!
          });
        },
            child: Text(_codeButtonText, semanticsLabel: "Send S M S code",))
      ]),
        //code text field
        // send code -> resend code
        codeField(),  // -> if auto fill auto login else manually log in
       login("phone"),
       registration(),
    ]);
  }
  Form codeField() {
    return Form(
        key: formKey,
        child: Padding(
        padding: const EdgeInsets.symmetric(
        vertical: 8.0, horizontal: 40),
            child: PinCodeTextField(
      appContext: context,
      pastedTextStyle: TextStyle(
      color: Colors.green.shade600,
      fontWeight: FontWeight.bold,
      ),
      length: 5,
      //animationType: AnimationType.fade,
      validator: (v) {
        if (v!.length < 5) {
        return _codeFillText;
        } else {
        return null;
        }
      },
      pinTheme: PinTheme(
      shape: PinCodeFieldShape.box,
      borderRadius: BorderRadius.circular(5),
      fieldHeight: 50,
      fieldWidth: 40,
      activeFillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      animationDuration: const Duration(milliseconds: 300),
      //enableActiveFill: true,
      errorAnimationController: _errorController,
      controller: _codeController,
      keyboardType: TextInputType.number,
      boxShadows: const [
      BoxShadow(
      offset: Offset(0, 1),
      color: Colors.black12,
      blurRadius: 10,
      )
    ],
    onCompleted: (v) {
      debugPrint("Completed");
    },
    /* onTap: () {
       print("Pressed");
     },*/
    onChanged: (value) {
      debugPrint(value);
      setState(() {
      //  currentText = value;
      });
    },
    beforeTextPaste: (text) {
      debugPrint("Allowing to paste $text");
      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
      //but you can show anything you want here, like your pop up saying wrong paste format or etc
      return true;
    },
    )),
    );
  }

  /*
  errorController!.add(ErrorAnimationType
                            .shake);
   */

  String? get _validatePhoneNumber{
    final phoneExp = RegExp(r'^\(\d\d\d\) \d\d\d\-\d\d\d\d$');
    if (!phoneExp.hasMatch(_phoneController.value.text)) {
      return "Enter a valid phone number ";
    }
    return null;
  }

  String? get _validateEmail {
    String pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
        r"{0,253}[a-zA-Z0-9])?)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(_emailController.value.text)) {
      return 'Enter a valid email address';
    }
    return null;

  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _errorController!.close();
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

