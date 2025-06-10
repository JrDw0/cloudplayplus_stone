import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cloudplayplus/base/logging.dart';
import 'package:cloudplayplus/services/app_info_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/app_init_service.dart';
import '../theme/fixed_colors.dart';
import '../pages/login_screen.dart';
import '../pages/main_page.dart';

class ReconnectScreen extends StatefulWidget {
  const ReconnectScreen({super.key});

  @override
  State<ReconnectScreen> createState() => _ReconnectScreenState();
}

class _ReconnectScreenState extends State<ReconnectScreen> {
  int _secondsRemaining = 10;
  Timer? _timer;
  bool _isCancelled = false;
  bool _reconnectSuccess = false;
  int _retryCount = 1;
  static const int maxRetries = 99999;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isCancelled || _reconnectSuccess) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        }
      });

      if (_secondsRemaining <= 0) {
        timer.cancel();
        _attemptReconnect();
      }
    });
  }

  Future<void> _attemptReconnect() async {
    if (_isCancelled || _reconnectSuccess) return;

    if (_retryCount >= maxRetries) {
      VLOG0('达到最大重试次数，停止重连');
      _cancelReconnect();
      return;
    }

    setState(() {
      _retryCount++;
    });

    final success = await AppInitService.reconnect();
    if (success) {
      if (ApplicationInfo.connectable &&
          ApplicationInfo.isSystem &&
          AppPlatform.isWindows) {
        appWindow.hide();
      }
      setState(() {
        _reconnectSuccess = true;
      });
    } else if (!_isCancelled) {
      setState(() {
        _secondsRemaining = 10 + _retryCount;
      });
      _startTimer();
    }
  }

  void _cancelReconnect() {
    setState(() {
      _isCancelled = true;
    });
    _timer?.cancel();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_reconnectSuccess) {
      return const MainScreen();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultTextStyle(
              style: const TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              child: AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Cloud Play Plus',
                    textStyle: colorizeTextStyle,
                    colors: colorizeColors,
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
            const SizedBox(height: 20),
            const SpinKitCircle(size: 51.0, color: Colors.white),
            const SizedBox(height: 30),
            Text(
              '网络连接失败: $_secondsRemaining 秒后重连 (第 $_retryCount 次尝试)',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cancelReconnect,
              child: const Text('取消重连'),
            ),
          ],
        ),
      ),
    );
  }
}
