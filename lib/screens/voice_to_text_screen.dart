// ignore_for_file: avoid_print

import 'package:demo_task_syscraft/config/theme/app_text_style.dart';
import 'package:demo_task_syscraft/constants/app_const_text.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceToTextScreen extends StatefulWidget {
  const VoiceToTextScreen({super.key});

  @override
  VoiceToTextScreenState createState() => VoiceToTextScreenState();
}

class VoiceToTextScreenState extends State<VoiceToTextScreen> {
  late stt.SpeechToText speech;
  bool isListening = false;
  String text = '';

  @override
  void initState() {
    super.initState();
    speech = stt.SpeechToText();
  }

  void _listen() async {
    if (!isListening) {
      bool available = await speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );
      if (available) {
        setState(() => isListening = true);
        speech.listen(
          onResult: (result) => setState(() {
            text = result.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => isListening = false);
      speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
        title: Text(
          AppConstString.voiceToTxt,
          style: AppTextStyle.blueColor14W500,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: text),
              decoration: const InputDecoration(
                labelText: AppConstString.transcribedText,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  text = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _listen,
              child: Text(
                isListening
                    ? AppConstString.stopListening
                    : AppConstString.startDictation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
