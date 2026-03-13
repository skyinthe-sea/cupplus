import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Computes SHA-256 hash of combined contract content for legal recordkeeping.
String computeContractHash(String termsContent, String privacyContent) {
  final combined = '$termsContent\n---\n$privacyContent';
  final bytes = utf8.encode(combined);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// Collects device info for contract agreement record.
Map<String, dynamic> collectDeviceInfo() {
  return {
    'platform': _platformName(),
    'os_version': Platform.operatingSystemVersion,
    'dart_version': Platform.version.split(' ').first,
    'is_debug': kDebugMode,
    'timestamp_utc': DateTime.now().toUtc().toIso8601String(),
  };
}

String _platformName() {
  if (Platform.isAndroid) return 'android';
  if (Platform.isIOS) return 'ios';
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  return 'unknown';
}

/// Current contract version identifier
const String currentContractVersion = 'v1.0';

/// Terms of Service content (Korean)
const String termsContent = '''
제1조 (목적)
본 약관은 CupPlus 서비스(이하 "서비스")의 이용과 관련하여 회사와 이용자 간의 권리, 의무 및 책임 사항, 기타 필요한 사항을 규정함을 목적으로 합니다.

제2조 (정의)
① "서비스"란 회사가 제공하는 결혼정보서비스 매니저 플랫폼을 의미합니다.
② "이용자"란 본 약관에 따라 회사가 제공하는 서비스를 받는 자를 의미합니다.

제3조 (약관의 효력 및 변경)
① 본 약관은 이용자가 서비스에 가입하고 동의함으로써 효력이 발생합니다.
② 회사는 합리적인 사유가 발생할 경우 약관을 변경할 수 있습니다.

제4조 (서비스의 제공)
회사는 다음과 같은 서비스를 제공합니다.
- 회원 프로필 관리
- 매칭 서비스 중개
- 매니저 간 커뮤니케이션

제5조 (이용자의 의무)
이용자는 서비스를 이용함에 있어 타인의 권리를 침해하거나 법적으로 금지된 행위를 해서는 안됩니다.
''';

/// Privacy Policy content (Korean)
const String privacyContent = '''
개인정보 수집 및 이용 동의

1. 수집하는 개인정보의 항목
- 필수: 이름, 성별, 생년월일, 직업, 종교, 키
- 선택: 연락처, 이메일, 학력, 회사명, 취미, 자기소개, 프로필 사진

2. 개인정보의 수집 및 이용목적
- 결혼정보서비스 매칭을 위한 회원 정보 관리
- 매니저 간 매칭 중개 서비스 제공

3. 개인정보의 보유 및 이용기간
- 회원 탈퇴 시까지 또는 법령에 따른 보존기간

4. 제3자 제공
- 수집된 개인정보는 동의 없이 제3자에게 제공되지 않습니다.
- 다만, 매칭 서비스 특성상 매칭 상대방 매니저에게 회원 프로필이 공유됩니다.

5. 동의 거부 권리
귀하는 위 개인정보 수집에 동의하지 않을 권리가 있으며, 미동의 시 회원 등록이 불가합니다.
''';

/// Marketing consent content (Korean)
const String marketingContent = '''
마케팅 정보 수신 동의 (선택)

CupPlus에서 제공하는 다음과 같은 마케팅 정보를 수신하시겠습니까?

- 신규 서비스 및 기능 안내
- 프로모션 및 이벤트 정보
- 매칭 팁 및 업계 뉴스레터

* 마케팅 정보 수신에 동의하지 않아도 기본 서비스 이용에 지장이 없습니다.
* 동의 후 언제든지 설정에서 수신을 거부할 수 있습니다.
''';
