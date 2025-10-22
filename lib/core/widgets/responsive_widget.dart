import 'package:flutter/material.dart';
import 'package:sync_event/core/util/responsive_helper.dart';

/// A responsive widget that adapts its layout based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? largeDesktop;
  final Widget? ultraWide;

  const ResponsiveWidget({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.largeDesktop,
    this.ultraWide,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (ResponsiveHelper.isUltraWide(context) && ultraWide != null) {
          return ultraWide!;
        } else if (ResponsiveHelper.isLargeDesktop(context) && largeDesktop != null) {
          return largeDesktop!;
        } else if (ResponsiveHelper.isDesktop(context) && desktop != null) {
          return desktop!;
        } else if (ResponsiveHelper.isTablet(context) && tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A responsive container that adapts its padding and constraints
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? maxWidth;
  final Alignment? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
      margin: margin,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? ResponsiveHelper.getMaxContentWidth(context),
      ),
      alignment: alignment,
      child: child,
    );
  }
}

/// A responsive grid that adapts its columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double? spacing;
  final double? runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    this.spacing,
    this.runSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final columns = ResponsiveHelper.getResponsiveGridColumns(
      context,
      mobileColumns: mobileColumns ?? 1,
      tabletColumns: tabletColumns ?? 2,
      desktopColumns: desktopColumns ?? 3,
    );

    final spacingValue = spacing ?? ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );

    final runSpacingValue = runSpacing ?? ResponsiveHelper.getResponsiveSpacing(
      context,
      mobile: 16,
      tablet: 20,
      desktop: 24,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacingValue,
        mainAxisSpacing: runSpacingValue,
        childAspectRatio: ResponsiveHelper.getAspectRatio(
          context,
          mobileRatio: 1.2,
          tabletRatio: 1.1,
          desktopRatio: 1.0,
        ),
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// A responsive text widget that adapts its size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double? mobileSize;
  final double? tabletSize;
  final double? desktopSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileSize,
    this.tabletSize,
    this.desktopSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: mobileSize ?? 14,
      tablet: tabletSize ?? 16,
      desktop: desktopSize ?? 18,
    );

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A responsive button that adapts its size based on screen size
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle? style;
  final bool isOutlined;

  const ResponsiveButton(
    this.text, {
    super.key,
    this.onPressed,
    this.icon,
    this.style,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveHelper.getButtonHeight(context);
    final fontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 14,
      tablet: 15,
      desktop: 16,
    );

    final baseStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        Size(double.infinity, buttonHeight),
      ),
      textStyle: WidgetStateProperty.all(
        TextStyle(fontSize: fontSize),
      ),
    );

    final finalStyle = style?.merge(baseStyle) ?? baseStyle;

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, baseSize: 20),
              )
            : const SizedBox.shrink(),
        label: Text(text),
        style: finalStyle,
      );
    } else {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null
            ? Icon(
                icon,
                size: ResponsiveHelper.getIconSize(context, baseSize: 20),
              )
            : const SizedBox.shrink(),
        label: Text(text),
        style: finalStyle,
      );
    }
  }
}

/// A responsive card that adapts its padding and elevation
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation ?? ResponsiveHelper.getElevation(context),
      color: color,
      margin: margin ?? ResponsiveHelper.getResponsivePadding(context),
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ??
            BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, baseRadius: 12),
            ),
      ),
      child: Padding(
        padding: padding ?? ResponsiveHelper.getResponsivePadding(context),
        child: child,
      ),
    );
  }
}