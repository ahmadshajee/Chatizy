import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// A premium animated mesh gradient background that floats colorful blurred
/// circular blobs under a frosted glass overlay.
class AnimatedGlassBackground extends StatefulWidget {
  final Widget? child;
  const AnimatedGlassBackground({super.key, this.child});

  @override
  State<AnimatedGlassBackground> createState() => _AnimatedGlassBackgroundState();
}

class _AnimatedGlassBackgroundState extends State<AnimatedGlassBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme colors for base background and glass overlay
    final baseBgColor = isDark ? const Color(0xFF070B19) : const Color(0xFFF4F4F7);
    final overlayColor = isDark 
        ? Colors.black.withValues(alpha: 0.25) 
        : Colors.white.withValues(alpha: 0.65);

    // Floating blobs colors
    final blob1Color = isDark 
        ? const Color(0xFF5E5CE6).withValues(alpha: 0.45) 
        : const Color(0xFFE5E2FF).withValues(alpha: 0.35); // Soft Lavender
    final blob2Color = isDark 
        ? const Color(0xFF0DF5E3).withValues(alpha: 0.35) 
        : const Color(0xFFE2FDFC).withValues(alpha: 0.35); // Soft Cyan
    final blob3Color = isDark 
        ? const Color(0xFFFF2D55).withValues(alpha: 0.35) 
        : const Color(0xFFFDE2ED).withValues(alpha: 0.35); // Soft Pink
    final blob4Color = isDark 
        ? const Color(0xFF0A84FF).withValues(alpha: 0.4) 
        : const Color(0xFFE1F0FF).withValues(alpha: 0.4); // Soft Sky Blue

    return Stack(
      children: [
        // Base canvas color
        Container(
          color: baseBgColor,
        ),
        // Floating animated blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final value = _controller.value;
            double t = value * 2 * math.pi;
            
            // Clean trigonometric trajectories using dart:math
            double b1x = size.width * (0.3 + 0.15 * math.sin(t));
            double b1y = size.height * (0.25 + 0.12 * math.cos(t));

            double b2x = size.width * (0.7 - 0.18 * math.cos(t * 1.3));
            double b2y = size.height * (0.35 + 0.15 * math.sin(t * 1.3));

            double b3x = size.width * (0.4 + 0.2 * math.sin(t * 0.7 + 1.0));
            double b3y = size.height * (0.75 - 0.15 * math.cos(t * 0.7 + 1.0));

            double b4x = size.width * (0.8 - 0.15 * math.cos(t * 0.9 - 0.5));
            double b4y = size.height * (0.8 - 0.12 * math.sin(t * 0.9 - 0.5));

            return Stack(
              children: [
                // Blob 1: Lavender
                Positioned(
                  left: b1x - 180,
                  top: b1y - 180,
                  child: _BackgroundBlob(
                    width: 360,
                    height: 360,
                    color: blob1Color,
                  ),
                ),
                // Blob 2: Cyan Glow
                Positioned(
                  left: b2x - 200,
                  top: b2y - 200,
                  child: _BackgroundBlob(
                    width: 400,
                    height: 400,
                    color: blob2Color,
                  ),
                ),
                // Blob 3: Pink Highlight
                Positioned(
                  left: b3x - 160,
                  top: b3y - 160,
                  child: _BackgroundBlob(
                    width: 320,
                    height: 320,
                    color: blob3Color,
                  ),
                ),
                // Blob 4: Sky Blue
                Positioned(
                  left: b4x - 180,
                  top: b4y - 180,
                  child: _BackgroundBlob(
                    width: 360,
                    height: 360,
                    color: blob4Color,
                  ),
                ),
              ],
            );
          },
        ),
        // Frosted glass filter layer that blends everything
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(
              color: overlayColor,
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

/// Helper math class that safely bridges to dart:math
class _BackgroundBlob extends StatelessWidget {
  final double width;
  final double height;
  final Color color;

  const _BackgroundBlob({
    required this.width,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.1),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

/// A standard frosted glass panel wrapper.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final double blurSigma;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.border,
    this.blurSigma = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final defaultRadius = BorderRadius.circular(24);
    final finalRadius = borderRadius ?? defaultRadius;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.72);

    final defaultBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.65);

    final defaultShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.04);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: finalRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? defaultBgColor,
              borderRadius: finalRadius,
              border: border ??
                  Border.all(
                    color: defaultBorderColor,
                    width: 0.8,
                  ),
              boxShadow: [
                BoxShadow(
                  color: defaultShadowColor,
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A wrapper scaffold that applies the glass background and automatically handles glass AppBars
class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;

  const GlassScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar != null
          ? PreferredSize(
              preferredSize: appBar!.preferredSize,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: appBar!,
                ),
              ),
            )
          : null,
      body: AnimatedGlassBackground(
        child: SafeArea(
          child: body,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: bottomNavigationBar!,
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// A premium glassmorphic button with an inner glow or glowing gradient look.
class GlassButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool isGlowing;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const GlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.isGlowing = false,
    this.width,
    this.height = 54.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final finalRadius = borderRadius ?? BorderRadius.circular(27);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBgColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.6);

    final defaultBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.white.withValues(alpha: 0.55);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: finalRadius,
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: const Color(0xFF0A84FF).withValues(alpha: isDark ? 0.35 : 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: finalRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: isGlowing
                  ? null // Handled by gradient decoration in Container
                  : defaultBgColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: finalRadius,
                side: BorderSide(
                  color: isGlowing
                      ? const Color(0xFF0A84FF).withValues(alpha: 0.5)
                      : defaultBorderColor,
                  width: 0.8,
                 ),
              ),
            ),
            child: isGlowing
                ? Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF007AFF),
                          Color(0xFF8A2BB9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: finalRadius,
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: child,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }
}

