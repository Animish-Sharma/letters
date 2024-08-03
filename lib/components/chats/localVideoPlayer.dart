import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class LocalVideoPlayer extends StatefulWidget {
  LocalVideoPlayer({super.key, required this.videoUrl});
  String videoUrl;

  @override
  State<LocalVideoPlayer> createState() => _LocalVideoPlayerState();
}

class _LocalVideoPlayerState extends State<LocalVideoPlayer> {
  late VideoPlayerController _vidController;
  ChewieController? _chewieController;
  int? bufferDelay;

  @override
  void initState() {
    initializePlayer();
    super.initState();
  }

  @override
  void dispose() {
    _vidController.dispose();
    super.dispose();
  }

  Future<void> initializePlayer() async {
    _vidController =
        VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await Future.wait([_vidController.initialize()]);
    _chewieController = ChewieController(
      videoPlayerController: _vidController,
      autoPlay: false,
      looping: true,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff000000).withOpacity(0.75),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Video Player",
          style: GoogleFonts.poppins(color: Colors.white, fontSize: width / 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height / 1.125,
          child: Column(
            children: <Widget>[
              Expanded(
                child: Center(
                  child: _chewieController != null &&
                          _chewieController!
                              .videoPlayerController.value.isInitialized
                      ? Chewie(
                          controller: _chewieController!,
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 20),
                            Text('Loading'),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
