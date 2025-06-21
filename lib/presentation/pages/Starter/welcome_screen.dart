import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../assets/colors/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  final VoidCallback onNext;

  const WelcomeScreen({Key? key, required this.onNext}) : super(key: key);

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _controlsAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _controlsOpacityAnimation;
  late VideoPlayerController _videoController;

  bool _isVideoInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVideo();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _controlsAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _controlsOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controlsAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
    _controlsAnimationController.forward();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset(
      'lib/assets/videos/welcome_video.mp4',
    )
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      })
      ..addListener(() {
        if (!mounted) return;
        final bool isPlaying = _videoController.value.isPlaying;
        if (isPlaying != _isPlaying) {
          setState(() {
            _isPlaying = isPlaying;
          });
        }
      });
  }

  void _togglePlayPause() {
    if (!_isVideoInitialized) return;

    if (_videoController.value.isPlaying) {
      _videoController.pause();
    } else {
      _videoController.play();
    }

    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    if (!_isVideoInitialized) return;

    setState(() => _showControls = true);
    _controlsAnimationController.forward();

    Future.delayed(Duration(seconds: 3), () {
      if (mounted && _videoController.value.isPlaying) {
        _hideControls();
      }
    });
  }

  void _hideControls() {
    if (_videoController.value.isPlaying) {
      _controlsAnimationController.reverse().then((_) {
        if (mounted) {
          setState(() => _showControls = false);
        }
      });
    }
  }

  void _onVideoTap() {
    if (_showControls) {
      _hideControls();
    } else {
      _showControlsTemporarily();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controlsAnimationController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildVideoPlayer(double screenWidth, double screenHeight) {
    if (!_isVideoInitialized) {
      return Container(
        width: screenWidth * 0.9,
        height: screenHeight * 0.25,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.8),
              AppColors.primaryColor,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    final videoAspectRatio = _videoController.value.aspectRatio;
    final containerWidth = screenWidth * 0.9;
    final maxHeight = screenHeight * 0.3;

    double videoWidth = containerWidth;
    double videoHeight = videoWidth / videoAspectRatio;

    if (videoHeight > maxHeight) {
      videoHeight = maxHeight;
      videoWidth = videoHeight * videoAspectRatio;
    }

    return Container(
      width: videoWidth,
      height: videoHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(child: VideoPlayer(_videoController)),

            if (_showControls || !_isPlaying)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                ),
              ),

            if (_showControls || !_isPlaying)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _onVideoTap,
                  behavior: HitTestBehavior.translucent,
                ),
              ),

            if (_showControls || !_isPlaying)
              AnimatedBuilder(
                animation: _controlsAnimationController,
                builder: (context, child) => Opacity(
                  opacity: _controlsOpacityAnimation.value,
                  child: Center(
                    child: GestureDetector(
                      onTap: _togglePlayPause,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.02,
          ),
          child: Column(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildVideoPlayer(screenWidth, screenHeight),
                          SizedBox(height: screenHeight * 0.04),
                          Text(
                            'Добро пожаловать!',
                            style: TextStyle(
                              fontSize: screenWidth * 0.08,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainTitleColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            'Это медицинское приложение поможет вам в оценке и мониторинге состояния здоровья.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              color: AppColors.text2Color,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Text(
                            'Давайте начнем настройку приложения специально для вас.',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              color: AppColors.text1Color,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Container(
                width: double.infinity,
                height: screenHeight * 0.07,
                constraints: BoxConstraints(minHeight: 50, maxHeight: 70),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: widget.onNext,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Начать настройку',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: screenWidth * 0.05,
                          ),
                        ],
                      ),
                    ),
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
