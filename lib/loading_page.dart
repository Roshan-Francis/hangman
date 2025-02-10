import 'package:flutter/material.dart';
import 'package:hangman/start_page.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    
    Future.wait([
      for (var i = 0; i < 7; i++) 
        precacheImage(AssetImage('assets/images/hangman$i.png'), context)
    ]).then((_) {
      
      Future.delayed(Duration(seconds: 3), () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(55, 1, 35, 1), 
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    
                    Text(
                      "Loading ...",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.7),
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    SizedBox(
                      width: 250, 
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : StartPage(), 
    );
  }
}
