'use client';

import { useState, useEffect } from 'react';

const API_KEY = process.env.NEXT_PUBLIC_OPENWEATHER_API_KEY;

function weatherIcon(id) {
  if (id >= 200 && id < 300) return '⛈️';
  if (id >= 300 && id < 400) return '🌦️';
  if (id >= 500 && id < 600) return '🌧️';
  if (id >= 600 && id < 700) return '❄️';
  if (id >= 700 && id < 800) return '🌫️';
  if (id === 800) return '☀️';
  if (id === 801) return '🌤️';
  if (id === 802) return '⛅';
  return '☁️';
}

function toDisplay(c, unit) {
  return unit === 'C' ? Math.round(c) : Math.round(c * 9 / 5 + 32);
}

function getWindDir(deg) {
  const dirs = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  return dirs[Math.round(deg / 45) % 8];
}

function fmtTime(ts) {
  return new Date(ts * 1000).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', hour12: true });
}

export default function Home() {
  const [unit, setUnit] = useState('C');
  const [query, setQuery] = useState('');
  const [weather, setWeather] = useState(null);
  const [forecast, setForecast] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => { fetchWeather('Pune'); }, []);

  async function fetchWeather(city) {
    setLoading(true); setError(''); setWeather(null);
    try {
      const [wRes, fRes] = await Promise.all([
        fetch(`https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`),
        fetch(`https://api.openweathermap.org/data/2.5/forecast?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`)
      ]);
      if (!wRes.ok) throw new Error('City not found. Try another name.');
      const [w, f] = await Promise.all([wRes.json(), fRes.json()]);
      setWeather(w); setForecast(f);
    } catch (e) { setError(e.message); }
    finally { setLoading(false); }
  }

  async function fetchByCoords(lat, lon) {
    setLoading(true); setError(''); setWeather(null);
    try {
      const [wRes, fRes] = await Promise.all([
        fetch(`https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`),
        fetch(`https://api.openweathermap.org/data/2.5/forecast?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`)
      ]);
      const [w, f] = await Promise.all([wRes.json(), fRes.json()]);
      setWeather(w); setForecast(f);
    } catch (e) { setError('Could not load location.'); }
    finally { setLoading(false); }
  }

  function getLocation() {
    if (!navigator.geolocation) { setError('Geolocation not supported.'); return; }
    setLoading(true);
    navigator.geolocation.getCurrentPosition(
      p => fetchByCoords(p.coords.latitude, p.coords.longitude),
      () => { setError('Location access denied.'); setLoading(false); }
    );
  }

  function getForecastDays(f) {
    if (!f || !f.list) return [];
    const days = {};
    f.list.forEach(item => {
      const d = new Date(item.dt * 1000);
      const key = d.toDateString();
      if (!days[key]) days[key] = { name: d.toLocaleDateString('en-US', { weekday: 'short' }), date: d.getDate(), highs: [], lows: [], icons: [] };
      days[key].highs.push(item.main.temp_max);
      days[key].lows.push(item.main.temp_min);
      days[key].icons.push(item.weather[0].id);
    });
    return Object.values(days).slice(1, 6);
  }

  const forecastDays = getForecastDays(forecast);
  const now = new Date();

  return (
    <div className="root">
      {/* Subtle grain overlay */}
      <div className="grain" />

      <div className="shell">

        {/* ── TOP BAR ── */}
        <header className="topbar">
          <div className="brand">
            <span className="brand-icon">🌤</span>
            <span className="brand-name">Atmosfera</span>
          </div>

          <div className="search-row">
            <div className="search-box">
              <span className="search-icon">🔍</span>
              <input
                className="search-input"
                type="text"
                placeholder="Search city…"
                value={query}
                onChange={e => setQuery(e.target.value)}
                onKeyDown={e => e.key === 'Enter' && query.trim() && fetchWeather(query.trim())}
              />
            </div>
            <button className="loc-btn" onClick={getLocation} title="Use my location">
              <span>◎</span> Locate me
            </button>
          </div>

          <div className="unit-row">
            <button className={`unit-pill${unit === 'C' ? ' on' : ''}`} onClick={() => setUnit('C')}>°C</button>
            <button className={`unit-pill${unit === 'F' ? ' on' : ''}`} onClick={() => setUnit('F')}>°F</button>
          </div>
        </header>

        {/* ── STATES ── */}
        {loading && (
          <div className="state-wrap">
            <div className="leaf-loader">🍂</div>
            <p className="state-txt">Fetching weather…</p>
          </div>
        )}
        {error && !loading && (
          <div className="state-wrap">
            <p className="error-txt">⚠ {error}</p>
          </div>
        )}

        {/* ── MAIN CONTENT ── */}
        {weather && !loading && (
          <main className="content">

            {/* ── LEFT PANEL ── */}
            <section className="left-panel">

              {/* Hero weather */}
              <div className="hero-card">
                <div className="hero-top">
                  <div>
                    <div className="hero-city">{weather.name}</div>
                    <div className="hero-country">{weather.sys?.country} · {now.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</div>
                  </div>
                  <div className="hero-icon">{weatherIcon(weather.weather[0].id)}</div>
                </div>

                <div className="hero-temp">
                  {toDisplay(weather.main.temp, unit)}<span className="hero-unit">°{unit}</span>
                </div>
                <div className="hero-desc">{weather.weather[0].description}</div>
                <div className="hero-range">
                  <span>↑ {toDisplay(weather.main.temp_max, unit)}°</span>
                  <span className="dot">·</span>
                  <span>↓ {toDisplay(weather.main.temp_min, unit)}°</span>
                  <span className="dot">·</span>
                  <span>Feels {toDisplay(weather.main.feels_like, unit)}°</span>
                </div>
              </div>

              {/* Sun times */}
              {weather.sys?.sunrise && (
                <div className="sun-card">
                  <SunArc sunrise={weather.sys.sunrise} sunset={weather.sys.sunset} />
                  <div className="sun-times">
                    <div className="sun-item">
                      <span className="sun-label">Sunrise</span>
                      <span className="sun-val">🌅 {fmtTime(weather.sys.sunrise)}</span>
                    </div>
                    <div className="sun-item">
                      <span className="sun-label">Sunset</span>
                      <span className="sun-val">🌇 {fmtTime(weather.sys.sunset)}</span>
                    </div>
                  </div>
                </div>
              )}

              {/* Forecast */}
              <div className="forecast-card">
                <div className="card-title">5-Day Forecast</div>
                <div className="forecast-list">
                  {forecastDays.map((d, i) => (
                    <div className="fc-row" key={i}>
                      <span className="fc-day">{d.name} {d.date}</span>
                      <span className="fc-ico">{weatherIcon(d.icons[Math.floor(d.icons.length / 2)])}</span>
                      <div className="fc-bar-wrap">
                        <TempBar
                          low={toDisplay(Math.min(...d.lows), unit)}
                          high={toDisplay(Math.max(...d.highs), unit)}
                          unit={unit}
                        />
                      </div>
                      <span className="fc-high">{toDisplay(Math.max(...d.highs), unit)}°</span>
                    </div>
                  ))}
                </div>
              </div>

            </section>

            {/* ── RIGHT PANEL ── */}
            <section className="right-panel">

              <div className="card-title" style={{marginBottom:'16px'}}>Right Now</div>

              <div className="detail-grid">
                <DetailTile icon="💧" label="Humidity" value={`${weather.main.humidity}%`} bar={weather.main.humidity} />
                <DetailTile icon="💨" label="Wind" value={`${Math.round(weather.wind.speed * 3.6)} km/h`} sub={`${getWindDir(weather.wind.deg)} · ${weather.wind.deg}°`} />
                <DetailTile icon="👁" label="Visibility" value={`${(weather.visibility / 1000).toFixed(1)} km`} />
                <DetailTile icon="🌡" label="Pressure" value={`${weather.main.pressure}`} sub="hPa" />
                <DetailTile icon="🌬" label="Gust" value={weather.wind.gust ? `${Math.round(weather.wind.gust * 3.6)} km/h` : '—'} />
                <DetailTile icon="☁️" label="Cloud Cover" value={`${weather.clouds.all}%`} bar={weather.clouds.all} />
              </div>

              {/* Comfort index */}
              <div className="comfort-card">
                <div className="card-title" style={{marginBottom:'14px'}}>Comfort Index</div>
                <ComfortMeter humidity={weather.main.humidity} temp={weather.main.temp} />
              </div>

            </section>
          </main>
        )}

        {!weather && !loading && !error && (
          <div className="state-wrap">
            <p className="state-txt">Search a city to begin 🌿</p>
          </div>
        )}

      </div>
    </div>
  );
}

