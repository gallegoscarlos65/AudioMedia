import 'package:animate_do/animate_do.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:music_player/src/helpers/helpers.dart';
import 'package:music_player/src/models/audioplayer_model.dart';
import 'package:music_player/src/widgets/custom_appbar.dart';
import 'package:provider/provider.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[

          Background(),

          Column(
            children: <Widget>[
              
              CustomAppBar(),

              ImagenDiscoDuracion(),

              TituloPlay(),

              Expanded(
                child: Lyrics())

            ],
          ),
        ],
      )
    );
  }
}

class Background extends StatelessWidget {
  // const Background({
  //   Key? key,
  // }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: screenSize.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60)),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.center,
          colors: [
            Color(0xff33333E),
            Color(0xff201E28)
          ])
      ),
    );
  }
}

class Lyrics extends StatelessWidget {
  const Lyrics({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final lyrics = getLyrics();

    return Container(
      child: ListWheelScrollView(
        physics: BouncingScrollPhysics(),
        itemExtent: 42, 
        diameterRatio: 1.5,
        children: lyrics.map(
          (linea) => Text(linea, style: TextStyle(fontSize: 20, color: Colors.white.withOpacity(0.6)),),
          ).toList()
          )
    );
  }
}

class TituloPlay extends StatefulWidget {
  const TituloPlay({
    Key? key,
  }) : super(key: key);

  @override
  State<TituloPlay> createState() => _TituloPlayState();
}

class _TituloPlayState extends State<TituloPlay> with SingleTickerProviderStateMixin{

  bool isPlaying= false;
  bool firstTime = true;
  late AnimationController playAnimation;

  final assetsAudioPlayer = new AssetsAudioPlayer();

  @override
  void initState() {
    playAnimation = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    super.initState();
  }

  void open(){

    final audioPlayerModel = Provider.of<AudioPlayerModel>(context, listen: false);

    assetsAudioPlayer.open(
      Audio('assets/Breaking-Benjamin-Far-Away.mp3'),
      autoStart: true,
      showNotification: true
      );

      assetsAudioPlayer.currentPosition.listen((duration) { 
        audioPlayerModel.current = duration;
      });

      assetsAudioPlayer.current.listen((playingAudio) { 
        audioPlayerModel.songDuration = playingAudio?.audio.duration ?? Duration(seconds: 0);
      });


  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50),
      margin: EdgeInsets.only(top: 40),
      child: Row(
        children: [
          Column(
            children: [
              Text("Far Away", style: TextStyle(fontSize: 30, color: Colors.white.withOpacity(0.8)),),
              Text("-Breaking Benjamin", style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.8)),)
            ],
          ),

          Spacer(),

          FloatingActionButton(
            elevation: 0,
            highlightElevation: 0,
            onPressed: (){
              
              final audioPlayerModel = Provider.of<AudioPlayerModel>(context, listen: false);

              if(this.isPlaying){
                playAnimation.reverse();
                this.isPlaying = false;
                audioPlayerModel.controller.stop();
              }
              else {
                playAnimation.forward();
                this.isPlaying = true;
                audioPlayerModel.controller.repeat();
              }

              if(firstTime){
                this.open();
                firstTime = false;
              } else {
                assetsAudioPlayer.playOrPause();
              }

            },
            backgroundColor: Color(0xffF8CB51),
            child: AnimatedIcon(
              icon: AnimatedIcons.play_pause, 
              progress: playAnimation)
            )

        ],
      ),

    );
  }
}

class ImagenDiscoDuracion extends StatelessWidget {
  const ImagenDiscoDuracion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      margin: EdgeInsets.only(top: 70),
      child: Row(
        children: [
          //TODO: Disco
          ImagenDisco(),
          SizedBox(width: 20),
          BarraProgeso(),
          SizedBox(width: 20),
          //TODO: Barr progreso
        ],
      ),
    );
  }
}

class BarraProgeso extends StatelessWidget {
  const BarraProgeso({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final estilo = TextStyle(color: Colors.white.withOpacity(0.4));
    
  final audioPlayerModel = Provider.of<AudioPlayerModel>(context);
  final porcentaje = audioPlayerModel.porcentaje;



    return Container(

      child: Column(
        children: [
          Text('${audioPlayerModel.songTotalDuration}', style: estilo,),
          SizedBox(height: 10,),
          Stack(
            children: [
              Container(
                width: 3,
                height: 230 * porcentaje,
                color: Colors.white.withOpacity(0.1),
              ),

              Positioned(
                bottom: 0,
                child: Container(
                  width: 3,
                  height: 100,
                  color: Colors.white.withOpacity(0.8),
                ),
              )
            ],
          ),
          SizedBox(height: 10,),
      
          Text('${audioPlayerModel.currentSecond}',style: estilo,),
        ],
      ),

    );
  }
}

class ImagenDisco extends StatelessWidget {
  const ImagenDisco({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    final audioPlayerModel = Provider.of<AudioPlayerModel>(context);
    
    return Container(
      padding: EdgeInsets.all(20),
      width: 250,
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(200),
        child: Stack(
          alignment: Alignment.center,
          children: [

            SpinPerfect(
              duration: Duration(seconds: 10),
              infinite: true,
              manualTrigger: true,
              controller: (animationController) => audioPlayerModel.controller = animationController,
              child: Image(image: AssetImage('assets/aurora.jpg'))),

            Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(100)
              ),
            ),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Color(0xff1C1C25),
                borderRadius: BorderRadius.circular(100)
              ),
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(200),
        gradient: LinearGradient(colors: [
          Color(0xff484750),
          Color(0xff1E1C24)
        ],
        begin: Alignment.topLeft
        )
      ),
    );
  }
}