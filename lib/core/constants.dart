import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Supabase ──────────────────────────────────────────
const String supabaseUrl = 'https://ofadiqbebzmrjyxzoxym.supabase.co';
const String supabaseAnon = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_pJNeyKRY0TPGFQq3606wtQ_3A3MhoCw',
);
const String supabaseServiceRole = String.fromEnvironment(
  'SUPABASE_SERVICE_ROLE_KEY',
  defaultValue: '',
);

const String kSupabaseUrl = supabaseUrl;
const String kSupabaseAnonKey = supabaseAnon;
const String kSupabaseServiceRoleKey = supabaseServiceRole;

// Mapbox token - use --dart-define MAPBOX_TOKEN=<token> when running
const String mapboxToken = String.fromEnvironment(
  'MAPBOX_TOKEN',
  defaultValue: '',
);

// Colors
const kBg = Color(0xFFF4F5F6);
const kSurface = Colors.white;
const kCyan = Color(0xFF2563EB);
const kCyan2 = Color(0xFF1D4ED8);
const kCyan3 = Color(0xFF1E40AF);
const kMint = Color(0xFF3B82F6);
const kMint2 = Color(0xFF2563EB);
const kRed = Color(0xFFFF4D6D);
const kOrange = Color(0xFFFF8C42);
const kYellow = Color(0xFFFFD700);
const kText = Color(0xFF0D0D12);
const kText2 = Color(0xFF3A4A5C);
const kMuted = Color(0xFF8FA3B8);
const kBorder = Color(0xFFE8EDF2);
const kBorder2 = Color(0xFFD4DDE6);

// Radii
const double rSm = 10;
const double rMd = 14;
const double rLg = 20;
const double rXl = 28;

// Shadows
const shadowXs = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 3, offset: Offset(0, 1)),
];
const shadowSm = [
  BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
];
const shadowMd = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 20, offset: Offset(0, 4)),
];
const shadowLg = [
  BoxShadow(color: Color(0x1F000000), blurRadius: 40, offset: Offset(0, 8)),
];

TextStyle headStyle({
  double size = 14,
  FontWeight weight = FontWeight.w800,
  Color? color,
}) =>
    GoogleFonts.nunito(
      fontSize: size,
      fontWeight: weight,
      color: color ?? kText,
    );

TextStyle bodyStyle({
  double size = 13,
  FontWeight weight = FontWeight.w400,
  Color? color,
}) =>
    GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? kText,
    );

// Font families
const String kFontHead = 'Nunito';
const String kFontBody = 'DMSans';

// Hub location
const double kHubLat = 41.9024;
const double kHubLng = 12.5143;
const double kDefaultLat = 41.8988;
const double kDefaultLng = 12.4768;

// Rome location
const double kRomeLat = 41.9024;
const double kRomeLng = 12.5143;

// API endpoints
const String osrmBase = 'https://router.project-osrm.org/route/v1/driving';
const String nominatimBase = 'https://nominatim.openstreetmap.org/reverse';