/* ── SUB-COMPONENTS ── */

function DetailTile({ icon, label, value, sub, bar }) {
  return (
    <div className="detail-tile">
      <span className="tile-icon">{icon}</span>
      <div className="tile-body">
        <span className="tile-label">{label}</span>
        <span className="tile-val">{value}</span>
        {sub && <span className="tile-sub">{sub}</span>}
        {bar !== undefined && (
          <div className="tile-bar-bg">
            <div className="tile-bar-fill" style={{ width: `${bar}%` }} />
          </div>
        )}
      </div>
    </div>
  );
}

function ComfortMeter({ humidity, temp }) {
  // Simple heat index comfort score 0–100
  const score = Math.max(0, Math.min(100, 100 - Math.abs(temp - 22) * 3 - Math.abs(humidity - 50) * 0.5));
  const label = score > 75 ? 'Very Comfortable' : score > 50 ? 'Comfortable' : score > 30 ? 'Moderate' : 'Uncomfortable';
  const color = score > 75 ? 'var(--green)' : score > 50 ? 'var(--amber)' : score > 30 ? 'var(--terracotta)' : 'var(--rust)';
  return (
    <div className="comfort-wrap">
      <div className="comfort-track">
        <div className="comfort-fill" style={{ width: `${score}%`, background: color }} />
        <div className="comfort-thumb" style={{ left: `${score}%`, background: color }} />
      </div>
      <div className="comfort-labels">
        <span style={{ color }}>{ label }</span>
        <span className="comfort-score">{Math.round(score)}/100</span>
      </div>
    </div>
  );
}

