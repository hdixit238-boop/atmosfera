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