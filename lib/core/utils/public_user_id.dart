/// Maps an internal auth user id (e.g. Supabase UUID) to a **fixed 14-digit**
/// numeric string for display. Same account always gets the same digits.
///
/// This is display-only; the real UUID remains in Supabase for APIs and RLS.
String publicUserId14(String rawUserId) {
  final trimmed = rawUserId.trim();
  if (trimmed.isEmpty) return '';

  final hex = trimmed.replaceAll('-', '');
  final hexOk = RegExp(r'^[0-9a-fA-F]{32}$');
  if (hexOk.hasMatch(hex)) {
    try {
      final big = BigInt.parse(hex, radix: 16);
      const modulus = 100000000000000; // 10^14
      final remainder = big % BigInt.from(modulus);
      return remainder.toString().padLeft(14, '0');
    } catch (_) {
      // fall through
    }
  }

  // Non-UUID ids: deterministic mix into 14 digits
  var h = BigInt.zero;
  for (var i = 0; i < trimmed.length; i++) {
    h = (h * BigInt.from(65599) + BigInt.from(trimmed.codeUnitAt(i))) %
        BigInt.from(100000000000000);
  }
  return h.toString().padLeft(14, '0');
}
