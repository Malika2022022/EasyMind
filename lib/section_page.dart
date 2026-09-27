import 'package:flutter/material.dart';
import 'package:testdrive/library_page.dart';
import 'package:testdrive/speakingintro.dart';
import 'package:testdrive/writingPage.dart';
import 'package:testdrive/audio_player_screen.dart';
import 'package:testdrive/chatAi.dart';
class SectionPage extends StatelessWidget {
  const SectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xFFFFFFF0),
      body:SafeArea(
        child:SingleChildScrollView(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Text('Welcome to EasyMind!',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 25,
                            fontFamily: 'Inter',
                            color: Color(0xFF373737))),
                    const SizedBox(height: 14),
                    Text('Choose a section to start practising',
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            fontFamily: 'Inter')),
                  ],
                ),
              ),
              const SizedBox(height: 24,),
              GestureDetector(
                onTap:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=>LibraryPage()));
                  
                  
                },
                child: Container(
                  width: 350, 
                  height: 101, 
                  margin: const EdgeInsets.only(left:23,bottom: 13), 
                  padding: const EdgeInsets.symmetric(horizontal: 20), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4E3),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text('Reading',
                      style: TextStyle(
                        color: Color(0xFF373737),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,),
                        ),
                        Text('Easy reading practice',
                        style: TextStyle(
                          color: const Color(0xFF373737), 
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14, 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4,),
              GestureDetector(
                onTap:(){
                  Navigator.push(context,
                  MaterialPageRoute(builder:(context)=>ListeningScreen())
                  );
                },
                child: Container(
                  width: 350, 
                  height: 101, 
                  margin: const EdgeInsets.only(left:23,bottom: 13), 
                  padding: const EdgeInsets.symmetric(horizontal: 20), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4E3),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text('Listening',
                      style: TextStyle(
                        color: Color(0xFF373737),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,),
                        ),
                        Text('Audio practice',
                        style: TextStyle(
                          color: const Color(0xFF373737), 
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14, 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4,),
              GestureDetector(
                onTap:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  SpeakingIntroPage()),
                  );
                },
                child: Container(
                  width: 350, 
                  height: 101, 
                  margin: const EdgeInsets.only(left:23,bottom: 13), 
                  padding: const EdgeInsets.symmetric(horizontal: 20), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4E3),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text('Speaking',
                      style: TextStyle(
                        color: Color(0xFF373737),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,),
                        ),
                        Text('Practice speaking skills',
                        style: TextStyle(
                          color: const Color(0xFF373737), 
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14, 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4,),
              GestureDetector(
                onTap:(){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder:(context)=>DyslexiaWritingApp())
                    );
                },
                child: Container(
                  width: 350, 
                  height: 101, 
                  margin: const EdgeInsets.only(left:23,bottom: 13), 
                  padding: const EdgeInsets.symmetric(horizontal: 20), 
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4E3),
                    borderRadius: BorderRadius.circular(8), 
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      const Text('Writing',
                      style: TextStyle(
                        color: Color(0xFF373737),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 24,),
                        ),
                        Text('Express your ideas',
                        style: TextStyle(
                          color: const Color(0xFF373737), 
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14, 
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4,),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context)=> AiChatPage())
                    );
                },
                child: Container(
                  width: 78,
                  height: 75,
                  margin: const EdgeInsets.only(left: 23, bottom: 13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4E3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'lib/images/Aihelp.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],  
          ),
        )
      )
    );
  }
}