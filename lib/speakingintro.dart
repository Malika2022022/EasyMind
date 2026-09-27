import 'package:flutter/material.dart';
import 'package:testdrive/VideoplayPage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:flutter/services.dart';
class VideoItem {
  final String url;
  final String title;
  final String description;

  VideoItem({
    required this.url, 
    required this.title,
    required this.description,
  });
}
class SpeakingIntroPage extends StatefulWidget {
  const SpeakingIntroPage({super.key});

  @override
  State<SpeakingIntroPage> createState() => _SpeakingIntroPageState();

}
class _SpeakingIntroPageState extends State<SpeakingIntroPage>{
  final TextEditingController _urlController = TextEditingController();
  final List<VideoItem> _videos = [];
  void _handleSubmitted(String value) async {
    if (value.isEmpty) return;
    final yt = YoutubeExplode();
    try {
      var video = await yt.videos.get(value); 
      setState(() {
        _videos.add(VideoItem(
          url: value,
          title: video.title, 
          description: video.author,
        ));
      });
      _urlController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube link')),
     );
    } finally {
      yt.close(); 
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor:Color(0xFFFFFFF0),
      body:SafeArea(
        
          child:Column(
            children:[
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF373737)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Center(
                child: Text('Speaking',
                style:TextStyle(
                  fontFamily:'Inter',
                    fontWeight:FontWeight.w600,
                    fontSize:30,
                )),
                ),
              const SizedBox(height:7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24,vertical:10),
                child:SizedBox(
                  width:335,
                  height:28,
                  child:TextField(
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    controller:_urlController,
                    decoration:InputDecoration(
                      hintText:'youtube link',
                      hintStyle:TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12),
                      filled:true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      fillColor:const Color(0xFF373737),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Image.asset('lib/images/Symbol.png'),
                        ),
                      
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _handleSubmitted,
                  )
                )
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24, top: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Videos', style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.w600)),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _videos.length,
                  itemBuilder: (context, index) {
                    return _buildVideoCard(_videos[index]);
                  },
                ),
             ),
            ]
          )
        )
      );
  }
  Widget _buildVideoCard(VideoItem video){
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerPage(videoUrl: video.url),
          ),
        );
      },
      child:Center(
        child:Container(
          width:375,
          height:105,
          decoration: BoxDecoration(
            color: const Color(0xFFEEE8AA), 
            borderRadius: BorderRadius.circular(1), 
            border: const Border(
              bottom: BorderSide(color: Color(0xFF373737), width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 167,
                height: 77,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://img.youtube.com/vi/${YoutubePlayer.convertUrlToId(video.url)}/0.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF373737)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        video.description,
                        style: const TextStyle(fontSize: 11, color: Colors.black54),
                      ),
                    ],
                  ),
                )
              )
            ]
          ) 
        )
      )
    );
  }
}
