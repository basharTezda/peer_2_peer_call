import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class CallExample extends StatefulWidget {
  const CallExample({Key? key}) : super(key: key);

  @override
  State<CallExample> createState() => _CallExampleState();
}

class _CallExampleState extends State<CallExample> {
  final TextEditingController _controller = TextEditingController();
  final Peer peer = Peer(options: PeerOptions(debug: LogLevel.All));
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  bool inCall = false;
  String? peerId;

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize();
    _remoteRenderer.initialize();
loadDevices();
    peer.on("open").listen((id) {
      setState(() {
        peerId = peer.id;
      });
    });

    peer.on<MediaConnection>("call").listen((call) async {
      final mediaStream = await navigator.mediaDevices
          .getUserMedia({"video": true, "audio": true});

      call.answer(mediaStream);

      call.on("close").listen((event) {
        setState(() {
          inCall = false;
        });
      });

      call.on<MediaStream>("stream").listen((event) {
        _localRenderer.srcObject = mediaStream;
        _remoteRenderer.srcObject = event;

        setState(() {
          inCall = true;
        });
      });
    });
  }

  @override
  void dispose() {
    peer.dispose();
    _controller.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }
    Future<void> loadDevices() async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      //Ask for runtime permissions if necessary.
      var status = await Permission.bluetooth.request();
      if (status.isPermanentlyDenied) {
        print('BLEpermdisabled');
      }

      status = await Permission.bluetoothConnect.request();
      if (status.isPermanentlyDenied) {
        print('ConnectPermdisabled');
      }
    }
    final devices = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      _devices = devices;
    });
  }
  List<MediaDeviceInfo> _devices = [];

  List<MediaDeviceInfo> get audioInputs =>
      _devices.where((device) => device.kind == 'audioinput').toList();
  void connect() async {
    final mediaStream = await navigator.mediaDevices
        .getUserMedia({"video": true, "audio": true});

    final conn = peer.call(_controller.text, mediaStream);

    conn.on("close").listen((event) {
      setState(() {
        inCall = false;
      });
    });
 Future<void> loadDevices() async {
    if (WebRTC.platformIsAndroid || WebRTC.platformIsIOS) {
      //Ask for runtime permissions if necessary.
      var status = await Permission.bluetooth.request();
      if (status.isPermanentlyDenied) {
        print('BLEpermdisabled');
      }

      status = await Permission.bluetoothConnect.request();
      if (status.isPermanentlyDenied) {
        print('ConnectPermdisabled');
      }
    }
    final devices = await navigator.mediaDevices.enumerateDevices();
    setState(() {
      _devices = devices;
    });
  }

    conn.on<MediaStream>("stream").listen((event) {
      _remoteRenderer.srcObject = event;
      _localRenderer.srcObject = mediaStream;

      setState(() {
        inCall = true;
      });
    });

    // });
  }

  void send() {
    // conn.send('Hello!');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _renderState(),
              const Text(
                'Connection ID:',
              ),
              SelectableText(peerId ?? ""),
              TextField(
                controller: _controller,
              ),
              ElevatedButton(onPressed: connect, child: const Text("connect")),
              ElevatedButton(
                  onPressed: send, child: const Text("send message")),
              if (inCall)
                Expanded(
                  child: RTCVideoView(
                    _localRenderer,
                  ),
                ),
              if (inCall)
                Expanded(
                  child: RTCVideoView(
                    _remoteRenderer,
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _renderState() {
    Color bgColor = inCall ? Colors.green : Colors.grey;
    Color txtColor = Colors.white;
    String txt = inCall ? "Connected" : "Standby";
    return Container(
      decoration: BoxDecoration(color: bgColor),
      child: Text(
        txt,
        style:
            Theme.of(context).textTheme.titleLarge?.copyWith(color: txtColor),
      ),
    );
  }
}