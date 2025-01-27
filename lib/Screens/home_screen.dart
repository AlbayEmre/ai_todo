import 'dart:convert';
import 'dart:developer';
import 'package:ai_todo/Model/Urun.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Urun> _urunlerBox;

  // Speech to text
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechAvailable = false;//Stateden alınabilir 
  bool _listening = false; //!State den alınabilir

  // Google Generative AI
  late final GenerativeModel _generativeModel;

  final GenerationConfig _generationConfig = GenerationConfig(
      responseMimeType: "application/json",
      responseSchema: Schema.array(
          items: Schema.object(properties: {
        "isim": Schema.string(),
        "miktar": Schema.number(),
        "miktarTuru": Schema.enumString(enumValues: ["kilo", "adet", "litre"])
      })));

  late final ChatSession _chatSession;

  @override
  void initState() {
    super.initState();
    _speech.initialize().then((value) => setState(() => _speechAvailable = true));

    _generativeModel = GenerativeModel(
      apiKey: "AIzaSyC2xQob63Ip1NEiHcrOqPowQmJngbCnuNY",
      model: "gemini-1.5-flash-latest",
      generationConfig: _generationConfig,
    );
    _startGeminiSession();

    _urunlerBox = Hive.box<Urun>('urunlerBox');
  }

  void _startListening() {
    setState(() => _listening = true);
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _sendMessage(result.recognizedWords);
        }
      },
    );
  }

  void _stopListening() {
    _speech.stop().then((value) => setState(() => _listening = false));
  }

  void _startGeminiSession() {
    _chatSession = _generativeModel.startChat(history: [
      Content("user", [
        TextPart(
            "Vereceğim cümlede geçen alışveriş listesini JSON formatında döndür: {isim, miktar, miktarTuru(kilo, adet veya litre)}") //Her seferinde hatırlaması için
      ]),
    ]);
  }

  void _sendMessage(String message) {
    final Content content = Content.text(message);
    _generativeModel.countTokens([content]).then(
      (CountTokensResponse value) {
        log("${value.totalTokens} token harcandı");
      },
    );

    _chatSession.sendMessage(content).then(
      (GenerateContentResponse value) {
        if (value.text case final String text) {
          final List urunler = jsonDecode(text);
          final List<Urun> urunList = urunler.map((e) => Urun.fromMap(e)).toList();
          for (var urun in urunList) {
            _urunlerBox.add(urun);
          }
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alışveriş Listesi'),
      ),
      body: Column(
        children: [
          Expanded(child: _urunlerListe()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: !_listening
                ? FloatingActionButton(
                    onPressed: _speechAvailable ? _startListening : null,
                    child: const Icon(Icons.keyboard_voice),
                  )
                : FloatingActionButton(
                    onPressed: _stopListening,
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.stop),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _urunlerListe() {
    return ValueListenableBuilder(
      valueListenable: _urunlerBox.listenable(),
      builder: (context, Box<Urun> box, _) {
        if (box.values.isEmpty) {
          return Center(child: Text('Liste boş'));
        } else {
          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final Urun? urun = box.getAt(index);
              return Dismissible(
                key: Key(urun!.key.toString()),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  urun.delete();
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  child: ListTile(
                    title: Text(urun.isim),
                    subtitle: Text("${urun.miktar} ${urun.miktarTuru}"),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
