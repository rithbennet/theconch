import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShakeAnimationWidget extends StatefulWidget {
  final Widget child;
  final bool isShaking;
  final double movementX;
  final double movementY;
  final double intensity;

  const ShakeAnimationWidget({
    super.key,
    required this.child,
    required this.isShaking,
    this.movementX = 0.0,
    this.movementY = 0.0,
    this.intensity = 1.0,
  });

  @override
  State<ShakeAnimationWidget> createState() => _ShakeAnimationWidgetState();
}

class _ShakeAnimationWidgetState extends State<ShakeAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(ShakeAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isShaking && !oldWidget.isShaking) {
      _animationController.reset();
      _animationController.forward();
    } else if (!widget.isShaking && oldWidget.isShaking) {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double offsetX = 0.0;
        double offsetY = 0.0;
        double rotationAngle = 0.0;
          if (widget.isShaking) {
          // Generate shake animation using the animation controller
          final animationValue = _animation.value;
          
          // Create more dramatic shake effect with multiple sine waves
          offsetX = math.sin(animationValue * math.pi * 20) * 25 * widget.intensity;
          offsetY = math.cos(animationValue * math.pi * 15) * 15 * widget.intensity;
          rotationAngle = math.sin(animationValue * math.pi * 25) * 0.3 * widget.intensity;
          
          // Add dampening effect as animation progresses
          final dampening = 1.0 - (animationValue * 0.8);
          offsetX *= dampening;
          offsetY *= dampening;
          rotationAngle *= dampening;
          
          // If accelerometer data is provided, add it to the shake
          if (widget.movementX != 0.0 || widget.movementY != 0.0) {
            offsetX += widget.movementX * widget.intensity * 0.5;
            offsetY += widget.movementY * widget.intensity * 0.5;
            rotationAngle += (widget.movementX / 50) * widget.intensity * 0.5;
          }
          
          // Clamp values to reasonable limits
          offsetX = offsetX.clamp(-40.0, 40.0);
          offsetY = offsetY.clamp(-30.0, 30.0);
          rotationAngle = rotationAngle.clamp(-0.4, 0.4);
        }
        
        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform.rotate(
            angle: rotationAngle,
            child: widget.child,
          ),
        );
      },
    );
  }
}