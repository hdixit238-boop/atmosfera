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