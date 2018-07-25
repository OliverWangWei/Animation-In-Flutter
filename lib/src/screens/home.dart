import 'package:flutter/material.dart';
import '../widgets/cat.dart';
import 'dart:math';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

// TickerProvider 給widget外面的世界一個識別證可以進來該widget, 為了通知AnimationController更新
class _HomeState extends State<Home> with TickerProviderStateMixin {
  // 這兩個變數會在widget整個生命中持續存在被持有
  Animation<double> catAnimation;
  AnimationController catController;

  Animation<double> boxAnimation;
  AnimationController boxController;

  // 1. 當State第一次被創建時會調用這個方法
  // 2. 只有繼承State的widget才有該方法
  // 3. 用來初始化實體變數
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    boxController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    boxAnimation = Tween(begin: pi * 0.6, end: pi * 0.65).animate(
      CurvedAnimation(
        parent: boxController,
        curve: Curves.easeInOut, // constant change between 0.0 to 3.14
      ),
    );

    // 監聽動畫的狀態
    boxController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        boxController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        boxController.forward();
      }
    });

    boxController.forward();

    catController = AnimationController(
      duration: Duration(milliseconds: 200), // 該動畫會持續多久
      vsync: this, // 代表嵌入TickerProvider到當前運行的widget實體
    );

    catAnimation = Tween(begin: -30.0, end: -80.0).animate(CurvedAnimation(
      // 該widget用來描述, 動畫數值從begin到end的比率有多快
      parent: catController,
      curve: Curves.easeIn,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation!'),
      ),
      body: GestureDetector(
        // 手勢偵測器
        child: Center(
          child: Stack(
            overflow: Overflow.visible, // 超過stack邊間的子類都顯示出來
            children: <Widget>[
              buildCatAnimation(),
              buildBox(),
              buildLeftFlap(),
              buildRightFlap()
            ],
          ),
        ), // 偵測該子widget上使用者的手勢
        onTap: onTap,
      ),
    );
  }

  Widget buildCatAnimation() {
    return AnimatedBuilder(
      animation: catAnimation,
      child: Cat(), // a really expensive widget to create
      // 從streamBuilder的學習經驗來看, 匿名方法都會返回一個新的widget以供畫面重新渲染,
      // 但是在動畫上面每秒會更新60次也就是每秒渲染60次, 這會造成極大的負擔.
      // 因此, 匿名方法只負責處理相對微小的變動數值
      // 而不想被頻繁渲染的物件就指派給child屬性, 讓每次builder function 被調用時只需將child傳入就好
      // 並不需要再重新創建
      builder: (context, child) {
        // will not resize Stack anymore, and Stack will not care about it
        return Positioned(
          // inexpensive widget to create
          child: child,
          top: catAnimation.value,
          // constraints to left and right, cause the original thing is too big
          right: 0.0,
          left: 0.0,
        );
      },
    );
  }

  void onTap() {
    if (catController.status == AnimationStatus.completed) {
      // finish the animation
      catController.reverse(); // 200 ---> 0
      boxController.forward();
    } else if (catController.status == AnimationStatus.dismissed) {
      // stop at the beginning
      catController.forward(); // 0 ---> 200
      boxController.stop();
    }
  }

  Widget buildBox() {
    return Container(
      height: 200.0,
      width: 200.0,
      color: Colors.brown,
    );
  }

  Widget buildLeftFlap() {
    return Positioned(
      left: 3.0,
      top: 1.0,
      child: AnimatedBuilder(
        animation: boxAnimation,
        child: Container(
          height: 10.0,
          width: 125.0,
          color: Colors.brown,
        ),
        builder: (context, child) {
          return Transform.rotate(
            angle: boxAnimation.value,
            alignment: Alignment.topLeft, // widget的重心
            child: child,
          );
        },
      ),
    );
  }

  Widget buildRightFlap() {
    // flutter: Positioned widgets must be placed directly inside Stack widgets.
    return Positioned(
      top: 1.0,
      right: 3.0,
      child: AnimatedBuilder(
        animation: boxAnimation,
        child: Container(
          height: 10.0,
          width: 125.0,
          color: Colors.brown,
        ),
        builder: (context, child) {
          return Transform.rotate(
            angle: -boxAnimation.value,
            alignment: Alignment.topRight, // widget的重心
            child: child,
          );
        },
      ),
    );
  }
}
