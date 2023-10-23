// ignore_for_file: avoid_print, file_names

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:intl/intl.dart' show DateFormat;
// import 'package:path_provider/path_provider.dart';
import 'package:whisper_flutter/whisper_dart-0.0.11/lib/whisper_dart.dart';

class RecorderPage extends StatefulWidget {
  const RecorderPage({Key? key, required this.index}) : super(key: key);
  final int index;
  @override
  State<RecorderPage> createState() => _RecorderPageState(index: index);
}

class _RecorderPageState extends State<RecorderPage>
// with AutomaticKeepAliveClientMixin
{

  final int index;
  _RecorderPageState({required this.index});
  // FlutterSoundPlayer? myPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? myRecorder = FlutterSoundRecorder();
  StreamSubscription? _recorderSubscription;
  final recordingPlayer = AssetsAudioPlayer();
  String _recorderState = "準備好後請按下按鈕";
  String pathToAudio = "";
  bool _playAudio = false;
  bool _isRecording = false;

  String _timerText = '00:00:00';
  List<String> questions = [
    "請您跟我聊聊您的家鄉，\n您的家鄉在哪呢？您到目前為止在您的家鄉住的時間久嗎？有什麼回憶嗎？",
    "若在台灣有颱風預報時，通常會需要準備什麼？發生什麼事？",
    "請問您昨天晚餐在哪裡吃飯？吃什麼？請描述細節及內容。",
    "若您想要泡一杯茶或咖啡，您會怎麼做？請描述細節及內容。",
    "請您跟我聊聊您最近喜歡看的節目是什麼？ 從電視、Youtube或廣播",
    "一年中的四季，您最喜歡哪一個季節？為什麼？",
  ];
  // @override
  // bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initializer();
    print("第 $index 頁 initialized.\n");
  }

  void initializer() async {

    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.audio.request();
    await Permission.manageExternalStorage.request();
    pathToAudio = '/sdcard/Download/test1_question$index.wav';
    // _recordingSession = FlutterSoundRecorder();
    myRecorder = await FlutterSoundRecorder().openRecorder();
    await myRecorder!
        .setSubscriptionDuration(const Duration(milliseconds: 100));
    await initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
    stopRecording;

    if (_recorderSubscription != null) {
      _recorderSubscription!.cancel();
      _recorderSubscription = null;
    }
    if (myRecorder != null) {
      myRecorder!.closeRecorder();
      myRecorder = null;
    }
    print("第 $index 頁 disposed.\n");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("第 $index 頁 didChangeDependencies");
  }

  @override
  void didUpdateWidget(covariant RecorderPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    print("第 $index 頁 didUpdateWidget");
  }

  @override
  Widget build(BuildContext context) {
    print("第 $index 頁 build");
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20,),
          Container(
            // height: 50,
            child: Text(
              "問題 ${index+1}",
              style: TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(20),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 0.5),
              borderRadius: const BorderRadius.all(Radius.circular(6)),
            ),
            child: Text(
              questions[index],
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
          Text(
            _recorderState,
            style: const TextStyle(fontSize: 20, color: Colors.black38),
          ),
          const SizedBox(
            height: 20,
          ),
          Center(
            child: Text(
              _timerText,
              style: const TextStyle(
                  fontSize: 30, color: Color.fromARGB(255, 255, 184, 30)),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FloatingActionButton.large(
            heroTag: "btn $index",
            backgroundColor: Colors.red,
            onPressed: () {
              setState(() {
                _isRecording = !_isRecording;
              });
              if (_isRecording) {
                startRecording();
              } else {
                stopRecording();
              }
            },
            child: _isRecording
                ? const Icon(
                    Icons.stop,
                  )
                : const Icon(Icons.mic),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                elevation: 9.0, backgroundColor: Colors.red),
            onPressed: () {
              setState(() {
                _playAudio = !_playAudio;
              });
              if (_playAudio) {
                playFunc();
              } else {
                stopPlayFunc();
              }
            },
            icon: _playAudio
                ? const Icon(
                    Icons.stop,
                  )
                : const Icon(Icons.play_arrow),
            label: _playAudio
                ? const Text(
                    "Stop",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  )
                : const Text(
                    "播放錄音檔",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                elevation: 9.0, backgroundColor: Colors.red),
            onPressed: () async {
              Whisper whisper = Whisper(
                whisperLib: "libwhisper.so",
              );
              var res = await whisper.request(
                whisperRequest: WhisperRequest.fromWavFile(
                  audio: File(pathToAudio),
                  model: File('./ggml-base.bin'),
                  language: "zh"
                ),

              );
              print(res);
              
            },
            icon:  const Icon(Icons.play_arrow),
            label: const Text(
                    "Translate",
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
          ),
          
        ],
      ),
    );
  }

  ElevatedButton createElevatedButton(
      {required IconData icon,
      required Color iconColor,
      required void Function() onPressFunc}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(6.0),
        side: const BorderSide(
          color: Colors.red,
          width: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        elevation: 9.0,
      ),
      onPressed: onPressFunc,
      icon: Icon(
        icon,
        color: iconColor,
        size: 38.0,
      ),
      label: const Text(''),
    );
  }

  void getRecorderState() {
    if (myRecorder!.isStopped) {
      setState(() {
        _recorderState = "準備好後請按下按鈕";
      });
    } else if (myRecorder!.isRecording) {
      setState(() {
        _recorderState = "現在請說話";
      });
    } else if (myRecorder!.isPaused) {
      setState(() {
        _recorderState = "錄音已暫停";
      });
    } else {
      setState(() {
        _recorderState = "Unknown";
      });
    }
  }

  Future<void> startRecording() async {
    Directory directory = Directory(path.dirname(pathToAudio));
    if (!directory.existsSync()) {
      directory.createSync();
    }
    if (myRecorder != null) {
      // myRecorder!.openAudioSession();
      await myRecorder!.startRecorder(
        toFile: pathToAudio,
        codec: Codec.pcm16WAV,
        // sampleRate: 16000,
      );

      if (myRecorder!.onProgress != null) {
        // ignore: no_leading_underscores_for_local_identifiers
        _recorderSubscription = myRecorder!.onProgress!.listen((e) {
          var date = DateTime.fromMillisecondsSinceEpoch(
              e.duration.inMilliseconds,
              isUtc: true);
          var timeText = DateFormat('mm:ss:SS', 'en_GB').format(date);
          setState(() {
            _timerText = timeText.substring(0, 8);
          });
        }, onError: (err) {
          print(err);
        }, onDone: () {
          print('subscription done!!');
        }, cancelOnError: false);
      }
      getRecorderState();
    }
  }

  Future<void> stopRecording() async {
    if (myRecorder != null) {
      await _recorderSubscription!.cancel();
      await myRecorder!.stopRecorder();

      getRecorderState();
    }
  }

  Future<void> playFunc() async {
    recordingPlayer.open(
      Audio.file(pathToAudio),
      autoStart: true,
      showNotification: true,
    );
  }

  Future<void> stopPlayFunc() async {
    recordingPlayer.stop();
  }
}
