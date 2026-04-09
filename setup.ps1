# Run this script in D:\weather-app
# Right-click PowerShell -> Run as Administrator if needed
# Command: powershell -ExecutionPolicy Bypass -File setup.ps1

Write-Host "Creating Aether Weather App..." -ForegroundColor Cyan

# Create folders
New-Item -ItemType Directory -Force -Path "app" | Out-Null
New-Item -ItemType Directory -Force -Path "components" | Out-Null
New-Item -ItemType Directory -Force -Path "lib" | Out-Null

# ── package.json ──────────────────────────────────────────────────────────────
@'
{
  "name": "weather-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.2.3",
    "react": "^18",
    "react-dom": "^18",
    "lucide-react": "^0.383.0",
    "date-fns": "^3.6.0"
  },
  "devDependencies": {
    "eslint": "^8",
    "eslint-config-next": "14.2.3"
  }
}
'@ | Set-Content "package.json" -Encoding UTF8

# ── next.config.js ────────────────────────────────────────────────────────────
@'
/** @type {import("next").NextConfig} */
const nextConfig = {
  images: {
    remotePatterns: [{ protocol: "https", hostname: "openweathermap.org" }],
  },
};
module.exports = nextConfig;
'@ | Set-Content "next.config.js" -Encoding UTF8

# ── .env.local ────────────────────────────────────────────────────────────────
@'
NEXT_PUBLIC_WEATHER_API_KEY=PASTE_YOUR_KEY_HERE
'@ | Set-Content ".env.local" -Encoding UTF8

# ── lib/weather.js ────────────────────────────────────────────────────────────
@'
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
'@ | Set-Content "lib\weather.js" -Encoding UTF8

