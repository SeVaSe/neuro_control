import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../../assets/colors/app_colors.dart';

class VideoHelloPage extends StatefulWidget {
  const VideoHelloPage({Key? key}) : super(key: key);

  @override
  State<VideoHelloPage> createState() => _VideoHelloPageState();
}

class _VideoHelloPageState extends State<VideoHelloPage> {
  // Цвета
  // static const Color primaryColor = Color(0xFF0A3D91);
  // static const Color secondaryColor = Color(0xFF1565C0);
  // static const Color thirdColor = Colors.white;
  // static const Color mainTitleColor = secondaryColor;
  // static const Color text1Color = Color(0xFF1E88E5);
  // static const Color text2Color = Color(0xFF0D47A1);

  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset('lib/assets/videos/welcome_video.mp4');
      await _controller.initialize();

      _controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      setState(() {
        _isLoading = false;
      });

      // Автоматически скрывать элементы управления через 3 секунды
      _hideControlsAfterDelay();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Ошибка загрузки видео: ${e.toString()}';
      });
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
      _hideControlsAfterDelay();
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Видео приветствие',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_hasError) {
      return _buildErrorWidget();
    }

    return _buildVideoPlayer();
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryColor, AppColors.secondryColor],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.thirdColor),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Text(
              'Загрузка видео...',
              style: TextStyle(
                color: AppColors.thirdColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryColor, AppColors.secondryColor],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 20),
              const Text(
                'Ошибка загрузки видео',
                style: TextStyle(
                  color: AppColors.thirdColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Неизвестная ошибка',
                style: TextStyle(
                  color: AppColors.thirdColor.withOpacity(0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _hasError = false;
                  });
                  _initializeVideo();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Попробовать снова'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.text1Color,
                  foregroundColor: AppColors.thirdColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            // Видео контейнер
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onTap: _toggleControls,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Видео плеер
                        Center(
                          child: AspectRatio(
                            aspectRatio: _controller.value.aspectRatio,
                            child: VideoPlayer(_controller),
                          ),
                        ),

                        // Элементы управления
                        if (_showControls) _buildControls(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Информационная панель
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black,
                    AppColors.primaryColor.withOpacity(0.1),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Прогресс бар
                  _buildProgressBar(),
                  const SizedBox(height: 16),
                  // Кнопки управления
                  _buildControlButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
          ],
        ),
      ),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _togglePlayPause,
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 48,
              color: AppColors.thirdColor,
            ),
            padding: const EdgeInsets.all(20),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(
            _formatDuration(_controller.value.position),
            style: TextStyle(
              color: AppColors.thirdColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.text1Color,
                  inactiveTrackColor: AppColors.thirdColor.withOpacity(0.2),
                  thumbColor: AppColors.text1Color,
                  overlayColor: AppColors.text1Color.withOpacity(0.2),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _controller.value.position.inMilliseconds.toDouble(),
                  max: _controller.value.duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    _controller.seekTo(Duration(milliseconds: value.toInt()));
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _formatDuration(_controller.value.duration),
            style: TextStyle(
              color: AppColors.thirdColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: Icons.replay_10,
          onPressed: () {
            final newPosition = _controller.value.position - const Duration(seconds: 10);
            _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
          },
          label: '-10с',
        ),
        _buildControlButton(
          icon: _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
          onPressed: _togglePlayPause,
          isMain: true,
          label: _controller.value.isPlaying ? 'Пауза' : 'Играть',
        ),
        _buildControlButton(
          icon: Icons.forward_10,
          onPressed: () {
            final newPosition = _controller.value.position + const Duration(seconds: 10);
            _controller.seekTo(newPosition > _controller.value.duration
                ? _controller.value.duration
                : newPosition);
          },
          label: '+10с',
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String label,
    bool isMain = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isMain ? AppColors.text1Color : Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(
              icon,
              color: AppColors.thirdColor,
              size: isMain ? 28 : 22,
            ),
            padding: EdgeInsets.all(isMain ? 16 : 12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.thirdColor.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}