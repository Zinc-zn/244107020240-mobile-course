import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lyrics Song',
      debugShowCheckedModeBanner: false,
      home: LayarLirik(),
    );
  }
}

class LayarLirik extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'YOU!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          'LANY',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Bagian Lirik
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      "Like water in the desert\nImpossible to find\nYou found me when I was broken\nPut me back together, gave me life\nLike a flower in the concrete\nSo beautiful and rare",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "You gave me hope when I was empty\nWalked me through the fire, you were there\nYou're the sun to the moon\nYou're my ocean, painted blue\nYou, I'm nothing without you\n(Without you, without you)\nLike an angel in a nightmare\nYou opened up my eyes\nLooking in all the wrong places\nYou're the one I needed this whole time\nYou're the sun to the moon\nYou're my ocean, painted blue\nYou, I'm nothing without you\n(Without you, without you)\nYou're the light in the dark\nYou're the arrow through my heart\nYou, I'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you\nYou, I'm nothing without you\nI'm nothing without you\nI'm nothing without you\nI'm nothing without you\nYou're the air in my lungs\nYou're the veins to my blood\nYeah, you, I'm nothing without you\nYou're the sun to the moon\nYou're my ocean, painted blue\nYou, I'm nothing without you\n(Without you, without you)\nYou're the light in the dark\nYou're the arrow through my heart\nYou, I'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you (oh, oh)\nI'm nothing without you",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: Colors.black45,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "0:31",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 4,
                        width: 50,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "3:51",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              Center(
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(Icons.pause, size: 32, color: Colors.black),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(Icons.play_arrow, size: 32, color: Colors.black),
                ),
              ),

              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(
                    Icons.skip_previous,
                    size: 32,
                    color: Colors.black,
                  ),
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
