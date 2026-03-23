/// Max size for user-uploaded profile photos (email / phone + password users).
/// Not applied to Google avatars (loaded by URL from Google via Supabase session).
const int kMaxLocalProfilePhotoBytes = 1024 * 1024; // 1 MB
