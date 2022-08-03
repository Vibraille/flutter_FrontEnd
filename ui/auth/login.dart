import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibra_braille/bloc/auth_bloc.dart';
import 'package:vibra_braille/ui/auth/register.dart';
import 'package:vibra_braille/ui/auth/verify.dart';

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
  String inputPhone = "";
  String inputEmail = "";
  String inputPass = "";

  late TabController _tabController;
  final formKey = GlobalKey<FormState>(debugLabel: '_login');
  late SharedPreferences sp;

  @override
  void initState() {
    super.initState();
    late DateTime lastLogin;
    late int difference;
    getPreferences().whenComplete(() => {
      if (sp.containsKey("tokenExpiration") ) {
        lastLogin = DateTime.fromMillisecondsSinceEpoch(sp.getInt("tokenExpiration")!),
        difference = DateTime.now().difference(lastLogin).inDays,
        if (difference < 6 ) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => CameraPage(sp: sp)), (route) => false)
        } else if (difference < 14) {
          refreshToken(sp),
        }
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 75,
        title: TabBar(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(Icons.email, semanticLabel: "Login with Email", size: 35,),
              text: "Email",
            ),
            Tab(
              icon: Icon(Icons.phone , semanticLabel: "Login with Phone Number", size: 35),
              text: "Phone",
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Center(
            child: emailLogin(),
          ),
          Center(
            child: phoneLogin(),
          ),
        ],
      ),

    );
  }


  refreshToken(SharedPreferences sp) {
    final bloc = AuthBloc();
    bloc.token.add(sp.getString("refreshToken")!);
    WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
      context: context,
      builder: (BuildContext context) {
        return StreamBuilder<List<String>?>(
            stream: bloc.tokenStream,
            builder: (context, snapshot) {
              if (snapshot.data != null && snapshot.data!.length == 2) {
                log(sp.getString("accessToken")!);
                sp.setString("refreshToken", snapshot.data![0]);
                sp.setString("accessToken", snapshot.data![1]);
                log(sp.getString("accessToken")!);
              }
              return const Center(child: CircularProgressIndicator());
            });
      },
    );});
    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.pop(context);
    // });

  }


  SizedBox loginButton(int method) {
    final button =  (method == 0) ?
    ElevatedButton(
      onPressed: () {
        _handleSubmitted(0);
      },
      child: const Text("Login", semanticsLabel: "Login",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
    ) :
    ElevatedButton(
      onPressed: () {
        _handleSubmitted(1);
      },
      child: const Text("Login", semanticsLabel: "Login",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
    );

    return SizedBox(
      width: 175,
      height: 45,
      child: button,);
  }

  _handleSubmitted(int method) {
    if (method == 1) {
      _validatePhoneNumber();
      if (!phoneError) loginMethod(1);
    } else {
      _validateEmail();
      if (!emailError)  loginMethod(0);
    }

  }

  loginMethod(int method) {
    Map<String,String> loginMethod = <String, String>{};
    if (method == 1) {
      loginMethod["phone_number"] = inputPhone;
    } else if (method == 0) {
      loginMethod["email"] = inputEmail;
    }
    loginMethod["password"] = inputPass;
    Login(loginMethod, context);
  }


  Row registration() {
    return Row( mainAxisAlignment: MainAxisAlignment.center,
        children: [ const Text("Don't have an account?",semanticsLabel: "Don't have an account?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
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
                    color: Colors.blue, fontSize: 18),)
          )
        ]);
  }

  Container logo() {
    return Container(
      height: 230.0,
      padding: const EdgeInsets.only(top: 50),
      child: Center(
        child: Image.asset('assets/logo.png', height: 300,),
      ),);
  }

  Column emailLogin() {
    return Column(
      children: [  const Padding(padding: EdgeInsets.only(top: 35)), logo(),
        const Padding(padding: EdgeInsets.only(top: 50, bottom: 20)),
        SizedBox(
          width: MediaQuery.of(context).size.width * .8,
          child: Column(
            children: [TextField(
              onChanged: (value) => {
                inputEmail = value
              },
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(

                filled: true,
               // icon: const Icon(Icons.email),
                hintText: "Enter your email address",
                labelText: "Email",
                errorText: emailError ? 'Enter a valid email address' : null,
              ),
              keyboardType: TextInputType.emailAddress,

            ),
              const Padding(padding: EdgeInsets.only(top: 30, )),
              password(), const Padding(padding: EdgeInsets.only(bottom: 5))],
          ),
        ),
        loginButton(0),
        const Padding(padding: EdgeInsets.only(bottom: 10)),
        registration(),
      ],
    );
  }

  Column phoneLogin() {
    return Column(
        children: [  const Padding(padding: EdgeInsets.only(top: 35)),
          logo(), const Padding(padding: EdgeInsets.only(top: 52, bottom: 18)),
          SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Column( children: [
              // width: 250.0,
              //child:
            TextField(
                onChanged: (value) => {
                  inputPhone = value
                } ,
                controller: _phoneController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  filled: true,
                  // icon: const Icon(Icons.phone),
                  hintText: "Enter your phone Number",
                  labelText: "Phone Number",
                  prefixText: '+1 ',
                  errorText: phoneError ? "Enter a valid phone number " : null,
                ),

                keyboardType: TextInputType.phone,
                maxLength: 14,
                // TextInputFormatters are applied in sequence.
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  // Fit the validating format.
                  UsNumberTextInputFormatter(),
                ],
              ),

          const Padding(padding: EdgeInsets.only(top: 10, )),
          password(),],

          ),), const Padding(padding: EdgeInsets.only(bottom: 10)),
          loginButton(1),
          const Padding(padding: EdgeInsets.only(bottom: 10)),
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
      onChanged: (value) {

        inputPass = value;
      },
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
    if (!regex.hasMatch(inputEmail)) {
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
  late BuildContext context;
  late Map<String, String> creds;

  Login(Map<String, String> loginMethod, this.context) {
    creds = loginMethod;
    _login(loginMethod);
  }

  _login(Map<String,String> loginMethod) {
    log(loginMethod.toString());
    final bloc = AuthBloc();
    bloc.loginUser.add(loginMethod);
    WidgetsBinding.instance.addPostFrameCallback((_){ showDialog(
      context: context,
      builder: (BuildContext context) {
      return StreamBuilder<Account?>(
          stream: bloc.loginStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.data != null) {
              log(snapshot.data!.statusCode.toString());
              if (snapshot.data!.statusCode == 401) {
                log("Verify!");
                return  const AlertDialog( content:
                Text('Please verify your account', semanticsLabel: "Please verify your account",
                    style: TextStyle(fontSize: 30)));
              } else if (snapshot.data!.statusCode == 200 ){
                setPreferences(snapshot.data!);
                  return const Center(child: CircularProgressIndicator());
              }
              String response = snapshot.data!.errorMessage;
              return  AlertDialog( content:
              Text(response, semanticsLabel: response,
                  style: const TextStyle(fontSize: 30)));
            } else {
              return  const AlertDialog( content:
              Text('Failed to Login, check the email/password is correct', semanticsLabel: "Failed to Login",
                  style: TextStyle(fontSize: 30)));
            }
          });
      },
    );});
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context);
    });
  action();
  }


  
  action() {
    Future.delayed(const Duration(seconds: 2), () {
    });
    SharedPreferences.getInstance().then((sp) => {
    //   log(sp.containsKey("email").toString()),
      if (sp.containsKey("email")) {
        Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
        builder: (context) => CameraPage(sp: sp)), (
        route) => false),
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) =>
      VerifyPage(email: creds["email"]!,
      password: creds["password"]!))),
    }}
    );


  }

  setPreferences(Account account) async {
    SharedPreferences.getInstance().then((sp) => {
          sp.setString("email", account.email),
          sp.setString("username", account.username),
          sp.setString("phone", account.phone),
          sp.setString("refreshToken", account.refreshToken),
          sp.setString("accessToken", account.accessToken),
          sp.setInt("tokenExpiration",  DateTime.now().millisecondsSinceEpoch),

    });
  }


}
