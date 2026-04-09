"use client";

const icons = {
  "01d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="32" cy="32" r="14" fill="#F5C842" opacity="0.9"/>
      <g stroke="#F5C842" strokeWidth="3" strokeLinecap="round">
        <line x1="32" y1="6" x2="32" y2="14"/>
        <line x1="32" y1="50" x2="32" y2="58"/>
        <line x1="6" y1="32" x2="14" y2="32"/>
        <line x1="50" y1="32" x2="58" y2="32"/>
        <line x1="13.1" y1="13.1" x2="18.8" y2="18.8"/>
        <line x1="45.2" y1="45.2" x2="50.9" y2="50.9"/>
        <line x1="50.9" y1="13.1" x2="45.2" y2="18.8"/>
        <line x1="18.8" y1="45.2" x2="13.1" y2="50.9"/>
      </g>
    </svg>
  ),
  "01n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M40 12C28 14 20 24 22 36C24 48 35 55 47 52C35 58 18 50 15 36C12 22 22 10 36 10C37.4 10 38.7 10.1 40 12Z" fill="#90CDF4"/>
    </svg>
  ),
  "02d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="22" cy="26" r="10" fill="#F5C842" opacity="0.9"/>
      <g stroke="#F5C842" strokeWidth="2" strokeLinecap="round" opacity="0.6">
        <line x1="22" y1="10" x2="22" y2="14"/>
        <line x1="8" y1="26" x2="12" y2="26"/>
        <line x1="11" y1="15" x2="14" y2="18"/>
        <line x1="33" y1="15" x2="30" y2="18"/>
      </g>
      <rect x="20" y="30" width="32" height="18" rx="9" fill="#CBD5E0"/>
      <ellipse cx="30" cy="30" rx="10" ry="10" fill="#E2E8F0"/>
      <ellipse cx="42" cy="32" rx="8" ry="8" fill="#EDF2F7"/>
    </svg>
  ),
  "02n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M28 10C20 12 15 20 17 28C18 32 21 35 25 37" stroke="#90CDF4" strokeWidth="2" fill="none"/>
      <rect x="20" y="30" width="32" height="18" rx="9" fill="#718096"/>
      <ellipse cx="30" cy="30" rx="10" ry="10" fill="#A0AEC0"/>
      <ellipse cx="42" cy="32" rx="8" ry="8" fill="#CBD5E0"/>
    </svg>
  ),
  "03d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="28" width="40" height="20" rx="10" fill="#CBD5E0"/>
      <ellipse cx="26" cy="28" rx="13" ry="13" fill="#E2E8F0"/>
      <ellipse cx="40" cy="30" rx="11" ry="11" fill="#EDF2F7"/>
    </svg>
  ),
  "03n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="28" width="40" height="20" rx="10" fill="#718096"/>
      <ellipse cx="26" cy="28" rx="13" ry="13" fill="#A0AEC0"/>
      <ellipse cx="40" cy="30" rx="11" ry="11" fill="#CBD5E0"/>
    </svg>
  ),
  "04d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="8" y="32" width="36" height="18" rx="9" fill="#A0AEC0"/>
      <ellipse cx="22" cy="32" rx="11" ry="11" fill="#CBD5E0"/>
      <ellipse cx="34" cy="34" rx="9" ry="9" fill="#E2E8F0"/>
      <rect x="20" y="26" width="36" height="18" rx="9" fill="#718096"/>
      <ellipse cx="34" cy="26" rx="11" ry="11" fill="#A0AEC0"/>
      <ellipse cx="46" cy="28" rx="9" ry="9" fill="#CBD5E0"/>
    </svg>
  ),
  "04n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="8" y="32" width="36" height="18" rx="9" fill="#4A5568"/>
      <ellipse cx="22" cy="32" rx="11" ry="11" fill="#718096"/>
      <rect x="20" y="26" width="36" height="18" rx="9" fill="#2D3748"/>
      <ellipse cx="34" cy="26" rx="11" ry="11" fill="#4A5568"/>
    </svg>
  ),
  "09d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="14" width="40" height="20" rx="10" fill="#718096"/>
      <ellipse cx="26" cy="14" rx="13" ry="13" fill="#A0AEC0"/>
      <ellipse cx="40" cy="16" rx="11" ry="11" fill="#CBD5E0"/>
      <g stroke="#63B3ED" strokeWidth="2.5" strokeLinecap="round">
        <line x1="22" y1="40" x2="20" y2="50"/>
        <line x1="30" y1="40" x2="28" y2="52"/>
        <line x1="38" y1="40" x2="36" y2="50"/>
        <line x1="46" y1="40" x2="44" y2="52"/>
      </g>
    </svg>
  ),
  "09n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="14" width="40" height="20" rx="10" fill="#4A5568"/>
      <ellipse cx="26" cy="14" rx="13" ry="13" fill="#718096"/>
      <g stroke="#63B3ED" strokeWidth="2.5" strokeLinecap="round">
        <line x1="22" y1="40" x2="20" y2="50"/>
        <line x1="30" y1="40" x2="28" y2="52"/>
        <line x1="38" y1="40" x2="36" y2="50"/>
        <line x1="46" y1="40" x2="44" y2="52"/>
      </g>
    </svg>
  ),
  "10d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <circle cx="18" cy="20" r="8" fill="#F5C842" opacity="0.7"/>
      <rect x="16" y="18" width="36" height="18" rx="9" fill="#718096"/>
      <ellipse cx="28" cy="18" rx="11" ry="11" fill="#A0AEC0"/>
      <g stroke="#63B3ED" strokeWidth="2.5" strokeLinecap="round">
        <line x1="24" y1="42" x2="22" y2="52"/>
        <line x1="32" y1="42" x2="30" y2="54"/>
        <line x1="40" y1="42" x2="38" y2="52"/>
      </g>
    </svg>
  ),
  "10n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="14" width="40" height="20" rx="10" fill="#4A5568"/>
      <ellipse cx="26" cy="14" rx="13" ry="13" fill="#718096"/>
      <g stroke="#63B3ED" strokeWidth="2.5" strokeLinecap="round">
        <line x1="24" y1="40" x2="22" y2="50"/>
        <line x1="32" y1="40" x2="30" y2="52"/>
        <line x1="40" y1="40" x2="38" y2="50"/>
      </g>
    </svg>
  ),
  "11d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="8" y="10" width="48" height="22" rx="11" fill="#4A5568"/>
      <ellipse cx="24" cy="10" rx="14" ry="14" fill="#718096"/>
      <ellipse cx="40" cy="12" rx="12" ry="12" fill="#A0AEC0"/>
      <g stroke="#4299E1" strokeWidth="2" strokeLinecap="round">
        <line x1="20" y1="36" x2="18" y2="44"/>
        <line x1="36" y1="36" x2="34" y2="44"/>
      </g>
      <polyline points="28,36 24,46 30,46 26,56" stroke="#F5C842" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
    </svg>
  ),
  "11n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="8" y="10" width="48" height="22" rx="11" fill="#2D3748"/>
      <ellipse cx="24" cy="10" rx="14" ry="14" fill="#4A5568"/>
      <g stroke="#4299E1" strokeWidth="2" strokeLinecap="round">
        <line x1="20" y1="36" x2="18" y2="44"/>
        <line x1="36" y1="36" x2="34" y2="44"/>
      </g>
      <polyline points="28,36 24,46 30,46 26,56" stroke="#F5C842" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" fill="none"/>
    </svg>
  ),
  "13d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="14" width="40" height="20" rx="10" fill="#CBD5E0"/>
      <ellipse cx="26" cy="14" rx="13" ry="13" fill="#E2E8F0"/>
      <g fill="#BEE3F8">
        <circle cx="22" cy="42" r="3"/>
        <circle cx="32" cy="46" r="3"/>
        <circle cx="42" cy="42" r="3"/>
        <circle cx="27" cy="52" r="3"/>
        <circle cx="37" cy="52" r="3"/>
      </g>
    </svg>
  ),
  "13n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="12" y="14" width="40" height="20" rx="10" fill="#718096"/>
      <ellipse cx="26" cy="14" rx="13" ry="13" fill="#A0AEC0"/>
      <g fill="#BEE3F8">
        <circle cx="22" cy="42" r="3"/>
        <circle cx="32" cy="46" r="3"/>
        <circle cx="42" cy="42" r="3"/>
        <circle cx="27" cy="52" r="3"/>
        <circle cx="37" cy="52" r="3"/>
      </g>
    </svg>
  ),
  "50d": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g stroke="#A0AEC0" strokeWidth="2.5" strokeLinecap="round" opacity="0.8">
        <line x1="10" y1="22" x2="54" y2="22"/>
        <line x1="14" y1="30" x2="50" y2="30"/>
        <line x1="10" y1="38" x2="54" y2="38"/>
        <line x1="14" y1="46" x2="50" y2="46"/>
      </g>
    </svg>
  ),
  "50n": (
    <svg viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <g stroke="#718096" strokeWidth="2.5" strokeLinecap="round" opacity="0.8">
        <line x1="10" y1="22" x2="54" y2="22"/>
        <line x1="14" y1="30" x2="50" y2="30"/>
        <line x1="10" y1="38" x2="54" y2="38"/>
        <line x1="14" y1="46" x2="50" y2="46"/>
      </g>
    </svg>
  ),
};

export default function WeatherIcon({ code, size = 48, className = "" }) {
  const icon = icons[code] || icons["03d"];
  return (
    <span
      className={className}
      style={{ display: "inline-flex", width: size, height: size, flexShrink: 0 }}
    >
      {icon}
    </span>
  );
}