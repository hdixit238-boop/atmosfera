# Save this as fix.ps1 in D:\weather-app
# Run: powershell -ExecutionPolicy Bypass -File fix.ps1

Write-Host "Fixing all files..." -ForegroundColor Cyan

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# ── lib/weather.js ────────────────────────────────────────────────────────────
$weather = @'
const API_KEY = process.env.NEXT_PUBLIC_WEATHER_API_KEY;
const BASE = "https://api.openweathermap.org/data/2.5";
const GEO  = "http://api.openweathermap.org/geo/1.0";

export async function fetchWeather(city) {
  const r = await fetch(`${BASE}/weather?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`);
  if (!r.ok) throw new Error("City not found");
  return r.json();
}
export async function fetchWeatherByCoords(lat, lon) {
  const r = await fetch(`${BASE}/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`);
  if (!r.ok) throw new Error("Location not found");
  return r.json();
}
export async function fetchForecast(city) {
  const r = await fetch(`${BASE}/forecast?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`);
  if (!r.ok) throw new Error("Forecast unavailable");
  return r.json();
}
export async function fetchForecastByCoords(lat, lon) {
  const r = await fetch(`${BASE}/forecast?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`);
  if (!r.ok) throw new Error("Forecast unavailable");
  return r.json();
}
export async function searchCities(query) {
  const r = await fetch(`${GEO}/direct?q=${encodeURIComponent(query)}&limit=5&appid=${API_KEY}`);
  if (!r.ok) return [];
  return r.json();
}
export function getWeatherTheme(id) {
  if (id >= 200 && id < 300) return "storm";
  if (id >= 300 && id < 400) return "drizzle";
  if (id >= 500 && id < 600) return "rain";
  if (id >= 600 && id < 700) return "snow";
  if (id >= 700 && id < 800) return "fog";
  if (id === 800) return "clear";
  return "clouds";
}
export function getDailyForecast(list) {
  const days = {};
  list.forEach(item => {
    const date = item.dt_txt.split(" ")[0];
    if (!days[date]) days[date] = [];
    days[date].push(item);
  });
  return Object.entries(days).slice(0, 5).map(([date, items]) => {
    const temps = items.map(i => i.main.temp);
    const mid = items[Math.floor(items.length / 2)];
    return { date, min: Math.round(Math.min(...temps)), max: Math.round(Math.max(...temps)), weather: mid.weather[0] };
  });
}
export function getHourlyForecast(list) {
  return list.slice(0, 8).map(item => ({
    time: item.dt_txt.split(" ")[1].slice(0, 5),
    temp: Math.round(item.main.temp),
    weather: item.weather[0],
    pop: Math.round((item.pop || 0) * 100),
  }));
}
export function getWindDirection(deg) {
  return ["N","NE","E","SE","S","SW","W","NW"][Math.round(deg / 45) % 8];
}
export function formatSunTime(unix) {
  return new Date(unix * 1000).toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true });
}
export function getWeatherLabel(id) {
  if (id >= 200 && id < 300) return "Thunderstorm";
  if (id >= 300 && id < 400) return "Drizzle";
  if (id >= 500 && id < 600) return "Rain";
  if (id >= 600 && id < 700) return "Snow";
  if (id >= 700 && id < 800) return "Fog";
  if (id === 800) return "Clear";
  if (id === 801) return "Few Clouds";
  if (id === 802) return "Scattered";
  return "Cloudy";
}
'@
[System.IO.File]::WriteAllText("$PWD\lib\weather.js", $weather, $utf8NoBom)
Write-Host "Fixed: weather.js" -ForegroundColor Green

# ── components/WeatherIcon.jsx ─────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "components" | Out-Null
$weatherIcon = @'
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
'@
[System.IO.File]::WriteAllText("$PWD\components\WeatherIcon.jsx", $weatherIcon, $utf8NoBom)
Write-Host "Created: WeatherIcon.jsx" -ForegroundColor Green

# ── components/MainCard.jsx ───────────────────────────────────────────────────
$mainCard = @'
"use client";
import { formatSunTime, getWindDirection } from "@/lib/weather";
import WeatherIcon from "./WeatherIcon";
import styles from "./MainCard.module.css";

