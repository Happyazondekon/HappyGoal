import 'package:flutter/material.dart';
import 'package:happygoal/utils/audio_manager.dart';
import 'package:happygoal/l10n/app_localizations.dart';
import 'package:happygoal/utils/responsive_helper.dart';

class AudioSettingsWidget extends StatefulWidget {
  const AudioSettingsWidget({Key? key}) : super(key: key);

  @override
  State<AudioSettingsWidget> createState() => _AudioSettingsWidgetState();
}

class _AudioSettingsWidgetState extends State<AudioSettingsWidget>
    with SingleTickerProviderStateMixin {
  bool _isSoundEnabled = true;
  bool _isMusicEnabled = true;
  bool _playInBackground = false;
  double _volume = 0.5;

  late AnimationController _entryController;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = AudioManager.getSettings();
    setState(() {
      _isSoundEnabled = settings['soundEnabled'];
      _isMusicEnabled = settings['musicEnabled'];
      _playInBackground = settings['playInBackground'];
      _volume = settings['volume'];
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entryController,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 16)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.scale(context, 16),
                vertical: ResponsiveHelper.scale(context, 12),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ResponsiveHelper.scale(context, 16)),
                ),
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(ResponsiveHelper.scale(context, 6)),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      ),
                      borderRadius:
                      BorderRadius.circular(ResponsiveHelper.scale(context, 8)),
                    ),
                    child: Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white,
                      size: ResponsiveHelper.scale(context, 16),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.scale(context, 10)),
                  Text(
                    AppLocalizations.of(context)!.audioSettingsTitle,
                    style: TextStyle(
                      fontSize: ResponsiveHelper.textScale(context, 15),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Toggles ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.all(ResponsiveHelper.scale(context, 12)),
              child: Column(
                children: [
                  _buildToggleRow(
                    icon: Icons.music_note_rounded,
                    iconColor: const Color(0xFFFFD700),
                    label: AppLocalizations.of(context)!.audioSettingsSound,
                    value: _isSoundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isSoundEnabled = value;
                        AudioManager.setSoundEnabled(value);
                        if (_isSoundEnabled) {
                          AudioManager.playSound('whistle');
                        }
                      });
                    },
                  ),

                  _buildDivider(),

                  _buildToggleRow(
                    icon: Icons.library_music_rounded,
                    iconColor: const Color(0xFF2196F3),
                    label: AppLocalizations.of(context)!.audioSettingsMusic,
                    value: _isMusicEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isMusicEnabled = value;
                        AudioManager.setMusicEnabled(value);
                      });
                    },
                  ),

                  _buildDivider(),

                  _buildToggleRow(
                    icon: Icons.headphones_rounded,
                    iconColor: const Color(0xFF9C27B0),
                    label: AppLocalizations.of(context)!.audioSettingsBackground,
                    subtitle: AppLocalizations.of(context)!.audioSettingsBackgroundDesc,
                    value: _playInBackground,
                    onChanged: (value) {
                      setState(() {
                        _playInBackground = value;
                        AudioManager.setPlayInBackground(value);
                      });
                    },
                  ),

                  _buildDivider(),

                  // ── Volume Slider ────────────────────────────────────
                  _buildVolumeRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.scale(context, 4),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.scale(context, 34),
            height: ResponsiveHelper.scale(context, 34),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.scale(context, 10)),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: ResponsiveHelper.scale(context, 16)),
          ),
          SizedBox(width: ResponsiveHelper.scale(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveHelper.textScale(context, 14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: ResponsiveHelper.scale(context, 2)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: ResponsiveHelper.textScale(context, 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildCustomSwitch(value, onChanged, iconColor),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(bool value, ValueChanged<bool> onChanged, Color activeColor) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: ResponsiveHelper.scale(context, 44),
        height: ResponsiveHelper.scale(context, 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveHelper.scale(context, 12)),
          gradient: value
              ? LinearGradient(
            colors: [activeColor, activeColor.withOpacity(0.7)],
          )
              : null,
          color: value ? null : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: value ? activeColor.withOpacity(0.5) : Colors.white.withOpacity(0.12),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              left: value ? ResponsiveHelper.scale(context, 22) : ResponsiveHelper.scale(context, 2),
              top: ResponsiveHelper.scale(context, 2),
              child: Container(
                width: ResponsiveHelper.scale(context, 18),
                height: ResponsiveHelper.scale(context, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveHelper.scale(context, 4),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.scale(context, 34),
            height: ResponsiveHelper.scale(context, 34),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(ResponsiveHelper.scale(context, 10)),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.2)),
            ),
            child: Icon(
              _volume == 0
                  ? Icons.volume_off_rounded
                  : _volume < 0.5
                  ? Icons.volume_down_rounded
                  : Icons.volume_up_rounded,
              color: const Color(0xFF4CAF50),
              size: ResponsiveHelper.scale(context, 16),
            ),
          ),
          SizedBox(width: ResponsiveHelper.scale(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Volume',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ResponsiveHelper.textScale(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.scale(context, 8),
                        vertical: ResponsiveHelper.scale(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(
                            ResponsiveHelper.scale(context, 6)),
                      ),
                      child: Text(
                        '${(_volume * 100).round()}%',
                        style: TextStyle(
                          color: const Color(0xFF4CAF50),
                          fontSize:
                          ResponsiveHelper.textScale(context, 11),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: ResponsiveHelper.scale(context, 4)),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: ResponsiveHelper.scale(context, 3),
                    thumbShape: RoundSliderThumbShape(
                      enabledThumbRadius: ResponsiveHelper.scale(context, 8),
                      elevation: 2,
                    ),
                    activeTrackColor: const Color(0xFF4CAF50),
                    inactiveTrackColor: Colors.white.withOpacity(0.12),
                    overlayShape: RoundSliderOverlayShape(
                      overlayRadius: ResponsiveHelper.scale(context, 14),
                    ),
                  ),
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    onChanged: (value) {
                      setState(() {
                        _volume = value;
                        AudioManager.setVolume(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.06),
      height: ResponsiveHelper.scale(context, 16),
      thickness: 1,
    );
  }
}