# ── app/globals.css ───────────────────────────────────────────────────────────
@'
@import url("https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;700;900&family=DM+Sans:wght@300;400;500;600&family=DM+Mono:wght@400;500&display=swap");
:root {
  --sky-deep: #0a0e1a;
  --sky-card: rgba(26,34,53,0.7);
  --gold: #f5c842;
  --blue-bright: #63b3ed;
  --coral: #fc8181;
  --mint: #68d391;
  --lavender: #b794f4;
  --text-primary: #f0f4ff;
  --text-secondary: rgba(240,244,255,0.6);
  --text-muted: rgba(240,244,255,0.35);
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body {
  font-family: "DM Sans", sans-serif;
  background: var(--sky-deep);
  color: var(--text-primary);
  min-height: 100vh;
  overflow-x: hidden;
  -webkit-font-smoothing: antialiased;
}
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-track { background: var(--sky-deep); }
::-webkit-scrollbar-thumb { background: rgba(99,179,237,0.3); border-radius: 3px; }
::selection { background: rgba(99,179,237,0.25); color: var(--text-primary); }
'@ | Set-Content "app\globals.css" -Encoding UTF8

# ── app/layout.jsx ────────────────────────────────────────────────────────────
@'
import "./globals.css";
export const metadata = { title: "Aether Weather", description: "Beautiful real-time weather app" };
export default function RootLayout({ children }) {
  return <html lang="en"><body>{children}</body></html>;
}
'@ | Set-Content "app\layout.jsx" -Encoding UTF8

# ── app/page.module.css ───────────────────────────────────────────────────────
@'
.page { min-height: 100vh; position: relative; }
.content {
  position: relative; z-index: 1;
  max-width: 1280px; margin: 0 auto;
  padding: 24px 24px 40px;
  min-height: 100vh; display: flex; flex-direction: column;
}
.header { display: flex; align-items: center; gap: 20px; margin-bottom: 32px; flex-wrap: wrap; }
.logo { display: flex; align-items: center; gap: 10px; flex-shrink: 0; }
.logoIcon { font-size: 26px; }
.logoText { font-family: "Playfair Display", serif; font-size: 22px; font-weight: 700; color: #f0f4ff; letter-spacing: -0.5px; }
.unitToggle { display: flex; gap: 4px; background: rgba(255,255,255,0.05); border: 1px solid rgba(255,255,255,0.08); border-radius: 50px; padding: 4px; flex-shrink: 0; }
.unitBtn { background: none; border: none; cursor: pointer; font-family: "DM Mono", monospace; font-size: 13px; font-weight: 500; color: rgba(240,244,255,0.4); padding: 6px 14px; border-radius: 50px; transition: all 0.2s; }
.unitBtn:hover { color: rgba(240,244,255,0.7); }
.unitActive { background: rgba(99,179,237,0.2) !important; color: #63b3ed !important; }
.error { background: rgba(252,129,129,0.1); border: 1px solid rgba(252,129,129,0.25); border-radius: 14px; padding: 14px 20px; color: #fc8181; font-size: 14px; margin-bottom: 24px; display: flex; align-items: center; gap: 10px; }
.skeleton { display: flex; flex-direction: column; gap: 16px; animation: pulse 1.5s ease infinite; }
.skeletonMain { height: 340px; background: rgba(255,255,255,0.04); border-radius: 28px; }
.skeletonRow { display: flex; gap: 16px; }
.skeletonCard { flex: 1; height: 160px; background: rgba(255,255,255,0.04); border-radius: 24px; }
@keyframes pulse { 0%,100% { opacity: 0.5; } 50% { opacity: 1; } }
.grid { display: grid; grid-template-columns: 1fr 360px; gap: 16px; flex: 1; }
@media (max-width: 1024px) { .grid { grid-template-columns: 1fr; } .sidebar { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; } }
@media (max-width: 640px) { .sidebar { grid-template-columns: 1fr; } }
.col { display: flex; flex-direction: column; gap: 16px; }
.sidebar { display: flex; flex-direction: column; gap: 16px; }
.footer { margin-top: 40px; text-align: center; font-size: 12px; color: rgba(240,244,255,0.25); }
.footer a { color: rgba(99,179,237,0.6); text-decoration: none; }
.footer a:hover { color: #63b3ed; }
'@ | Set-Content "app\page.module.css" -Encoding UTF8

# ── app/page.jsx ──────────────────────────────────────────────────────────────
@'
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
            <span className={styles.logoIcon}>🌤</span>
            <span className={styles.logoText}>Aether</span>
          </div>
          <SearchBar onSearch={loadWeather} onLocationClick={loadByLocation} />
          <div className={styles.unitToggle}>
            <button className={`${styles.unitBtn} ${unit==="C" ? styles.unitActive : ""}`} onClick={() => setUnit("C")}>°C</button>
            <button className={`${styles.unitBtn} ${unit==="F" ? styles.unitActive : ""}`} onClick={() => setUnit("F")}>°F</button>
          </div>
        </header>
        {error && <div className={styles.error}><span>⚠️</span> {error}</div>}
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
          Powered by <a href="https://openweathermap.org" target="_blank" rel="noopener noreferrer">OpenWeatherMap</a> · Built with Next.js
        </footer>
      </div>
    </div>
  );
}
'@ | Set-Content "app\page.jsx" -Encoding UTF8

# ── components/WeatherBackground.jsx ─────────────────────────────────────────
@'
"use client";
import styles from "./WeatherBackground.module.css";
const themes = {
  clear:   { gradient: "linear-gradient(160deg,#0f2027 0%,#1a3a5c 40%,#2c5f8a 100%)", accent: "#f5c842", particles: "stars" },
  clouds:  { gradient: "linear-gradient(160deg,#0a0e1a 0%,#1a2235 50%,#243347 100%)", accent: "#90cdf4", particles: "none" },
  rain:    { gradient: "linear-gradient(160deg,#0a0c14 0%,#111827 50%,#1a2235 100%)", accent: "#63b3ed", particles: "rain" },
  drizzle: { gradient: "linear-gradient(160deg,#0a0e1a 0%,#111827 50%,#1a2235 100%)", accent: "#76e4f7", particles: "rain" },
  storm:   { gradient: "linear-gradient(160deg,#05060a 0%,#0d1117 50%,#111827 100%)", accent: "#b794f4", particles: "storm" },
  snow:    { gradient: "linear-gradient(160deg,#0d1117 0%,#1a2235 50%,#243347 100%)", accent: "#bee3f8", particles: "snow" },
  fog:     { gradient: "linear-gradient(160deg,#111827 0%,#1f2937 50%,#243347 100%)", accent: "#a0aec0", particles: "none" },
};
function Stars() {
  return (
    <div className={styles.stars}>
      {Array.from({length:60}).map((_,i) => (
        <div key={i} className={styles.star} style={{left:`${Math.random()*100}%`,top:`${Math.random()*100}%`,animationDelay:`${Math.random()*4}s`,animationDuration:`${2+Math.random()*3}s`,width:`${Math.random()*2.5+0.5}px`,height:`${Math.random()*2.5+0.5}px`}} />
      ))}
    </div>
  );
}
function Rain() {
  return (
    <div className={styles.rain}>
      {Array.from({length:40}).map((_,i) => (
        <div key={i} className={styles.raindrop} style={{left:`${Math.random()*100}%`,animationDelay:`${Math.random()*2}s`,animationDuration:`${0.6+Math.random()*0.6}s`,opacity:0.15+Math.random()*0.25}} />
      ))}
    </div>
  );
}
function Snow() {
  return (
    <div className={styles.snow}>
      {Array.from({length:40}).map((_,i) => (
        <div key={i} className={styles.flake} style={{left:`${Math.random()*100}%`,animationDelay:`${Math.random()*5}s`,animationDuration:`${4+Math.random()*4}s`,width:`${Math.random()*6+2}px`,height:`${Math.random()*6+2}px`,opacity:0.3+Math.random()*0.4}} />
      ))}
    </div>
  );
}
export default function WeatherBackground({ theme = "clear" }) {
  const t = themes[theme] || themes.clear;
  return (
    <div className={styles.bg} style={{background: t.gradient}}>
      <div className={styles.orb1} style={{background:`radial-gradient(circle,${t.accent}22 0%,transparent 70%)`}} />
      <div className={styles.orb2} style={{background:`radial-gradient(circle,${t.accent}11 0%,transparent 70%)`}} />
      <div className={styles.noise} />
      {t.particles === "stars" && <Stars />}
      {(t.particles === "rain" || t.particles === "storm") && <Rain />}
      {t.particles === "snow" && <Snow />}
    </div>
  );
}
'@ | Set-Content "components\WeatherBackground.jsx" -Encoding UTF8

@'
.bg { position: fixed; inset: 0; z-index: 0; transition: background 1.5s ease; overflow: hidden; }
.orb1 { position: absolute; width: 700px; height: 700px; top: -200px; right: -150px; border-radius: 50%; animation: pulse 8s ease-in-out infinite; }
.orb2 { position: absolute; width: 500px; height: 500px; bottom: -100px; left: -100px; border-radius: 50%; animation: pulse 10s ease-in-out infinite reverse; }
.noise { position: absolute; inset: 0; opacity: 0.04; pointer-events: none; background-image: url("data:image/svg+xml,%3Csvg viewBox='0 0 200 200' xmlns='http://www.w3.org/2000/svg'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.9' numOctaves='4'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)' opacity='1'/%3E%3C/svg%3E"); }
.stars { position: absolute; inset: 0; }
.star { position: absolute; background: white; border-radius: 50%; animation: twinkle var(--dur,3s) ease-in-out infinite; }
@keyframes twinkle { 0%,100%{opacity:0.1;transform:scale(1)}50%{opacity:0.8;transform:scale(1.3)} }
.rain,.snow { position: absolute; inset: 0; }
.raindrop { position: absolute; top: -20px; width: 1.5px; height: 20px; background: linear-gradient(to bottom,transparent,rgba(147,210,255,0.6)); animation: fall linear infinite; }
@keyframes fall { 0%{transform:translateY(-30px)}100%{transform:translateY(110vh)} }
.flake { position: absolute; top: -20px; background: rgba(255,255,255,0.7); border-radius: 50%; animation: snowfall linear infinite; }
@keyframes snowfall { 0%{transform:translateY(-30px) translateX(0)}50%{transform:translateY(50vh) translateX(30px)}100%{transform:translateY(110vh) translateX(-15px)} }
@keyframes pulse { 0%,100%{transform:scale(1) translate(0,0);opacity:1}50%{transform:scale(1.1) translate(20px,-20px);opacity:0.7} }
'@ | Set-Content "components\WeatherBackground.module.css" -Encoding UTF8

# ── components/SearchBar.jsx ──────────────────────────────────────────────────
@'
"use client";
import { useState, useRef, useEffect } from "react";
import { searchCities } from "@/lib/weather";
import styles from "./SearchBar.module.css";
export default function SearchBar({ onSearch, onLocationClick }) {
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const debounceRef = useRef(null);
  useEffect(() => {
    if (query.length < 2) { setSuggestions([]); setOpen(false); return; }
    clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(async () => {
      setLoading(true);
      const res = await searchCities(query);
      setSuggestions(res); setOpen(res.length > 0); setLoading(false);
    }, 350);
    return () => clearTimeout(debounceRef.current);
  }, [query]);
  const handleSelect = (city) => {
    const name = city.local_names?.en || city.name;
    const full = city.state ? `${name}, ${city.state}, ${city.country}` : `${name}, ${city.country}`;
    onSearch(full); setQuery(""); setOpen(false);
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    if (query.trim()) { onSearch(query.trim()); setQuery(""); setOpen(false); }
  };
  return (
    <div className={styles.wrapper}>
      <form onSubmit={handleSubmit} className={styles.form}>
        <div className={styles.inputWrap}>
          <svg className={styles.searchIcon} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          <input className={styles.input} type="text" placeholder="Search city..." value={query} onChange={e => setQuery(e.target.value)} onFocus={() => suggestions.length > 0 && setOpen(true)} />
          {loading && <div className={styles.spinner} />}
          <button type="button" className={styles.locationBtn} onClick={onLocationClick} title="Use my location">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
          </button>
        </div>
        {open && (
          <ul className={styles.dropdown}>
            {suggestions.map((c,i) => (
              <li key={i} className={styles.suggestion} onMouseDown={() => handleSelect(c)}>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{opacity:0.4}}><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <span>{c.local_names?.en || c.name}</span>
                <span className={styles.country}>{c.state ? `${c.state}, ` : ""}{c.country}</span>
              </li>
            ))}
          </ul>
        )}
      </form>
    </div>
  );
}
'@ | Set-Content "components\SearchBar.jsx" -Encoding UTF8

@'
.wrapper { position: relative; width: 100%; max-width: 500px; margin: 0 auto; z-index: 100; }
.form { position: relative; }
.inputWrap { display: flex; align-items: center; background: rgba(255,255,255,0.06); border: 1px solid rgba(255,255,255,0.1); border-radius: 50px; padding: 0 16px; gap: 10px; backdrop-filter: blur(20px); transition: all 0.3s; }
.inputWrap:focus-within { background: rgba(255,255,255,0.09); border-color: rgba(99,179,237,0.4); box-shadow: 0 0 0 4px rgba(99,179,237,0.08); }
.searchIcon { opacity: 0.4; flex-shrink: 0; }
.input { flex: 1; background: none; border: none; outline: none; font-family: "DM Sans",sans-serif; font-size: 15px; color: #f0f4ff; padding: 14px 0; caret-color: #63b3ed; }
.input::placeholder { color: rgba(240,244,255,0.35); }
.locationBtn { background: none; border: none; cursor: pointer; color: rgba(240,244,255,0.4); padding: 4px; border-radius: 6px; display: flex; align-items: center; transition: color 0.2s; flex-shrink: 0; }
.locationBtn:hover { color: #63b3ed; }
.spinner { width: 16px; height: 16px; border: 2px solid rgba(99,179,237,0.2); border-top-color: #63b3ed; border-radius: 50%; animation: spin 0.7s linear infinite; flex-shrink: 0; }
@keyframes spin { to { transform: rotate(360deg); } }
.dropdown { position: absolute; top: calc(100% + 8px); left: 0; right: 0; background: rgba(15,20,35,0.97); border: 1px solid rgba(255,255,255,0.1); border-radius: 16px; list-style: none; overflow: hidden; backdrop-filter: blur(30px); animation: dropIn 0.2s ease; box-shadow: 0 20px 60px rgba(0,0,0,0.4); }
@keyframes dropIn { from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:translateY(0)} }
.suggestion { display: flex; align-items: center; gap: 10px; padding: 12px 18px; cursor: pointer; font-size: 14px; color: rgba(240,244,255,0.8); transition: background 0.15s; border-bottom: 1px solid rgba(255,255,255,0.05); }
.suggestion:last-child { border-bottom: none; }
.suggestion:hover { background: rgba(99,179,237,0.1); color: #f0f4ff; }
.country { margin-left: auto; font-size: 12px; color: rgba(240,244,255,0.35); }
'@ | Set-Content "components\SearchBar.module.css" -Encoding UTF8

# ── components/MainCard.jsx ───────────────────────────────────────────────────
@'
"use client";
import { formatSunTime, getWindDirection } from "@/lib/weather";
import styles from "./MainCard.module.css";
const ICONS = {"01d":"☀️","01n":"🌙","02d":"⛅","02n":"☁️","03d":"☁️","03n":"☁️","04d":"☁️","04n":"☁️","09d":"🌧️","09n":"🌧️","10d":"🌦️","10n":"🌧️","11d":"⛈️","11n":"⛈️","13d":"❄️","13n":"❄️","50d":"🌫️","50n":"🌫️"};
function Stat({label,value,icon}){return(<div className={styles.stat}><span className={styles.statIcon}>{icon}</span><div><div className={styles.statLabel}>{label}</div><div className={styles.statValue}>{value}</div></div></div>);}
export default function MainCard({data}){
  const icon=ICONS[data.weather[0].icon]||"🌤️";
  const temp=Math.round(data.main.temp);
  const high=Math.round(data.main.temp_max);
  const low=Math.round(data.main.temp_min);
  const feelsLike=Math.round(data.main.feels_like);
  const now=new Date();
  return(
    <div className={styles.card}>
      <div className={styles.header}>
        <div>
          <div className={styles.location}><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>{data.name}, {data.sys.country}</div>
          <div className={styles.date}>{now.toLocaleDateString("en-US",{weekday:"long",month:"long",day:"numeric"})}</div>
        </div>
        <div className={styles.time}>{now.toLocaleTimeString("en-US",{hour:"2-digit",minute:"2-digit",hour12:true})}</div>
      </div>
      <div className={styles.main}>
        <div className={styles.emoji}>{icon}</div>
        <div className={styles.tempBlock}>
          <div className={styles.temp}>{temp}°</div>
          <div className={styles.desc}>{data.weather[0].description}</div>
          <div className={styles.hiLo}><span>↑ {high}°</span><span className={styles.slash}>/</span><span>↓ {low}°</span></div>
        </div>
      </div>
      <div className={styles.stats}>
        <Stat label="Feels like" value={`${feelsLike}°`} icon="🌡️"/>
        <Stat label="Humidity" value={`${data.main.humidity}%`} icon="💧"/>
        <Stat label="Wind" value={`${Math.round(data.wind.speed)} m/s ${getWindDirection(data.wind.deg)}`} icon="💨"/>
        <Stat label="Pressure" value={`${data.main.pressure} hPa`} icon="📊"/>
        <Stat label="Sunrise" value={formatSunTime(data.sys.sunrise)} icon="🌅"/>
        <Stat label="Sunset" value={formatSunTime(data.sys.sunset)} icon="🌇"/>
        <Stat label="Visibility" value={`${(data.visibility/1000).toFixed(1)} km`} icon="👁️"/>
        <Stat label="Clouds" value={`${data.clouds.all}%`} icon="☁️"/>
      </div>
    </div>
  );
}
'@ | Set-Content "components\MainCard.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 28px; padding: 32px; backdrop-filter: blur(30px); animation: fadeUp 0.6s cubic-bezier(0.4,0,0.2,1); }
@keyframes fadeUp { from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)} }
.header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 32px; }
.location { display: flex; align-items: center; gap: 6px; font-size: 14px; font-weight: 500; color: rgba(240,244,255,0.7); }
.date { font-family: "Playfair Display",serif; font-size: 13px; color: rgba(240,244,255,0.35); margin-top: 4px; }
.time { font-family: "DM Mono",monospace; font-size: 13px; color: rgba(240,244,255,0.4); }
.main { display: flex; align-items: center; gap: 24px; margin-bottom: 36px; }
.emoji { font-size: 72px; line-height: 1; filter: drop-shadow(0 0 30px rgba(245,200,66,0.3)); animation: float 4s ease-in-out infinite; }
@keyframes float { 0%,100%{transform:translateY(0)}50%{transform:translateY(-8px)} }
.temp { font-family: "Playfair Display",serif; font-size: 88px; font-weight: 900; line-height: 1; color: #f0f4ff; letter-spacing: -4px; }
.desc { font-size: 16px; color: rgba(240,244,255,0.5); text-transform: capitalize; margin-top: 4px; }
.hiLo { display: flex; align-items: center; gap: 6px; font-size: 14px; color: rgba(240,244,255,0.5); margin-top: 6px; font-family: "DM Mono",monospace; }
.slash { color: rgba(240,244,255,0.2); }
.stats { display: grid; grid-template-columns: repeat(4,1fr); gap: 16px; }
@media (max-width:640px) { .stats{grid-template-columns:repeat(2,1fr)} .temp{font-size:64px} .emoji{font-size:52px} }
.stat { display: flex; align-items: center; gap: 10px; background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.06); border-radius: 14px; padding: 12px 14px; transition: background 0.2s; }
.stat:hover { background: rgba(99,179,237,0.06); }
.statIcon { font-size: 18px; }
.statLabel { font-size: 11px; color: rgba(240,244,255,0.35); text-transform: uppercase; letter-spacing: 0.07em; }
.statValue { font-size: 14px; font-weight: 500; color: rgba(240,244,255,0.85); margin-top: 2px; }
'@ | Set-Content "components\MainCard.module.css" -Encoding UTF8

# ── components/HourlyForecast.jsx ─────────────────────────────────────────────
@'
"use client";
import styles from "./HourlyForecast.module.css";
const ICONS={"01d":"☀️","01n":"🌙","02d":"⛅","02n":"☁️","03d":"☁️","03n":"☁️","04d":"☁️","04n":"☁️","09d":"🌧️","09n":"🌧️","10d":"🌦️","10n":"🌧️","11d":"⛈️","11n":"⛈️","13d":"❄️","13n":"❄️","50d":"🌫️","50n":"🌫️"};
export default function HourlyForecast({hours}){
  const maxTemp=Math.max(...hours.map(h=>h.temp));
  const minTemp=Math.min(...hours.map(h=>h.temp));
  return(
    <div className={styles.card}>
      <div className={styles.title}>Hourly Forecast</div>
      <div className={styles.scroll}>
        {hours.map((h,i)=>{
          const pct=maxTemp===minTemp?50:((h.temp-minTemp)/(maxTemp-minTemp))*100;
          return(
            <div key={i} className={styles.item} style={{animationDelay:`${i*0.06}s`}}>
              <div className={styles.time}>{i===0?"Now":h.time}</div>
              {h.pop>0&&<div className={styles.pop}><span>💧</span>{h.pop}%</div>}
              <div className={styles.icon}>{ICONS[h.weather.icon]||"🌤️"}</div>
              <div className={styles.bar}><div className={styles.barFill} style={{height:`${pct}%`}}/></div>
              <div className={styles.temp}>{h.temp}°</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
'@ | Set-Content "components\HourlyForecast.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 24px; padding: 24px; backdrop-filter: blur(30px); animation: fadeUp 0.7s cubic-bezier(0.4,0,0.2,1); }
@keyframes fadeUp { from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)} }
.title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; color: rgba(240,244,255,0.35); margin-bottom: 20px; }
.scroll { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 4px; scrollbar-width: none; }
.scroll::-webkit-scrollbar { display: none; }
.item { display: flex; flex-direction: column; align-items: center; gap: 8px; min-width: 68px; padding: 14px 10px; border-radius: 16px; background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.05); transition: background 0.2s; animation: slideIn 0.4s ease both; }
.item:hover { background: rgba(99,179,237,0.08); }
@keyframes slideIn { from{opacity:0;transform:translateX(12px)}to{opacity:1;transform:translateX(0)} }
.time { font-family: "DM Mono",monospace; font-size: 11px; color: rgba(240,244,255,0.4); }
.pop { display: flex; align-items: center; gap: 2px; font-size: 11px; color: #63b3ed; }
.icon { font-size: 22px; line-height: 1; }
.bar { width: 4px; height: 40px; background: rgba(255,255,255,0.07); border-radius: 2px; display: flex; align-items: flex-end; overflow: hidden; }
.barFill { width: 100%; background: linear-gradient(to top,#63b3ed,#b794f4); border-radius: 2px; transition: height 0.8s ease; }
.temp { font-size: 14px; font-weight: 600; color: rgba(240,244,255,0.85); }
'@ | Set-Content "components\HourlyForecast.module.css" -Encoding UTF8

# ── components/DailyForecast.jsx ──────────────────────────────────────────────
@'
"use client";
import styles from "./DailyForecast.module.css";
const ICONS={"01d":"☀️","01n":"🌙","02d":"⛅","02n":"☁️","03d":"☁️","03n":"☁️","04d":"☁️","04n":"☁️","09d":"🌧️","09n":"🌧️","10d":"🌦️","10n":"🌧️","11d":"⛈️","11n":"⛈️","13d":"❄️","13n":"❄️","50d":"🌫️","50n":"🌫️"};
export default function DailyForecast({days}){
  const all=days.flatMap(d=>[d.min,d.max]);
  const absMin=Math.min(...all);
  const absMax=Math.max(...all);
  return(
    <div className={styles.card}>
      <div className={styles.title}>5-Day Forecast</div>
      <div className={styles.list}>
        {days.map((day,i)=>{
          const date=new Date(day.date);
          const label=i===0?"Today":date.toLocaleDateString("en-US",{weekday:"short"});
          const minPct=((day.min-absMin)/(absMax-absMin))*100;
          const maxPct=((day.max-absMin)/(absMax-absMin))*100;
          return(
            <div key={i} className={styles.row} style={{animationDelay:`${i*0.08}s`}}>
              <span className={styles.day}>{label}</span>
              <span className={styles.icon}>{ICONS[day.weather.icon]||"🌤️"}</span>
              <span className={styles.desc}>{day.weather.description}</span>
              <div className={styles.range}>
                <span className={styles.low}>{day.min}°</span>
                <div className={styles.bar}><div className={styles.fill} style={{left:`${minPct}%`,width:`${maxPct-minPct}%`}}/></div>
                <span className={styles.high}>{day.max}°</span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
'@ | Set-Content "components\DailyForecast.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 24px; padding: 24px; backdrop-filter: blur(30px); animation: fadeUp 0.8s cubic-bezier(0.4,0,0.2,1); }
@keyframes fadeUp { from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)} }
.title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; color: rgba(240,244,255,0.35); margin-bottom: 16px; }
.list { display: flex; flex-direction: column; gap: 4px; }
.row { display: grid; grid-template-columns: 56px 28px 1fr auto; align-items: center; gap: 12px; padding: 10px 12px; border-radius: 12px; transition: background 0.2s; animation: fadeIn 0.4s ease both; }
.row:hover { background: rgba(255,255,255,0.04); }
@keyframes fadeIn { from{opacity:0}to{opacity:1} }
.day { font-size: 14px; font-weight: 500; color: rgba(240,244,255,0.7); }
.icon { font-size: 20px; text-align: center; }
.desc { font-size: 13px; color: rgba(240,244,255,0.35); text-transform: capitalize; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.range { display: flex; align-items: center; gap: 10px; min-width: 160px; }
.low { font-size: 14px; font-family: "DM Mono",monospace; color: rgba(240,244,255,0.4); min-width: 30px; text-align: right; }
.high { font-size: 14px; font-family: "DM Mono",monospace; color: rgba(240,244,255,0.85); min-width: 30px; }
.bar { flex: 1; height: 5px; background: rgba(255,255,255,0.08); border-radius: 3px; position: relative; overflow: hidden; }
.fill { position: absolute; height: 100%; border-radius: 3px; background: linear-gradient(to right,#63b3ed,#f5c842); }
'@ | Set-Content "components\DailyForecast.module.css" -Encoding UTF8

# ── components/AirQuality.jsx ─────────────────────────────────────────────────
@'
"use client";
import styles from "./AirQuality.module.css";
export default function AirQuality({data}){
  const h=data.main.humidity;
  const dew=Math.round(data.main.temp-((100-h)/5));
  const vis=(data.visibility/1000).toFixed(1);
  const stats=[
    {label:"Dew Point",value:`${dew}°C`,icon:"🌡️",color:"#68d391"},
    {label:"Humidity",value:`${h}%`,icon:"💧",bar:h,color:"#63b3ed"},
    {label:"Pressure",value:`${data.main.pressure} hPa`,icon:"📊",color:"#b794f4"},
    {label:"Visibility",value:`${vis} km`,icon:"👁️",bar:Math.min((parseFloat(vis)/10)*100,100),color:"#f5c842"},
    {label:"Cloud Cover",value:`${data.clouds.all}%`,icon:"☁️",bar:data.clouds.all,color:"#90cdf4"},
    {label:"Wind Gust",value:data.wind.gust?`${Math.round(data.wind.gust)} m/s`:"N/A",icon:"💨",color:"#fc8181"},
  ];
  return(
    <div className={styles.card}>
      <div className={styles.title}>Atmosphere</div>
      <div className={styles.grid}>
        {stats.map((s,i)=>(
          <div key={i} className={styles.item}>
            <div className={styles.top}><span className={styles.icon}>{s.icon}</span><span className={styles.label}>{s.label}</span></div>
            <div className={styles.value} style={{color:s.color}}>{s.value}</div>
            {s.bar!==undefined&&<div className={styles.barWrap}><div className={styles.barFill} style={{width:`${s.bar}%`,background:s.color}}/></div>}
          </div>
        ))}
      </div>
    </div>
  );
}
'@ | Set-Content "components\AirQuality.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 24px; padding: 24px; backdrop-filter: blur(30px); }
.title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; color: rgba(240,244,255,0.35); margin-bottom: 20px; }
.grid { display: grid; grid-template-columns: repeat(3,1fr); gap: 12px; }
@media (max-width:640px) { .grid{grid-template-columns:repeat(2,1fr)} }
.item { background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.05); border-radius: 14px; padding: 14px; transition: background 0.2s; }
.item:hover { background: rgba(255,255,255,0.06); }
.top { display: flex; align-items: center; gap: 6px; margin-bottom: 8px; }
.icon { font-size: 16px; }
.label { font-size: 11px; text-transform: uppercase; letter-spacing: 0.07em; color: rgba(240,244,255,0.35); }
.value { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
.barWrap { height: 3px; background: rgba(255,255,255,0.07); border-radius: 2px; overflow: hidden; }
.barFill { height: 100%; border-radius: 2px; transition: width 1s ease; opacity: 0.8; }
'@ | Set-Content "components\AirQuality.module.css" -Encoding UTF8

# ── components/WindCompass.jsx ────────────────────────────────────────────────
@'
"use client";
import { getWindDirection } from "@/lib/weather";
import styles from "./WindCompass.module.css";
function getBeaufort(mps){
  const s=[{max:0.5,level:0,name:"Calm",color:"#68d391"},{max:1.5,level:1,name:"Light Air",color:"#68d391"},{max:3.3,level:2,name:"Light Breeze",color:"#90cdf4"},{max:5.5,level:3,name:"Gentle Breeze",color:"#63b3ed"},{max:7.9,level:4,name:"Moderate Breeze",color:"#f5c842"},{max:10.7,level:5,name:"Fresh Breeze",color:"#f5c842"},{max:13.8,level:6,name:"Strong Breeze",color:"#fc8181"},{max:17.1,level:7,name:"Near Gale",color:"#fc8181"},{max:20.7,level:8,name:"Gale",color:"#b794f4"},{max:24.4,level:9,name:"Strong Gale",color:"#b794f4"},{max:28.4,level:10,name:"Storm",color:"#fc8181"},{max:32.6,level:11,name:"Violent Storm",color:"#fc8181"},{max:Infinity,level:12,name:"Hurricane",color:"#fc8181"}];
  return s.find(x=>mps<=x.max)||s[s.length-1];
}
export default function WindCompass({data}){
  const speed=Math.round(data.wind.speed);
  const deg=data.wind.deg||0;
  const gust=data.wind.gust?Math.round(data.wind.gust):null;
  const dir=getWindDirection(deg);
  const b=getBeaufort(speed);
  return(
    <div className={styles.card}>
      <div className={styles.title}>Wind</div>
      <div className={styles.body}>
        <div className={styles.compassWrap}>
          <div className={styles.compass}>
            {["N","E","S","W"].map(d=><span key={d} className={styles["dir"+d]}>{d}</span>)}
            <div className={styles.needle} style={{transform:`rotate(${deg}deg)`}}>
              <div className={styles.needleHead}/>
              <div className={styles.needleTail}/>
            </div>
            <div className={styles.center}/>
          </div>
        </div>
        <div className={styles.info}>
          <div className={styles.speedBlock}>
            <div className={styles.speed}>{speed}</div>
            <div className={styles.unit}>m/s</div>
          </div>
          <div className={styles.direction}>{dir} · {deg}°</div>
          {gust&&<div className={styles.gust}>Gust: {gust} m/s</div>}
          <div className={styles.beaufort}>
            <div className={styles.beaufortLabel}>Beaufort Scale</div>
            <div className={styles.beaufortBar}>
              {Array.from({length:12}).map((_,i)=><div key={i} className={styles.beaufortCell} style={{background:i<b.level?b.color:"rgba(255,255,255,0.08)"}}/>)}
            </div>
            <div className={styles.beaufortName} style={{color:b.color}}>{b.name}</div>
          </div>
        </div>
      </div>
    </div>
  );
}
'@ | Set-Content "components\WindCompass.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 24px; padding: 24px; backdrop-filter: blur(30px); }
.title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; color: rgba(240,244,255,0.35); margin-bottom: 20px; }
.body { display: flex; align-items: center; gap: 24px; }
.compassWrap { flex-shrink: 0; }
.compass { width: 100px; height: 100px; border-radius: 50%; border: 1.5px solid rgba(255,255,255,0.12); background: radial-gradient(circle,rgba(99,179,237,0.05),transparent); position: relative; display: flex; align-items: center; justify-content: center; }
.compass::before { content:""; position:absolute; inset:8px; border-radius:50%; border:1px dashed rgba(255,255,255,0.06); }
.dirN,.dirE,.dirS,.dirW { position:absolute; font-size:10px; font-weight:600; font-family:"DM Mono",monospace; color:rgba(240,244,255,0.4); }
.dirN{top:6px;left:50%;transform:translateX(-50%)} .dirS{bottom:6px;left:50%;transform:translateX(-50%)} .dirE{right:8px;top:50%;transform:translateY(-50%)} .dirW{left:8px;top:50%;transform:translateY(-50%)}
.needle { position:absolute; width:2px; height:60px; left:calc(50% - 1px); top:calc(50% - 30px); transform-origin:50% 50%; transition:transform 1s cubic-bezier(0.34,1.56,0.64,1); display:flex; flex-direction:column; align-items:center; }
.needleHead { width:0; height:0; border-left:5px solid transparent; border-right:5px solid transparent; border-bottom:28px solid #63b3ed; margin-bottom:2px; }
.needleTail { width:0; height:0; border-left:4px solid transparent; border-right:4px solid transparent; border-top:22px solid rgba(240,244,255,0.2); }
.center { width:8px; height:8px; background:#f0f4ff; border-radius:50%; position:absolute; top:calc(50% - 4px); left:calc(50% - 4px); z-index:1; box-shadow:0 0 10px rgba(99,179,237,0.5); }
.info { flex:1; }
.speedBlock { display:flex; align-items:baseline; gap:6px; margin-bottom:4px; }
.speed { font-family:"Playfair Display",serif; font-size:48px; font-weight:900; color:#f0f4ff; line-height:1; }
.unit { font-size:14px; color:rgba(240,244,255,0.4); }
.direction { font-size:14px; font-family:"DM Mono",monospace; color:rgba(240,244,255,0.5); margin-bottom:4px; }
.gust { font-size:13px; color:#fc8181; margin-bottom:16px; }
.beaufort { margin-top:12px; }
.beaufortLabel { font-size:10px; text-transform:uppercase; letter-spacing:0.08em; color:rgba(240,244,255,0.3); margin-bottom:6px; }
.beaufortBar { display:flex; gap:3px; margin-bottom:5px; }
.beaufortCell { flex:1; height:5px; border-radius:2px; transition:background 0.3s; }
.beaufortName { font-size:12px; font-weight:500; }
'@ | Set-Content "components\WindCompass.module.css" -Encoding UTF8

# ── components/SunriseSunset.jsx ──────────────────────────────────────────────
@'
"use client";
import { formatSunTime } from "@/lib/weather";
import styles from "./SunriseSunset.module.css";
export default function SunriseSunset({data}){
  const sunrise=data.sys.sunrise,sunset=data.sys.sunset;
  const now=Math.floor(Date.now()/1000);
  const dayLength=sunset-sunrise;
  const elapsed=Math.max(0,Math.min(now-sunrise,dayLength));
  const progress=(elapsed/dayLength)*100;
  const isDay=now>=sunrise&&now<=sunset;
  const angle=(progress/100)*180;
  const rad=(angle*Math.PI)/180;
  const cx=50+40*Math.cos(Math.PI-rad);
  const cy=50-40*Math.sin(Math.PI-rad);
  const dayH=Math.floor(dayLength/3600),dayM=Math.floor((dayLength%3600)/60);
  return(
    <div className={styles.card}>
      <div className={styles.title}>Sun & Moon</div>
      <svg viewBox="0 0 100 60" className={styles.svg}>
        <path d="M 10 50 A 40 40 0 0 1 90 50" fill="none" stroke="rgba(255,255,255,0.08)" strokeWidth="2" strokeLinecap="round"/>
        <path d="M 10 50 A 40 40 0 0 1 90 50" fill="none" stroke="url(#sg)" strokeWidth="2" strokeLinecap="round" strokeDasharray="125.6" strokeDashoffset={125.6-(progress/100)*125.6}/>
        <defs><linearGradient id="sg" x1="0%" y1="0%" x2="100%" y2="0%"><stop offset="0%" stopColor="#f5c842"/><stop offset="100%" stopColor="#fc8181"/></linearGradient></defs>
        <line x1="6" y1="50" x2="94" y2="50" stroke="rgba(255,255,255,0.1)" strokeWidth="1"/>
        {isDay&&<g><circle cx={cx} cy={cy} r="5" fill="#f5c842" opacity="0.2"/><circle cx={cx} cy={cy} r="3" fill="#f5c842"/></g>}
      </svg>
      <div className={styles.labels}>
        <div className={styles.sunTime}><span>🌅</span><div><div className={styles.sunLabel}>Sunrise</div><div className={styles.sunValue}>{formatSunTime(sunrise)}</div></div></div>
        <div className={styles.dayLength}><div className={styles.dayLabel}>Day length</div><div className={styles.dayValue}>{dayH}h {dayM}m</div></div>
        <div className={styles.sunTime}><span>🌇</span><div><div className={styles.sunLabel}>Sunset</div><div className={styles.sunValue}>{formatSunTime(sunset)}</div></div></div>
      </div>
      <div className={styles.progressWrap}>
        <div className={styles.progressBar}><div className={styles.progressFill} style={{width:`${Math.max(0,Math.min(progress,100))}%`}}/></div>
        <div className={styles.progressPct}>{Math.round(progress)}% of day elapsed</div>
      </div>
    </div>
  );
}
'@ | Set-Content "components\SunriseSunset.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 24px; padding: 24px; backdrop-filter: blur(30px); }
.title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; color: rgba(240,244,255,0.35); margin-bottom: 16px; }
.svg { width: 100%; max-height: 110px; display: block; }
.labels { display: flex; justify-content: space-between; align-items: center; margin-top: 8px; }
.sunTime { display: flex; align-items: center; gap: 8px; font-size: 20px; }
.sunLabel { font-size: 10px; text-transform: uppercase; letter-spacing: 0.08em; color: rgba(240,244,255,0.35); }
.sunValue { font-size: 14px; font-weight: 600; font-family: "DM Mono",monospace; color: rgba(240,244,255,0.85); }
.dayLength { text-align: center; }
.dayLabel { font-size: 10px; text-transform: uppercase; letter-spacing: 0.08em; color: rgba(240,244,255,0.35); }
.dayValue { font-size: 15px; font-weight: 600; color: #f5c842; }
.progressWrap { margin-top: 16px; padding-top: 16px; border-top: 1px solid rgba(255,255,255,0.06); }
.progressBar { height: 4px; background: rgba(255,255,255,0.08); border-radius: 2px; overflow: hidden; margin-bottom: 6px; }
.progressFill { height: 100%; background: linear-gradient(to right,#f5c842,#fc8181); border-radius: 2px; transition: width 1s ease; }
.progressPct { font-size: 11px; color: rgba(240,244,255,0.35); text-align: right; font-family: "DM Mono",monospace; }
'@ | Set-Content "components\SunriseSunset.module.css" -Encoding UTF8

# ── components/FavoriteCities.jsx ─────────────────────────────────────────────
@'
"use client";
import { useState, useEffect } from "react";
import { fetchWeather } from "@/lib/weather";
import styles from "./FavoriteCities.module.css";
const ICONS={"01d":"☀️","01n":"🌙","02d":"⛅","02n":"☁️","03d":"☁️","03n":"☁️","04d":"☁️","04n":"☁️","09d":"🌧️","09n":"🌧️","10d":"🌦️","10n":"🌧️","11d":"⛈️","11n":"⛈️","13d":"❄️","13n":"❄️","50d":"🌫️","50n":"🌫️"};
const CITIES=["New York","London","Tokyo","Dubai"];
export default function FavoriteCities({onSelect,currentCity}){
  const [cities,setCities]=useState([]);
  const [loading,setLoading]=useState(true);
  useEffect(()=>{
    Promise.all(CITIES.map(async city=>{
      try{const d=await fetchWeather(city);return{name:city,temp:Math.round(d.main.temp),icon:d.weather[0].icon,desc:d.weather[0].main};}
      catch{return null;}
    })).then(res=>{setCities(res.filter(Boolean));setLoading(false);});
  },[]);
  if(loading)return(<div className={styles.card}><div className={styles.title}>World Cities</div><div className={styles.loading}>{[1,2,3,4].map(i=><div key={i} className={styles.skeleton}/>)}</div></div>);
  return(
    <div className={styles.card}>
      <div className={styles.title}>World Cities</div>
      <div className={styles.list}>
        {cities.map((c,i)=>(
          <button key={i} className={`${styles.city} ${currentCity===c.name?styles.active:""}`} onClick={()=>onSelect(c.name)}>
            <span className={styles.cityIcon}>{ICONS[c.icon]||"🌤️"}</span>
            <span className={styles.cityName}>{c.name}</span>
            <span className={styles.cityDesc}>{c.desc}</span>
            <span className={styles.cityTemp}>{c.temp}°</span>
          </button>
        ))}
      </div>
    </div>
  );
}
'@ | Set-Content "components\FavoriteCities.jsx" -Encoding UTF8

@'
.card { background: rgba(255,255,255,0.045); border: 1px solid rgba(255,255,255,0.08); border-radius: 24px; padding: 24px; backdrop-filter: blur(30px); }
.title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.12em; color: rgba(240,244,255,0.35); margin-bottom: 16px; }
.list { display: flex; flex-direction: column; gap: 6px; }
.loading { display: flex; flex-direction: column; gap: 8px; }
.skeleton { height: 48px; border-radius: 12px; background: rgba(255,255,255,0.04); animation: shimmer 1.5s ease infinite; }
@keyframes shimmer { 0%,100%{opacity:0.4}50%{opacity:0.8} }
.city { display:flex; align-items:center; gap:12px; padding:12px 14px; border-radius:14px; border:1px solid rgba(255,255,255,0.05); background:rgba(255,255,255,0.03); cursor:pointer; text-align:left; color:rgba(240,244,255,0.8); font-family:"DM Sans",sans-serif; transition:all 0.2s; width:100%; }
.city:hover { background:rgba(99,179,237,0.08); border-color:rgba(99,179,237,0.2); }
.city.active { background:rgba(99,179,237,0.12); border-color:rgba(99,179,237,0.3); }
.cityIcon { font-size:20px; }
.cityName { font-size:14px; font-weight:500; flex:1; }
.cityDesc { font-size:12px; color:rgba(240,244,255,0.35); }
.cityTemp { font-size:16px; font-weight:600; font-family:"DM Mono",monospace; color:rgba(240,244,255,0.85); }
'@ | Set-Content "components\FavoriteCities.module.css" -Encoding UTF8

Write-Host ""
Write-Host "✅ All files created!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Open .env.local and paste your OpenWeatherMap API key"
Write-Host "  2. Run: npm install"
Write-Host "  3. Run: npm run dev"
Write-Host "  4. Open: http://localhost:3000"
Write-Host ""
Write-Host "Get your free API key at: https://openweathermap.org/api" -ForegroundColor Cyan