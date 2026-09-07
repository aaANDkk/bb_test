import 'package:bett_box/common/common.dart';
import 'package:bett_box/enum/enum.dart';
import 'package:bett_box/models/models.dart';
import 'package:bett_box/state.dart';
import 'package:bett_box/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NetworkDetection extends ConsumerStatefulWidget {
  const NetworkDetection({super.key});

  @override
  ConsumerState<NetworkDetection> createState() => _NetworkDetectionState();
}

class _NetworkDetectionState extends ConsumerState<NetworkDetection> {

  void _showIpClickBehaviorSettings() {
    final isZh = Localizations.localeOf(context).languageCode == 'zh';
    globalState.showCommonDialog<IpClickBehavior>(
      child: CommonDialog(
        title: appLocalizations.ipClickBehavior,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sync),
              title: Text(appLocalizations.manualRefreshIp),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                detectionState.manualRefresh();
              },
            ),
            if (isZh)
              ListTile(
                leading: Icon(Icons.public),
                title: Text(appLocalizations.switchToDomesticIp),
                onTap: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  detectionState.switchToDomesticIp();
                },
              ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text(appLocalizations.ipPrivacyProtection),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
                detectionState.toggleIpPrivacy();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreIpInfoDialog() {
    final rawIpInfo = detectionState.rawIpInfo;
    if (rawIpInfo == null) return;
    showIpDetailDialog(context, rawIpInfo.ip);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getWidgetHeight(1),
      child: ValueListenableBuilder<NetworkDetectionState>(
        valueListenable: detectionState.state,
        builder: (_, state, _) {
          final ipInfo = state.ipInfo;
          final isLoading = state.isLoading;
          return CommonCard(
            onPressed: ipInfo != null ? _showMoreIpInfoDialog : () {},
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: globalState.measure.titleMediumHeight + 16,
                  padding: baseInfoEdgeInsets.copyWith(bottom: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ipInfo != null && ipInfo.countryCode.isNotEmpty
                          ? _CountryFlagIcon(
                              countryCode: ipInfo.countryCode,
                            )
                          : Icon(
                              Icons.network_check,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 1,
                        child: TooltipText(
                          text: Text(
                            appLocalizations.networkDetection,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2),
                      AspectRatio(
                        aspectRatio: 1,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: _showIpClickBehaviorSettings,
                          icon: Icon(
                            size: 16.ap,
                            Icons.settings_outlined,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: baseInfoEdgeInsets.copyWith(top: 0),
                  child: SizedBox(
                    height: globalState.measure.bodyMediumHeight + 2,
                    child: FadeThroughBox(
                      child: ipInfo != null
                          ? TooltipText(
                              text: Text(
                                ipInfo.ip,
                                style: context.textTheme.bodyMedium?.toLight
                                    .adjustSize(1),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          : FadeThroughBox(
                              child: isLoading == false && ipInfo == null
                                  ? Text(
                                      state.errorMessage ?? 'timeout',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(color: Colors.red)
                                          .adjustSize(1),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : Container(
                                      padding: const EdgeInsets.all(2),
                                      child: Center(
                                        child: OverflowBox(
                                          maxWidth: 30,
                                          maxHeight: 16,
                                          child: SpinKitThreeBounce(
                                            color: context.colorScheme.primary,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CountryFlagIcon extends StatelessWidget {
  final String countryCode;

  const _CountryFlagIcon({
    required this.countryCode,
  });

  // 与 NTP 小部件 (Icons.access_time) 视觉重量与尺寸像素级精确对齐：
  // 槽位 24x24，整体外径 (国旗+外包边) 严格锁定为 16.0dp，线宽 1.2dp
  static const double _slotSize = 24.0;
  static const double _totalDiameter = 16.0;
  static const double _strokeWidth = 1.2;

  static const Set<String> _flagCodes = {'ac', 'ad', 'ae', 'af-emirate', 'af', 'ag', 'ai', 'al', 'am', 'an', 'ao', 'aq-true_south', 'aq', 'ar', 'artsakh', 'as', 'at', 'au-aboriginal', 'au-act', 'au-nsw', 'au-nt', 'au-qld', 'au-sa', 'au-tas', 'au-torres_strait_islands', 'au-vic', 'au-wa', 'au', 'aw', 'ax', 'az', 'ba', 'bb', 'bd', 'be', 'bf', 'bg', 'bh', 'bi', 'bj', 'bl', 'bm', 'bn', 'bo', 'bq-bo', 'bq-sa', 'bq-se', 'bq', 'br', 'bs', 'bt', 'bv', 'bw', 'by-historical', 'by', 'bz', 'ca-bc', 'ca-qc', 'ca', 'cc', 'cd', 'cf', 'cg', 'ch-gr', 'ch', 'ci', 'ck', 'cl', 'cm', 'cn-hk', 'cn-xj', 'cn-xz', 'cn', 'co', 'cp', 'cq', 'cr', 'cu', 'cv', 'cw', 'cx', 'cy', 'cz', 'de', 'dg', 'dj', 'dk', 'dm', 'do', 'dz', 'ea', 'easter_island', 'east_african_federation', 'ec-w', 'ec', 'ee', 'eg', 'eh', 'er', 'es-ar', 'es-ce', 'es-cn', 'es-ct', 'es-ga', 'es-ib', 'es-ml', 'es-pv', 'es-variant', 'es-vc', 'es', 'et-af', 'et-am', 'et-be', 'et-ga', 'et-ha', 'et-or', 'et-si', 'et-sn', 'et-so', 'et-sw', 'et-ti', 'et', 'eu', 'european_union', 'ewe', 'fi', 'fj', 'fk', 'fm', 'fo', 'fr-20r', 'fr-bre', 'fr-cp', 'fr', 'fx', 'ga', 'gb-con', 'gb-eng', 'gb-nir', 'gb-ork', 'gb-sct', 'gb-wls', 'gb', 'gd', 'ge-ab', 'ge', 'gf', 'gg', 'gh', 'gi', 'gl', 'gm', 'gn', 'gp', 'gq', 'gr', 'gs', 'gt', 'gu', 'guarani', 'gw', 'gy', 'hausa', 'hk', 'hm', 'hmong', 'hn', 'hr', 'ht', 'hu', 'ic', 'id-jb', 'id-jt', 'id', 'ie', 'il', 'im', 'in-as', 'in-gj', 'in-ka', 'in-mn', 'in-mz', 'in-or', 'in-tg', 'in-tn', 'in', 'io', 'iq-kr', 'iq', 'ir', 'is', 'it-21', 'it-23', 'it-25', 'it-32', 'it-34', 'it-36', 'it-42', 'it-45', 'it-52', 'it-55', 'it-57', 'it-62', 'it-65', 'it-67', 'it-72', 'it-75', 'it-77', 'it-78', 'it-82', 'it-88', 'it', 'je', 'jm', 'jo', 'jp', 'kanuri', 'ke', 'kg', 'kh', 'ki', 'kikuyu', 'km', 'kn', 'kongo', 'kp', 'kr', 'kw', 'ky', 'kz', 'la', 'lb', 'lc', 'li', 'lk', 'lr', 'ls', 'lt', 'lu', 'lv', 'ly', 'ma', 'malayali', 'maori', 'mc', 'md', 'me', 'mf', 'mg', 'mh', 'mk', 'ml', 'mm', 'mn', 'mo', 'mp', 'mq-old', 'mq', 'mr', 'ms', 'mt-civil_ensign', 'mt', 'mu', 'mv', 'mw', 'mx', 'my', 'mz', 'na', 'nc', 'ne', 'nf', 'ng', 'ni', 'nl-fr', 'nl', 'no', 'northern_cyprus', 'np', 'nr', 'nu', 'nz', 'occitania', 'om', 'otomi', 'pa', 'pe', 'pf', 'pg', 'ph', 'pk-jk', 'pk-sd', 'pk', 'pl', 'pm', 'pn', 'pr', 'ps', 'pt-20', 'pt-30', 'pt', 'pw', 'py', 'qa', 'quechua', 're', 'ro', 'rs', 'ru-ba', 'ru-ce', 'ru-cu', 'ru-da', 'ru-dpr', 'ru-ko', 'ru-lpr', 'ru-ta', 'ru-ud', 'ru', 'rw', 'sa', 'sami', 'sb', 'sc', 'sd', 'se', 'sealand', 'sg', 'sh-ac', 'sh-hl', 'sh-ta', 'sh', 'si', 'sj', 'sk', 'sl', 'sm', 'sn', 'so', 'somaliland', 'south_ossetia', 'soviet_union', 'sr', 'ss', 'st', 'su', 'sv', 'sx', 'sy', 'sz', 'ta', 'tc', 'td', 'tf', 'tg', 'th', 'tj', 'tk', 'tl', 'tm', 'tn', 'to', 'tr', 'transnistria', 'tt', 'tv', 'tw', 'tz-zanzibar', 'tz', 'ua-bpr', 'ua-kpr', 'ua', 'ug', 'uk', 'um', 'un', 'us-ak', 'us-al', 'us-ar', 'us-as', 'us-az', 'us-betsy_ross', 'us-ca', 'us-co', 'us-confederate_battle', 'us-dc', 'us-fl', 'us-ga', 'us-gu', 'us-hi', 'us-in', 'us-md', 'us-mn', 'us-mo', 'us-mp', 'us-ms', 'us-nc', 'us-nm', 'us-or', 'us-pr', 'us-ri', 'us-sc', 'us-tn', 'us-tx', 'us-um', 'us-vi', 'us-wa', 'us-wi', 'us-wy', 'us', 'uy', 'uz', 'va', 'vc', 've', 'vg', 'vi', 'vn', 'vu', 'wf', 'wiphala', 'ws', 'xk', 'xx', 'ye', 'yorubaland', 'yt', 'yu', 'za', 'zm', 'zw'};

  @override
  Widget build(BuildContext context) {
    final code = countryCode.trim().toLowerCase();
    final borderColor = Theme.of(context).colorScheme.onSurfaceVariant;

    Widget fallbackIcon() => SizedBox.square(
          dimension: _slotSize,
          child: Icon(
            Icons.network_check,
            color: borderColor,
            size: _slotSize,
          ),
        );

    if (code.isEmpty || !_flagCodes.contains(code)) {
      return fallbackIcon();
    }

    final assetPath = 'assets/flags/$code.svg';

    return SizedBox.square(
      dimension: _slotSize,
      child: Center(
        child: Container(
          width: _totalDiameter,
          height: _totalDiameter,
          foregroundDecoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: _strokeWidth,
            ),
          ),
          child: ClipOval(
            child: SvgPicture.asset(
              assetPath,
              width: _totalDiameter,
              height: _totalDiameter,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => fallbackIcon(),
            ),
          ),
        ),
      ),
    );
  }
}

