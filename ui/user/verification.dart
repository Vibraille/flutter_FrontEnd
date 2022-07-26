import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:vibra_braille/bloc/auth_bloc.dart/';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:vibra_braille/ui/user/login.dart';

import 'login.dart';

class VerifyPage extends StatefulWidget {
  final String email;
  final String code;
  final String password;
  const VerifyPage({super.key, required this.email, required this.code,  required this.password});

  @override
  State<VerifyPage> createState() => _VerifyState();
}

class _VerifyState extends State<VerifyPage> {
  late String _code;
  final codeController = TextEditingController();
  String _codeText = "Enter verification code";

  @override
  void initState() {
    super.initState();
    _code = widget.code;
    sendEmail(_code);
  }

//DELETE AND EDIT NOTE
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text("Please verify your email", semanticsLabel: "Please verify your email",
          style: TextStyle(fontSize: 40),),
          Row(
          children: [
          const Text("Verification code sent to ", semanticsLabel: "Verification sent to your email",
            style: TextStyle(fontSize: 35),),
            Text(widget.email,
              style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold),),
          ]),
         pin(), Text(_codeText, semanticsLabel: _codeText,),
          ElevatedButton(
            onPressed: _handleSubmitted,
            child: const Text("Submit", semanticsLabel: "Submit",),
          ),
          ElevatedButton(onPressed: () {
            resendCode();
          }, child: const Text("Send new verification code",
            semanticsLabel: "Send new verification code to email",)),
        ],
      )
    );

  }

  sendEmail(String code) async {
     final Email email = Email(
       subject: 'VibraBraille',
       body: 'Welcome to Vibra Braille! \nVerification code: $code',
       recipients: [widget.email],
//   cc: ['cc@example.com'],
//   bcc: ['bcc@example.com'],
//   attachmentPaths: ['/path/to/attachment.zip'],
//   isHTML: false,
 );
//
     await FlutterEmailSender.send(email);
     showInSnackBar("Verification code sent!");
  }

  void showInSnackBar(String value) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(value, semanticsLabel: value),
    ));
  }

  @override
    void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Pinput pin() {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: const Color.fromRGBO(234, 239, 243, 1)),
        borderRadius: BorderRadius.circular(20),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: const Color.fromRGBO(114, 178, 238, 1)),
      borderRadius: BorderRadius.circular(8),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
      hapticFeedbackType: HapticFeedbackType.vibrate,
      length: 6,
      controller: codeController,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      //errorText: "Incorrect pin, please try again ",
      onSubmitted: (value) => {
          _handleSubmitted()
      },
      onChanged: (value) => {
      setState(() => {
      _codeText = "Enter verification code"
      })
      },
      // validator: (s) {
      //   return s == _code ? null : 'Pin is incorrect';
      // },
      //pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
    );
  }




  resendCode() {
    final bloc = AuthBloc();
    bloc.codeRequest.add(widget.email);
    StreamBuilder<String?>(
        stream: bloc.requestStream,
        builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        showInSnackBar("Failed to request a new code, try again");
        return const Center(child: CircularProgressIndicator());
      } else {
        setState((){
          _code = snapshot.data!;
          _codeText = "Enter verification code";
        });
        showInSnackBar('Code resent!');
        return const Center(child: CircularProgressIndicator());
      }
    });
    }

  verified(String code) {
    final bloc = AuthBloc();
    bloc.verifyUser.add([widget.email,code]);
    StreamBuilder<String?>(
        stream: bloc.verifyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            showInSnackBar("Failed to verify your email. Please try again");
            return const Center(child: CircularProgressIndicator());
          } else {
            showInSnackBar(snapshot.data!);
            Login({"email": widget.email, "password": widget.password});
            return const Center(child: CircularProgressIndicator());
          }
        });
  }

  void _handleSubmitted() {
    if (codeController.value.text != _code) {
      setState(() => {
      _codeText = "Entered code does not match sent verification code"
      });
      
    } else {
      verified(_code);

    }
  }

}