function StatIcon({ type }) {
  const icons = {
    temp: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M14 14.76V3.5a2.5 2.5 0 0 0-5 0v11.26a4.5 4.5 0 1 0 5 0z"/></svg>,
    drop: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/></svg>,
    wind: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9.59 4.59A2 2 0 1 1 11 8H2m10.59 11.41A2 2 0 1 0 14 16H2m15.73-8.27A2.5 2.5 0 1 1 19.5 12H2"/></svg>,
    gauge: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 2a10 10 0 1 0 10 10"/><path d="M12 6v6l4 2"/></svg>,
    sunrise: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M17 18a5 5 0 0 0-10 0"/><line x1="12" y1="2" x2="12" y2="9"/><line x1="4.22" y1="10.22" x2="5.64" y2="11.64"/><line x1="1" y1="18" x2="3" y2="18"/><line x1="21" y1="18" x2="23" y2="18"/><line x1="18.36" y1="11.64" x2="19.78" y2="10.22"/><line x1="23" y1="22" x2="1" y2="22"/><polyline points="8 6 12 2 16 6"/></svg>,
    sunset: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M17 18a5 5 0 0 0-10 0"/><line x1="12" y1="9" x2="12" y2="2"/><line x1="4.22" y1="10.22" x2="5.64" y2="11.64"/><line x1="1" y1="18" x2="3" y2="18"/><line x1="21" y1="18" x2="23" y2="18"/><line x1="18.36" y1="11.64" x2="19.78" y2="10.22"/><line x1="23" y1="22" x2="1" y2="22"/><polyline points="16 5 12 9 8 5"/></svg>,
    eye: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>,
    cloud: <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>,
  };
  return <span style={{ color: "rgba(240,244,255,0.45)", display: "flex" }}>{icons[type]}</span>;
}

function Stat({ label, value, iconType }) {
  return (
    <div className={styles.stat}>
      <StatIcon type={iconType} />
      <div>
        <div className={styles.statLabel}>{label}</div>
        <div className={styles.statValue}>{value}</div>
      </div>
    </div>
  );
}