/// A premium glassmorphic input field.
class GlassTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const GlassTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.errorText,
  });

  @override
  State<GlassTextField> createState() => _GlassTextFieldState();
}

class _GlassTextFieldState extends State<GlassTextField> {
  bool _isFocused = false;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final defaultHintColor = isDark ? Colors.white.withValues(alpha: 0.4) : const Color(0xFF8E8E93);
    final defaultIconColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF8E8E93);
    final defaultFillColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.55);
    final defaultBorderColor = isDark ? Colors.white.withValues(alpha: 0.12) : const Color(0xFFD1D1D6);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.errorText != null
              ? Colors.red.withValues(alpha: 0.6)
              : _isFocused
                  ? const Color(0xFF0A84FF).withValues(alpha: 0.6)
                  : defaultBorderColor,
          width: 0.8,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFF0A84FF).withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 0),
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            style: TextStyle(
              color: defaultTextColor,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: defaultHintColor,
                fontSize: 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(color: defaultIconColor),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconTheme(
                      data: IconThemeData(color: defaultIconColor),
                      child: widget.suffixIcon!,
                    )
                  : null,
              filled: true,
              fillColor: defaultFillColor,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              errorText: widget.errorText,
              errorStyle: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A floating bottom navigation bar that acts like visionOS floating dock
class GlassBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const GlassBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultBgColor = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.7);
        
    final defaultBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.5);
        
    final unselectedColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF8E8E93);
        
    final unselectedTextCol = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF8E8E93);
        
    final selectedTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: GlassCard(
        borderRadius: BorderRadius.circular(32),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        backgroundColor: defaultBgColor,
        border: Border.all(
          color: defaultBorderColor,
          width: 0.8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;
            return GestureDetector(
              onTap: () => onTap(index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.05))
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: IconTheme(
                        data: IconThemeData(
                          color: isSelected
                              ? const Color(0xFF0A84FF)
                              : unselectedColor,
                          size: 24,
                        ),
                        child: isSelected ? item.activeIcon : item.icon,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label ?? '',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? selectedTextColor
                            : unselectedTextCol,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Custom FocusWrapper since we need to detect focus changes for styling
class FocusWrapper extends StatefulWidget {
  final Widget child;
  final ValueChanged<bool> onFocusChange;

  const FocusWrapper({
    super.key,
    required this.child,
    required this.onFocusChange,
  });

  @override
  State<FocusWrapper> createState() => _FocusWrapperState();
}

class _FocusWrapperState extends State<FocusWrapper> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      widget.onFocusChange(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      child: widget.child,
    );
  }
}

/// A premium glassmorphic alert dialog matching the Apple Glass aesthetic.
class GlassAlertDialog extends StatelessWidget {
  final Widget? icon;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final MainAxisAlignment? actionsAlignment;

  const GlassAlertDialog({
    super.key,
    this.icon,
    this.title,
    this.content,
    this.actions,
    this.actionsAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final defaultBgColor = isDark
        ? Colors.black.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.85);
        
    final defaultBorderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.white.withValues(alpha: 0.55);
        
    final titleTextColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final contentTextColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF636366);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: GlassCard(
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.all(24),
        backgroundColor: defaultBgColor,
        border: Border.all(
          color: defaultBorderColor,
          width: 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(child: icon!),
              const SizedBox(height: 16),
            ],
            if (title != null) ...[
              DefaultTextStyle(
                style: TextStyle(
                  color: titleTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: icon != null ? TextAlign.center : TextAlign.start,
                child: title!,
              ),
              const SizedBox(height: 16),
            ],
            if (content != null) ...[
              DefaultTextStyle(
                style: TextStyle(
                  color: contentTextColor,
                  fontSize: 15,
                ),
                child: content!,
               ),
              const SizedBox(height: 24),
            ],
            if (actions != null)
              Row(
                mainAxisAlignment: actionsAlignment ?? MainAxisAlignment.end,
                children: actions!.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: action,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