function TempBar({ low, high, unit }) {
  const min = unit === 'C' ? -10 : 14;
  const max = unit === 'C' ? 45 : 113;
  const l = ((low - min) / (max - min)) * 100;
  const h = ((high - min) / (max - min)) * 100;
  return (
    <div className="temp-track">
      <div className="temp-fill" style={{ left: `${l}%`, width: `${h - l}%` }} />
    </div>
  );
}

function SunArc({ sunrise, sunset }) {
  const rise = sunrise * 1000;
  const set = sunset * 1000;
  const pct = Math.max(0, Math.min(1, (Date.now() - rise) / (set - rise)));
  const t = pct;
  const cx = 30 + t * 400;
  const cy = Math.pow(1 - t, 2) * 95 + 2 * (1 - t) * t * 5 + t * t * 95;
  return (
    <svg viewBox="0 0 460 100" className="arc-svg">
      <defs>
        <linearGradient id="sunGrad" x1="0%" y1="0%" x2="100%" y2="0%">
          <stop offset="0%" stopColor="#c8702a" stopOpacity="0.3" />
          <stop offset="50%" stopColor="#f4a942" stopOpacity="0.8" />
          <stop offset="100%" stopColor="#c8702a" stopOpacity="0.3" />
        </linearGradient>
      </defs>
      <path d="M 30 95 Q 230 5 430 95" fill="none" stroke="url(#sunGrad)" strokeWidth="2" strokeDasharray="4 4" />
      <circle cx={cx} cy={cy} r="7" fill="#f4a942" opacity="0.95" />
      <circle cx={cx} cy={cy} r="12" fill="#f4a942" opacity="0.2" />
    </svg>
  );
}