export default function MainCard({ data }) {
  const temp = Math.round(data.main.temp);
  const high = Math.round(data.main.temp_max);
  const low = Math.round(data.main.temp_min);
  const feelsLike = Math.round(data.main.feels_like);
  const now = new Date();
  return (
    <div className={styles.card}>
      <div className={styles.header}>
        <div>
          <div className={styles.location}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            {data.name}, {data.sys.country}
          </div>
          <div className={styles.date}>{now.toLocaleDateString("en-US", { weekday: "long", month: "long", day: "numeric" })}</div>
        </div>
        <div className={styles.time}>{now.toLocaleTimeString("en-US", { hour: "2-digit", minute: "2-digit", hour12: true })}</div>
      </div>
      <div className={styles.main}>
        <WeatherIcon code={data.weather[0].icon} size={96} />
        <div className={styles.tempBlock}>
          <div className={styles.temp}>{temp}&deg;</div>
          <div className={styles.desc}>{data.weather[0].description}</div>
          <div className={styles.hiLo}>
            <span>&uarr; {high}&deg;</span>
            <span className={styles.slash}>/</span>
            <span>&darr; {low}&deg;</span>
          </div>
        </div>
      </div>
      <div className={styles.stats}>
        <Stat label="Feels like" value={`${feelsLike}\u00B0`} iconType="temp" />
        <Stat label="Humidity" value={`${data.main.humidity}%`} iconType="drop" />
        <Stat label="Wind" value={`${Math.round(data.wind.speed)} m/s ${getWindDirection(data.wind.deg)}`} iconType="wind" />
        <Stat label="Pressure" value={`${data.main.pressure} hPa`} iconType="gauge" />
        <Stat label="Sunrise" value={formatSunTime(data.sys.sunrise)} iconType="sunrise" />
        <Stat label="Sunset" value={formatSunTime(data.sys.sunset)} iconType="sunset" />
        <Stat label="Visibility" value={`${(data.visibility / 1000).toFixed(1)} km`} iconType="eye" />
        <Stat label="Clouds" value={`${data.clouds.all}%`} iconType="cloud" />
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\components\MainCard.jsx", $mainCard, $utf8NoBom)
Write-Host "Fixed: MainCard.jsx" -ForegroundColor Green

# ── components/HourlyForecast.jsx ─────────────────────────────────────────────
$hourly = @'
"use client";
import WeatherIcon from "./WeatherIcon";
import styles from "./HourlyForecast.module.css";

export default function HourlyForecast({ hours }) {
  const maxTemp = Math.max(...hours.map(h => h.temp));
  const minTemp = Math.min(...hours.map(h => h.temp));
  return (
    <div className={styles.card}>
      <div className={styles.title}>Hourly Forecast</div>
      <div className={styles.scroll}>
        {hours.map((h, i) => {
          const pct = maxTemp === minTemp ? 50 : ((h.temp - minTemp) / (maxTemp - minTemp)) * 100;
          return (
            <div key={i} className={styles.item} style={{ animationDelay: `${i * 0.06}s` }}>
              <div className={styles.time}>{i === 0 ? "Now" : h.time}</div>
              {h.pop > 0 && <div className={styles.pop}>{h.pop}%</div>}
              <WeatherIcon code={h.weather.icon} size={32} />
              <div className={styles.bar}>
                <div className={styles.barFill} style={{ height: `${pct}%` }} />
              </div>
              <div className={styles.temp}>{h.temp}&deg;</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\components\HourlyForecast.jsx", $hourly, $utf8NoBom)
Write-Host "Fixed: HourlyForecast.jsx" -ForegroundColor Green

# ── components/DailyForecast.jsx ──────────────────────────────────────────────
$daily = @'
"use client";
import WeatherIcon from "./WeatherIcon";
import styles from "./DailyForecast.module.css";

export default function DailyForecast({ days }) {
  const all = days.flatMap(d => [d.min, d.max]);
  const absMin = Math.min(...all);
  const absMax = Math.max(...all);
  return (
    <div className={styles.card}>
      <div className={styles.title}>5-Day Forecast</div>
      <div className={styles.list}>
        {days.map((day, i) => {
          const date = new Date(day.date);
          const label = i === 0 ? "Today" : date.toLocaleDateString("en-US", { weekday: "short" });
          const minPct = absMax === absMin ? 0 : ((day.min - absMin) / (absMax - absMin)) * 100;
          const maxPct = absMax === absMin ? 100 : ((day.max - absMin) / (absMax - absMin)) * 100;
          return (
            <div key={i} className={styles.row} style={{ animationDelay: `${i * 0.08}s` }}>
              <span className={styles.day}>{label}</span>
              <WeatherIcon code={day.weather.icon} size={28} />
              <span className={styles.desc}>{day.weather.description}</span>
              <div className={styles.range}>
                <span className={styles.low}>{day.min}&deg;</span>
                <div className={styles.bar}>
                  <div className={styles.fill} style={{ left: `${minPct}%`, width: `${maxPct - minPct}%` }} />
                </div>
                <span className={styles.high}>{day.max}&deg;</span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\components\DailyForecast.jsx", $daily, $utf8NoBom)
Write-Host "Fixed: DailyForecast.jsx" -ForegroundColor Green

# ── components/AirQuality.jsx ─────────────────────────────────────────────────
$air = @'
"use client";
import styles from "./AirQuality.module.css";

function AirIcon({ type }) {
  const s = { color: "rgba(240,244,255,0.45)", display: "flex" };
  const icons = {
    dew: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/></svg>,
    drop: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 2.69l5.66 5.66a8 8 0 1 1-11.31 0z"/></svg>,
    gauge: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>,
    eye: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>,
    cloud: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M18 10h-1.26A8 8 0 1 0 9 20h9a5 5 0 0 0 0-10z"/></svg>,
    wind: <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M9.59 4.59A2 2 0 1 1 11 8H2m10.59 11.41A2 2 0 1 0 14 16H2"/></svg>,
  };
  return <span style={s}>{icons[type]}</span>;
}

export default function AirQuality({ data }) {
  const h = data.main.humidity;
  const dew = Math.round(data.main.temp - ((100 - h) / 5));
  const vis = (data.visibility / 1000).toFixed(1);
  const stats = [
    { label: "Dew Point", value: `${dew}\u00B0C`, iconType: "dew", color: "#68d391" },
    { label: "Humidity", value: `${h}%`, iconType: "drop", bar: h, color: "#63b3ed" },
    { label: "Pressure", value: `${data.main.pressure} hPa`, iconType: "gauge", color: "#b794f4" },
    { label: "Visibility", value: `${vis} km`, iconType: "eye", bar: Math.min((parseFloat(vis) / 10) * 100, 100), color: "#f5c842" },
    { label: "Cloud Cover", value: `${data.clouds.all}%`, iconType: "cloud", bar: data.clouds.all, color: "#90cdf4" },
    { label: "Wind Gust", value: data.wind.gust ? `${Math.round(data.wind.gust)} m/s` : "N/A", iconType: "wind", color: "#fc8181" },
  ];
  return (
    <div className={styles.card}>
      <div className={styles.title}>Atmosphere</div>
      <div className={styles.grid}>
        {stats.map((s, i) => (
          <div key={i} className={styles.item}>
            <div className={styles.top}><AirIcon type={s.iconType} /><span className={styles.label}>{s.label}</span></div>
            <div className={styles.value} style={{ color: s.color }}>{s.value}</div>
            {s.bar !== undefined && (
              <div className={styles.barWrap}>
                <div className={styles.barFill} style={{ width: `${s.bar}%`, background: s.color }} />
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\components\AirQuality.jsx", $air, $utf8NoBom)
Write-Host "Fixed: AirQuality.jsx" -ForegroundColor Green

# ── components/FavoriteCities.jsx ─────────────────────────────────────────────
$fav = @'
"use client";
import { useState, useEffect } from "react";
import { fetchWeather } from "@/lib/weather";
import WeatherIcon from "./WeatherIcon";
import styles from "./FavoriteCities.module.css";

const CITIES = ["New York", "London", "Tokyo", "Dubai"];

export default function FavoriteCities({ onSelect, currentCity }) {
  const [cities, setCities] = useState([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    Promise.all(
      CITIES.map(async city => {
        try {
          const d = await fetchWeather(city);
          return { name: city, temp: Math.round(d.main.temp), icon: d.weather[0].icon, desc: d.weather[0].main };
        } catch { return null; }
      })
    ).then(res => { setCities(res.filter(Boolean)); setLoading(false); });
  }, []);

  if (loading) return (
    <div className={styles.card}>
      <div className={styles.title}>World Cities</div>
      <div className={styles.loading}>{[1,2,3,4].map(i => <div key={i} className={styles.skeleton} />)}</div>
    </div>
  );

  return (
    <div className={styles.card}>
      <div className={styles.title}>World Cities</div>
      <div className={styles.list}>
        {cities.map((c, i) => (
          <button key={i} className={`${styles.city} ${currentCity === c.name ? styles.active : ""}`} onClick={() => onSelect(c.name)}>
            <WeatherIcon code={c.icon} size={28} />
            <span className={styles.cityName}>{c.name}</span>
            <span className={styles.cityDesc}>{c.desc}</span>
            <span className={styles.cityTemp}>{c.temp}&deg;</span>
          </button>
        ))}
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\components\FavoriteCities.jsx", $fav, $utf8NoBom)
Write-Host "Fixed: FavoriteCities.jsx" -ForegroundColor Green

# ── components/SunriseSunset.jsx ──────────────────────────────────────────────
$sun = @'
"use client";
import { formatSunTime } from "@/lib/weather";
import styles from "./SunriseSunset.module.css";

export default function SunriseSunset({ data }) {
  const sunrise = data.sys.sunrise, sunset = data.sys.sunset;
  const now = Math.floor(Date.now() / 1000);
  const dayLength = sunset - sunrise;
  const elapsed = Math.max(0, Math.min(now - sunrise, dayLength));
  const progress = (elapsed / dayLength) * 100;
  const isDay = now >= sunrise && now <= sunset;
  const angle = (progress / 100) * 180;
  const rad = (angle * Math.PI) / 180;
  const cx = 50 + 40 * Math.cos(Math.PI - rad);
  const cy = 50 - 40 * Math.sin(Math.PI - rad);
  const dayH = Math.floor(dayLength / 3600), dayM = Math.floor((dayLength % 3600) / 60);
  return (
    <div className={styles.card}>
      <div className={styles.title}>Sun & Moon</div>
      <svg viewBox="0 0 100 60" className={styles.svg}>
        <path d="M 10 50 A 40 40 0 0 1 90 50" fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="2" strokeLinecap="round"/>
        <path d="M 10 50 A 40 40 0 0 1 90 50" fill="none" stroke="url(#sg)" strokeWidth="2" strokeLinecap="round" strokeDasharray="125.6" strokeDashoffset={125.6 - (progress / 100) * 125.6}/>
        <defs><linearGradient id="sg" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#f5c842"/><stop offset="100%" stopColor="#fc8181"/></linearGradient></defs>
        <line x1="6" y1="50" x2="94" y2="50" stroke="rgba(255,255,255,0.1)" strokeWidth="1"/>
        {isDay && <g><circle cx={cx} cy={cy} r="5" fill="#f5c842" opacity="0.2"/><circle cx={cx} cy={cy} r="3" fill="#f5c842"/></g>}
      </svg>
      <div className={styles.labels}>
        <div className={styles.sunTime}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#f5c842" strokeWidth="2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
          <div><div className={styles.sunLabel}>Sunrise</div><div className={styles.sunValue}>{formatSunTime(sunrise)}</div></div>
        </div>
        <div className={styles.dayLength}>
          <div className={styles.dayLabel}>Day length</div>
          <div className={styles.dayValue}>{dayH}h {dayM}m</div>
        </div>
        <div className={styles.sunTime}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fc8181" strokeWidth="2"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
          <div><div className={styles.sunLabel}>Sunset</div><div className={styles.sunValue}>{formatSunTime(sunset)}</div></div>
        </div>
      </div>
      <div className={styles.progressWrap}>
        <div className={styles.progressBar}><div className={styles.progressFill} style={{ width: `${Math.max(0, Math.min(progress, 100))}%` }}/></div>
        <div className={styles.progressPct}>{Math.round(progress)}% of day elapsed</div>
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\components\SunriseSunset.jsx", $sun, $utf8NoBom)
Write-Host "Fixed: SunriseSunset.jsx" -ForegroundColor Green

# ── app/page.jsx ── update logo icon to SVG ───────────────────────────────────
$page = @'
"use client";
import { useState, useEffect, useCallback } from "react";
import { fetchWeather, fetchWeatherByCoords, fetchForecast, fetchForecastByCoords, getWeatherTheme, getDailyForecast, getHourlyForecast } from "@/lib/weather";
import WeatherBackground from "@/components/WeatherBackground";
import SearchBar from "@/components/SearchBar";
import MainCard from "@/components/MainCard";
import HourlyForecast from "@/components/HourlyForecast";
import DailyForecast from "@/components/DailyForecast";
import AirQuality from "@/components/AirQuality";
import SunriseSunset from "@/components/SunriseSunset";
import WindCompass from "@/components/WindCompass";
import FavoriteCities from "@/components/FavoriteCities";
import styles from "./page.module.css";

function c2f(c) { return Math.round((c * 9) / 5 + 32); }
function convertToF(w) {
  return { ...w, main: { ...w.main, temp: c2f(w.main.temp), feels_like: c2f(w.main.feels_like), temp_min: c2f(w.main.temp_min), temp_max: c2f(w.main.temp_max) } };
}

export default function Home() {
  const [weather, setWeather] = useState(null);
  const [forecast, setForecast] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [theme, setTheme] = useState("clear");
  const [currentCity, setCurrentCity] = useState("");
  const [unit, setUnit] = useState("C");

  const loadWeather = useCallback(async (city) => {
    setLoading(true); setError(null);
    try {
      const [w, f] = await Promise.all([fetchWeather(city), fetchForecast(city)]);
      setWeather(w); setForecast(f);
      setTheme(getWeatherTheme(w.weather[0].id));
      setCurrentCity(city);
    } catch (e) { setError(e.message || "Could not load weather"); }
    finally { setLoading(false); }
  }, []);

  const loadByLocation = useCallback(() => {
    if (!navigator.geolocation) { setError("Geolocation not supported"); return; }
    setLoading(true); setError(null);
    navigator.geolocation.getCurrentPosition(async ({ coords }) => {
      try {
        const [w, f] = await Promise.all([fetchWeatherByCoords(coords.latitude, coords.longitude), fetchForecastByCoords(coords.latitude, coords.longitude)]);
        setWeather(w); setForecast(f);
        setTheme(getWeatherTheme(w.weather[0].id));
        setCurrentCity(w.name);
      } catch (e) { setError(e.message); }
      finally { setLoading(false); }
    }, () => { setError("Location access denied"); setLoading(false); });
  }, []);

  useEffect(() => { loadWeather("Pune"); }, [loadWeather]);

  const hourly = forecast ? getHourlyForecast(forecast.list) : [];
  const daily  = forecast ? getDailyForecast(forecast.list)  : [];
  const displayWeather = weather && unit === "F" ? convertToF(weather) : weather;

  return (
    <div className={styles.page}>
      <WeatherBackground theme={theme} />
      <div className={styles.content}>
        <header className={styles.header}>
          <div className={styles.logo}>
            <svg width="28" height="28" viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
              <circle cx="22" cy="24" r="10" fill="#F5C842" opacity="0.9"/>
              <rect x="18" y="28" width="34" height="18" rx="9" fill="rgba(255,255,255,0.25)"/>
              <ellipse cx="30" cy="28" rx="11" ry="11" fill="rgba(255,255,255,0.35)"/>
              <ellipse cx="43" cy="30" rx="9" ry="9" fill="rgba(255,255,255,0.2)"/>
            </svg>
            <span className={styles.logoText}>Aether</span>
          </div>
          <SearchBar onSearch={loadWeather} onLocationClick={loadByLocation} />
          <div className={styles.unitToggle}>
            <button className={`${styles.unitBtn} ${unit === "C" ? styles.unitActive : ""}`} onClick={() => setUnit("C")}>&deg;C</button>
            <button className={`${styles.unitBtn} ${unit === "F" ? styles.unitActive : ""}`} onClick={() => setUnit("F")}>&deg;F</button>
          </div>
        </header>
        {error && <div className={styles.error}><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg> {error}</div>}
        {loading && (
          <div className={styles.skeleton}>
            <div className={styles.skeletonMain} />
            <div className={styles.skeletonRow}>
              <div className={styles.skeletonCard} />
              <div className={styles.skeletonCard} />
            </div>
          </div>
        )}
        {!loading && displayWeather && (
          <div className={styles.grid}>
            <div className={styles.col}>
              <MainCard data={displayWeather} />
              <HourlyForecast hours={hourly} />
              <DailyForecast days={daily} />
            </div>
            <div className={styles.sidebar}>
              <FavoriteCities onSelect={loadWeather} currentCity={currentCity} />
              <AirQuality data={displayWeather} />
              <WindCompass data={displayWeather} />
              <SunriseSunset data={displayWeather} />
            </div>
          </div>
        )}
        <footer className={styles.footer}>
          Powered by <a href="https://openweathermap.org" target="_blank" rel="noopener noreferrer">OpenWeatherMap</a> &middot; Built with Next.js
        </footer>
      </div>
    </div>
  );
}
'@
[System.IO.File]::WriteAllText("$PWD\app\page.jsx", $page, $utf8NoBom)
Write-Host "Fixed: page.jsx" -ForegroundColor Green

Write-Host ""
Write-Host "All done! Now restart your dev server:" -ForegroundColor Cyan
Write-Host "  Press Ctrl+C to stop it, then run: npm run dev" -ForegroundColor Yellow