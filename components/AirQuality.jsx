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