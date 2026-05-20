const API_KEY = process.env.NEXT_PUBLIC_WEATHER_API_KEY || process.env.NEXT_PUBLIC_OPENWEATHER_API_KEY;
const BASE = "https://api.openweathermap.org/data/2.5";
const GEO  = "https://api.openweathermap.org/geo/1.0";

function assertApiKey() {
  if (!API_KEY) throw new Error("OpenWeather API key is missing");
}

async function handleResponse(res, fallback) {
  if (res.ok) return res.json();
  if (res.status === 401) throw new Error("Invalid OpenWeather API key");
  try {
    const data = await res.json();
    if (data?.message) throw new Error(data.message);
  } catch (_) {}
  throw new Error(fallback);
}

export async function fetchWeather(city) {
  assertApiKey();
  const r = await fetch(`${BASE}/weather?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`);
  return handleResponse(r, "City not found");
}
export async function fetchWeatherByCoords(lat, lon) {
  assertApiKey();
  const r = await fetch(`${BASE}/weather?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`);
  return handleResponse(r, "Location not found");
}
export async function fetchForecast(city) {
  assertApiKey();
  const r = await fetch(`${BASE}/forecast?q=${encodeURIComponent(city)}&appid=${API_KEY}&units=metric`);
  return handleResponse(r, "Forecast unavailable");
}
export async function fetchForecastByCoords(lat, lon) {
  assertApiKey();
  const r = await fetch(`${BASE}/forecast?lat=${lat}&lon=${lon}&appid=${API_KEY}&units=metric`);
  return handleResponse(r, "Forecast unavailable");
}
export async function searchCities(query) {
  assertApiKey();
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
