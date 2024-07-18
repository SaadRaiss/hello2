import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/img/saad.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 120,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: ElevatedButton(
              onPressed: () {
                String password = _passwordController.text;
                if (password.isEmpty) {
                  setState(() {
                    _errorMessage = 'Password cannot be empty. Please enter your password.';
                  });
                } else if (password == '12345') { // Assuming '123' is the correct password for demonstration
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                } else {
                  setState(() {
                    _errorMessage = 'Incorrect password. Try again.';
                  });
                }
              },
              child: Text('Login'),
            ),
          ),
          if (_errorMessage.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = -1;

  static List<Widget> _widgetOptions = <Widget>[
    DrawingPage(),
    FilterPage(),
    CustomDimensionPage(),
    DeveloperPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == -1 ? 'Home Page' : 'Home Page'),
        leading: _selectedIndex != -1 ? IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            setState(() {
              _selectedIndex = -1;
            });
          },
        ) : null,
      ),
      body: _selectedIndex == -1
          ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Welcome to ImageFlex', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Image.asset('assets/img/saad2.jpg', fit: BoxFit.cover),
          ),
        ],
      )
          : _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.brush),
            label: 'Draw',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_filter),
            label: 'Filters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.aspect_ratio),
            label: 'Dimensions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Developer',
          ),
        ],
        currentIndex: _selectedIndex == -1 ? 0 : _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}


class DrawingPage extends StatefulWidget {
  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  List<DrawingPoint?> points = [];
  bool isEraser = false;

  void toggleEraser() {
    setState(() {
      isEraser = !isEraser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Text("Drawing Board", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  RenderBox renderBox = context.findRenderObject() as RenderBox;
                  Offset localPosition = renderBox.globalToLocal(details.globalPosition);
                  points.add(
                    DrawingPoint(
                      points: localPosition,
                      paint: Paint()
                        ..color = isEraser ? Colors.white : Colors.black
                        ..strokeCap = StrokeCap.round
                        ..strokeWidth = isEraser ? 20.0 : 5.0,
                    ),
                  );
                });
              },
              onPanEnd: (details) {
                points.add(null);
              },
              child: CustomPaint(
                painter: DrawingPainter(points),
                child: Container(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isEraser ? Icons.brush : Icons.delete),
            onPressed: toggleEraser,
          ),
        ],
      ),
    );
  }
}

class DrawingPoint {
  Paint paint;
  Offset points;
  DrawingPoint({required this.points, required this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint?> points;

  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!.points, points[i + 1]!.points, points[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
class CustomDimensionPage extends StatefulWidget {
  @override
  _CustomDimensionPageState createState() => _CustomDimensionPageState();
}

class _CustomDimensionPageState extends State<CustomDimensionPage> {
  double _scale = 1.0;
  double _rotation = 0;

  void _zoom(bool inOut) {
    setState(() {
      _scale = inOut ? _scale * 1.1 : (_scale > 1 ? _scale / 1.1 : 1);
    });
  }

  void _rotate(bool leftRight) {
    setState(() {
      _rotation += leftRight ? math.pi / 16 : -math.pi / 16;
    });
  }

  void _reset() {
    setState(() {
      _scale = 1.0;
      _rotation = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Dimension'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateZ(_rotation)..scale(_scale),
                  child: Image.asset('assets/img/IRON_MAN.jpg'),
                ),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                FloatingActionButton(
                  onPressed: () => _zoom(true),
                  child: Icon(Icons.zoom_in),
                ),
                FloatingActionButton(
                  onPressed: () => _zoom(false),
                  child: Icon(Icons.zoom_out),
                ),
                FloatingActionButton(
                  onPressed: () => _rotate(true),
                  child: Icon(Icons.rotate_left),
                ),
                FloatingActionButton(
                  onPressed: () => _rotate(false),
                  child: Icon(Icons.rotate_right),
                ),
                FloatingActionButton(
                  onPressed: _reset,
                  child: Icon(Icons.restore),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class DeveloperPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('The Developer of Application'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/img/SI SAAD.jpeg'),
              SizedBox(height: 20), // Espacer l'image du texte
              Text(
                'SAAD RAISS\n1st year Engineering Cycle\nSchool of Digital Engineering and Artificial Intelligence\nEuromed University of Fez',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterPage extends StatefulWidget {
  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final String imagePath = 'assets/img/SBA3.jpg';
  Color? filterColor;

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.white,  // Use white to reset to the original image
  ];

  void _applyColorFilter(Color color) {
    setState(() {
      filterColor = color == Colors.white ? null : color;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Filters'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: filterColor == null
                  ? Image.asset(imagePath, fit: BoxFit.cover)
                  : ColorFiltered(
                colorFilter: ColorFilter.mode(filterColor!.withOpacity(0.6), BlendMode.modulate),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
          ),
          Wrap(
            spacing: 8.0,
            alignment: WrapAlignment.center,
            children: colors.map((color) => FloatingActionButton(
              backgroundColor: color,
              onPressed: () => _applyColorFilter(color),
              mini: true,
            )).toList(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
