import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_uikit/agora_uikit.dart';
import 'package:flutter/material.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final appID = "99d5207b7dd04a6a8e06c20ee89cb3b1";
  final channelName = "cirious";
  final token =
      "007eJxTYAiZI3REo33xgp1bf93uzo5ZeH1vm+/02TxpQjyL61I+LfmhwGBpmWJqZGCeZJ6SYmCSaJZokWpglmxkkJpqYZmcZJxkOOtZalpDICND69tXjIwMEAjiszMkZxZl5pcWMzAAAFmxI68=";
  Future<void> initAgora() async {
    await [Permission.camera, Permission.microphone].request();
    final _engine = await createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(
      appId: appID,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await _engine.joinChannel(
      token: token,
      channelId: channelName,
      options: const ChannelMediaOptions(
          // Set the user role as host
          // To set the user role to audience, change clientRoleBroadcaster to clientRoleAudience
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
      uid: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
